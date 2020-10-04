#!/bin/sh
#
#	A simple script to bring the OS configuration files listed in /config/data/.manifest
#	under /config/data so they can be versioned by git. 
#	The files are also tar'ed to allow easy installation in another machine preserving owner/permission
#	Every time the script is run, the copy of files is refereshed (i.e. all old files deleted first)
#	This file has only been tested on FreeBSD 12.1
#
#	(C) 2020 The Epicurean Engineer
#
config_dir="/config"
data_dir="$config_dir/data"
manifest="${data_dir}/.manifest"
tarball="${data_dir}/os_config.tgz"

if [ ! -f $manifest ]; then
	echo "Can't find manifest file $manifest. Exiting..."
	exit 1
fi
#
#	Verify the manifest file
#
unknown_files=no
for f in `cat $manifest`; do
	if [ ! -f /$f ]; then
		echo "Cannot find file /$f"
		unknown_files=yes
	fi
done
if [ "$unknown_files" == "yes" ] ; then
	echo "Some files in tha manifest file $manifest have not been found."
	echo "Please correct. Exiting..."
	exit 1
else
	echo "all files in the manifest located."
fi
#
#	Clean up our directory
#	Attention: we assume that all files not starting with '.' (apart from READMEs) should be deleted.
#
echo -n "Cleaning up old files..."
find ${data_dir} -maxdepth 1 -mindepth 1 -not -iname ".[A-z]*" -not -iname "README*" | xargs -r  rm -r
echo "done"
#
#	Create the tarball and copy the files over
#
echo "Copying over files and creating a new tarball. If you don't see a file you want there please update"
echo "the manifest file $manifest."
( cd / ; tar -czf - -T ${manifest} ) | tee ${tarball} | (cd ${data_dir}  ; tar -xpvzf - )
#
echo done
#
#
echo "all done. You may run git add . in directory $data_dir now"
