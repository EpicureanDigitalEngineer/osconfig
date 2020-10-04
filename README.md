# `osconfig`: maintaining FreeBSD configuration files in a git repository

`osconfig` is a recipe to maintain FreeBSD configuration files in a git repository. The recipe can be used to safeguard, document (and recover) those configuration files that differ from the vanilla installation. Before proceeding, please evaluate
other existing solutions (e.g. `etckeeper`) to ensure that this one fits your needs better.

> :warning: **WARNING**: Before proceeding, you need to make your own security risk analysis. You will be storing presumably configuration files
 with sensitive data in a (hopefully private, self-hosted) git repository. It is important that you understand what that means. Access to the repository data may give an intruder an easier life to hack into your system(s).

## Concepts

It is tempting to create a git repository at the root of your production server; but it would be a very risky strategy. The
pattern proposed by `osconfig` is for each machine you want to put under versioning:

  1. create a git archive (presumably private on a self-hosted instance);
  2. create a dedicate folder on the target machine (say `/config`);
  3. create a script to help you copy over the relevant configuration files in `/config/bin/collect_files.sh`;
  4. create a manifest file `/config/data/.manifest` listing all files that should be included;
  5. use the script to copy over the relevant configuration files in `/config/data`;
  6. put the `/config/data` folder under `git`;
  7. every time you add a configuration file to be tracked, add it to the manifest file (yes, it does require a disciplined sysadmin);
  8. if you have added a file, or changed a tracked file, run the script;
  9. the script will bring to `/config/data` the configuration files, create a tarball (so that you also have a record of the
     ownership and permissions and you can use it to redeploy the files in a controlled manner);
  10. use standard `git` commands (`git add . `, `git commit`, `git push`) in the `/config/data` repository.

> :warning: **TIP**: If you do not want to be installing git on all machines you need to maintain, you could consider mounting after step 9 the relevant folder (e.g. via `SSHFS`) on a machine where you already have git installed. This might require some investigation to verify that git works well over network mounted volumes.

## Installing on a new machine

To put configuration files of a new machine under version control, do the following steps:

``` bash
$ mkdir -p /config/data
$ touch /config/data/.gitignore
$ touch /config/data/.manifest
$ touch /config/data/README.md
$ git clone https://github.com/EpicureanDigitalEngineer/osconfig.git /config/bin
$ cd /config/data ; git init
$ git remote add origin https://yourgitserver/yourusers/yourgitrepository.git
```

## Running after your configuration changes

Update the manifest of configuration files you want to backup: introduce one file per line, using relative paths from `/` (no absolute paths to avoid `tar` warnings) :

``` bash
etc/rc.conf
etc/hosts
etc/resolv.conf
```

Run the script to bring the files over:

``` bash
$ cd /config/data
$ sh /config/bin/collect_files.sh
```

If all goes well, your configuration files are now in `/config/data`.

You may now follow your usual way to maintain the repository in `git`.


``` bash
$ cd /config/data
$ git add .
$ git commit -m 'New files and/or changes'
$ git push origin master
```

## References

- ideas: https://github.com/vastlimits/OS-Conf-Backup-Linux/


