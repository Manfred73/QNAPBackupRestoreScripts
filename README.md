# QNAP Backup & Restore Scripts

This repository contains some generic scripts which can be used for backing up and restoring config data for several applications, mostly for docker based config folders, but it can also be used for non docker config applications.
The following applications that I have running in docker are included:

* bazarr
* deluge
* hydra2
* jackett
* lidarr
* organizr
* overseerr
* plex
* prowlarr
* radarr
* sabnzbd
* sonarr
* spotweb
* tautulli
* whisparr
* homes directory of a specific user
* homes directory of the root user

The script can be easily changed to add more applications like SickBeard or SickChill. The only file that needs to be changed is the `appConfig.sh` file which contains all the data/locations for the specific applications to backup and restore.

## The scripts

### appConfig.sh
Contains all the data/locations for the specific applications to backup and restore. It should only be necessary to customize this script. The file is self-explanatory and describes what needs to be changed if you want to add a new application. It is possible to specify for each application which files and/or directories to backup and it also offers the possibilty to exclude certain files and/or directories from the backup.

### backup.sh
This is the backup script. It uses the `appConfig.sh` and `functions.sh` as input.
The script takes one mandatory application id as input and creates a backup of all the files/directories specified in the `appConfig.sh` for the specific application id. The result is stored as a `tar.gz` file with a filename consisting of the application id and a timestamp, e.g. `radarr-20200925212759.tar.gz.` All files within the `tar.gz` file are stored with absolute paths, so the restore script can extract them in the same exact location.
A backup for a specific application can either be done by running the `backup.sh` script manually from an ssh session or it can be scheduled as a crontab entry, for example:

`5 8 * * 7 /share/homes/someuser/scripts/backup_and_restore/backup.sh radarr >>/share/homes/someuser/scripts/backup_radarr.log 2>&1`

runs a backup for the radarr application every sunday at 08:05 and writes the result to the specified log file.

For more information on how to do add entries to the contrab on QNAP, see: https://wiki.qnap.com/wiki/Add_items_to_crontab.

In general, this script doesn't have to be changed.

#### Example:
```
./backup.sh radarr
```

### restore.sh
This is the restore script. It uses the `appConfig.sh` and `functions.sh` as input.
The script takes one mandatory application id (the application to restore) as input and finds the most recent backup file for that application. If you want to restore a specific version, you can add a date/time string as the second argument in the format of `YYYYMMDDHHMMSS`. In general, this script doesn't have to be changed.

Example 1:
```
./restore.sh radarr
```
Example 2:
```
./restore.sh radarr 20200925212759
```

### functions.sh
This script contains all the main logic used by the backup and restore scripts and uses `appConfig.sh` as input. In general, this script doesn't have be changed.

## How to use
* Just copy these 4 scripts to your QNAP, e.g. to `/share/homes/<your_user_name>/scripts/backup_and_restore/`.
* Recursively change the owner of the `backup_and_restore` directory and files: `chown -R <your_user_name>:users backup_and_restore`.
* Recursively change permissions of the `backup_and_restore` directory and files to 0755: `chmod -R 755 backup_and_restore`.
* In `appConfig.sh` change the following:
  * <your_user_name> with the name of your own homes folder
  * <YOUR_USER_NAME> with the name of your own homes folder (in capitals)
