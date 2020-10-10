#!/bin/sh
#
#       A simple script to bring the OS configuration files listed in /config/data/.manifest
#       under /config/data so they can be versioned by git.
#       The files are also tar'ed to allow easy installation in another machine preserving owner/permission
#       Every time the script is run, the copy of files is refereshed (i.e. all old files deleted first)
#       This file has only been tested on FreeBSD 12.1
#
#       (C) 2020 The Epicurean Engineer
#
##############################################################################################################
##
##                                      CONFIGURATION SECTION
##
##############################################################################################################
#
#
#       1. Declare your targets
#       Usually, this will just be "host" but you may want to include jails or containers
#       The name you choose will be used also as the directory name
#       example 1: TARGETS="host"
#       example 2: TARGETS="host jail1 jail2 jail3"
#
#TARGETS="host calibre drwin ghost git monitor nextcloud"
TARGETS="host"
#
#       2. For each of your targets declare their root directory; make sure to use the same
#       names you used in Step 1 in the format ROOT_${TARGETNAME}
#       Attention: no need to add a trailing slash, so for the root directory, just make it empty!
#
ROOT_host=""
#ROOT_calibre="/jail/calibre"
#ROOT_drwin="/jail/drwin"
#ROOT_ghost="/jail/ghost"
#ROOT_git="/jail/git"
#ROOT_monitor="/jail/monitor"
#ROOT_nextcloud="/jail/nextcloud"
#
#       3. Decide the (persistent) working directory, the data directory, the manifest file and tarball
#       file names. You may use the defaults proposed
#
config_dir="/config"
data_dir="data"
manifest=".manifest"
tarball="os_config.tgz"
#
##############################################################################################################
##
##                                      END OF CONFIGURATION SECTION
##
##############################################################################################################
#
#       We start with sanity checks
#
ALLOK="yes"
for target in $TARGETS
do
        target_root=$(eval echo \$ROOT_$target)
        #
        #       Verify the manifest file
        #
        manifest_target="$config_dir/$data_dir/$target/$manifest"
        if [ ! -f $manifest_target ]; then
                echo "Error: Can't find manifest file $manifest_target."
                ALLOK="no"
        else
                unknown_files=no
                for f in `cat $manifest_target`; do
                        if [ ! -f $target_root/$f ]; then
                                echo "Error: Cannot find file $target_root/$f"
                                unknown_files=yes
                        fi
                done
                if [ "$unknown_files" == "yes" ] ; then
                        echo "Error: Some files in tha manifest file $target_root/$manifest have not been found."
                        ALLOK="no"
                fi

        fi
done

if [ "$ALLOK" == "no" ] ; then
        echo "Errors found. Please correct them before running the script again."
        exit 1
fi

#
#       Main loop
#
for target in $TARGETS
do
        target_root=$(eval echo \$ROOT_$target)
        target_data_dir="$config_dir/$data_dir/$target"
        target_manifest="$config_dir/$data_dir/$target/$manifest"
        target_tarball="$config_dir/$data_dir/$target/$tarball"
        #
        #       Clean up our directory
        #       Attention: we assume that all files not starting with '.' (apart from READMEs) should be deleted.
        #
        echo -n "Cleaning up old files for $target..."
        find ${target_data_dir} -maxdepth 1 -mindepth 1 -not -iname ".[A-z]*" -not -iname "README*" | xargs -r  rm -r
        echo "done"
        #
        #       Create the tarball and copy the files over
        #
        echo "Copying over files and creating a new tarball for $target."
        echo "If you don't see a file you want there please update the manifest file $target_manifest."
        ( cd $target_root/ ; tar -czf - -T ${target_manifest} ) | tee ${target_tarball} | (cd ${target_data_dir}/  ; tar -xpvzf - )
        echo done
done

echo "all done. You may run git add . in directory $config/$data_dir now"
#
#       EOF
#

