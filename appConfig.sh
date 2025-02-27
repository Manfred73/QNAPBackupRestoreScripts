#!/bin/sh

##########################################################################################################################################################
# Global variables
##########################################################################################################################################################
# This script assumes that the CONFIG_LOCATION is the base path
# where all docker configs are located for apps such as deluge, 
# lidarr, sonarr, radarr, etc.
# Change this as applicable for your situation.
#
# The *_FILES_TO_BACKUP variables just refer to the entire docker 
# config location for that specific application, so everything 
# within that folder is backed up for convenience.
#
# For some applications this can create some large backup files.
# If you wish to only backup the most important files, you can 
# do this by specifying specific files or directories, so instead of doing:
#    LIDARR_FILES_TO_BACKUP=("$LIDARR_PATH")
#
# you could also do:
#    LIDARR_FILES_TO_BACKUP=("$LIDARR_PATH/lidarr.db" "$LIDARR_PATH/logs.db" "$LIDARR_PATH/config.xml")
#
# or you can use the base config path for the application like:
#    RADARR_FILES_TO_BACKUP=("$RADARR_PATH")
#
# and then add files or directories for exclusion like:
#    RADARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$RADARR_PATH/MediaCover" "$RADARR_PATH/Backups")
#
# since the MediaCover folder (in radarr, sonarr and lidarr) is very large and these don't 
# neccessarily have to be backed up (they can be restored/redownloaded by doing an update all from
# within the applications.
#
# Also the Backups directory for various applications are stored
# in the base config folders which you might want to exclude from this backup.
#
# Note: always make sure you use the absolute paths for the *_FILES_TO_BACKUP and 
# *_FILES_TO_EXCLUDE_FROM_BACKUP variables by adding the *_PATH variable in front of it.
#
# The backup.sh script creates a tar.gz file which stores the backup files with their absolute paths.
# The restore.sh script can be used to restore a certain backup of an application by extracting the tar.gz. 
#
# To add more applications or remove some:
# - extend the APPS array below with a new prefix (or remove the ones you don't need)
# - add a new section with variables for the new application (or remove the sections that you don't need)
# - add a new entry for the new application to the functions get_backup_path(), get_app_prefix(), get_files_to_backup() 
#   and get_files_to_exclude_from_backup below (or remove the ones that you don't need from these functions)
#
# Array of applications to backup.
APPS=("bazarr" "deluge" "gluetun" "homeassistant" "hydra2" "jackett" "kavita" "lidarr" "lms" "organizr" "overseerr" "petio" "plex" "prowlarr" "qbittorrent" "radarr" "radarr3D" "readarr" "sabnzbd" "sonarr" "spotweb" "spotwebdb" "tautulli" "tdarr" "whisparr" "uptime_kuma" "homes_<user>" "homes_root")

# General location variables for backup & restore
# Change these according to your preferences and available locations/directories
#
CONFIG_LOCATION='/share/shares/docker'
BACKUP_LOCATION="/share/shares/Backup/QNAP/share"
SCRIPTS_LOCATION='/share/shares/homes/<user>/scripts'
HOMES_LOCATION='/share/shares/homes'
HOMES_ROOT_LOCATION='/root'
TMP_FILE_LIST='/tmp/filesToBackup.lst'
TMP_FILE_LIST_TO_EXCLUDE='/tmp/filesToExcludeFromBackup.lst'
CURRENT_DIR=$(pwd)

# Variables for Bazarr backup & restore
#
BAZARR_PATH="$CONFIG_LOCATION/bazarr"
BAZARR_BACKUP_PATH="$BACKUP_LOCATION/docker/bazarr"
BAZARR_PREFIX="bazarr"
BAZARR_FILES_TO_BACKUP=("$BAZARR_PATH")
BAZARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$BAZARR_PATH/backup")

# Variables for Deluge backup & restore
#
DELUGE_PATH="$CONFIG_LOCATION/deluge"
DELUGE_BACKUP_PATH="$BACKUP_LOCATION/docker/deluge"
DELUGE_PREFIX="deluge"
DELUGE_FILES_TO_BACKUP=("$DELUGE_PATH")
DELUGE_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for gluetun backup & restore
#
GLUETUN_PATH="$CONFIG_LOCATION/gluetun"
GLUETUN_BACKUP_PATH="$BACKUP_LOCATION/docker/gluetun"
GLUETUN_PREFIX="gluetun"
GLUETUN_FILES_TO_BACKUP=("$GLUETUN_PATH")
GLUETUN_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Hydra2 backup & restore
#
HOMEASSISTANT_PATH="$CONFIG_LOCATION/homeassistant"
HOMEASSISTANT_BACKUP_PATH="$BACKUP_LOCATION/docker/homeassistant"
HOMEASSISTANT_PREFIX="homeassistant"
HOMEASSISTANT_FILES_TO_BACKUP=("$HOMEASSISTANT_PATH")
HOMEASSISTANT_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Hydra2 backup & restore
#
HYDRA2_PATH="$CONFIG_LOCATION/hydra2"
HYDRA2_BACKUP_PATH="$BACKUP_LOCATION/docker/hydra2"
HYDRA2_PREFIX="hydra2"
HYDRA2_FILES_TO_BACKUP=("$HYDRA2_PATH")
HYDRA2_FILES_TO_EXCLUDE_FROM_BACKUP=("$HYDRA2_PATH/backup" "$HYDRA2_PATH/downloads")

# Variables for Jackett backup & restore
#
JACKETT_PATH="$CONFIG_LOCATION/jackett"
JACKETT_BACKUP_PATH="$BACKUP_LOCATION/docker/jackett"
JACKETT_PREFIX="jackett"
JACKETT_FILES_TO_BACKUP=("$JACKETT_PATH")
JACKETT_FILES_TO_EXCLUDE_FROM_BACKUP=("$JACKETT_PATH/downloads")

# Variables for Kavita backup & restore
#
KAVITA_PATH="$CONFIG_LOCATION/kavita"
KAVITA_BACKUP_PATH="$BACKUP_LOCATION/docker/kavita"
KAVITA_PREFIX="kavita"
KAVITA_FILES_TO_BACKUP=("$KAVITA_PATH")
KAVITA_FILES_TO_EXCLUDE_FROM_BACKUP=("$KAVITA_PATH/Backups" "$KAVITA_PATH/cache" "$KAVITA_PATH/cache" "$KAVITA_PATH/covers" "$KAVITA_PATH/temp")

# Variables for Lidarr backup & restore
#
LIDARR_PATH="$CONFIG_LOCATION/lidarr"
LIDARR_BACKUP_PATH="$BACKUP_LOCATION/docker/lidarr"
LIDARR_PREFIX="lidarr"
LIDARR_FILES_TO_BACKUP=("$LIDARR_PATH")
LIDARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$LIDARR_PATH/Backups" "$LIDARR_PATH/MediaCover")

# Variables for LMS (Logitech Media Server) backup & restore
#
LMS_PATH="$CONFIG_LOCATION/lms"
LMS_BACKUP_PATH="$BACKUP_LOCATION/docker/lms"
LMS_PREFIX="lms"
LMS_FILES_TO_BACKUP=("$LMS_PATH")
LMS_FILES_TO_EXCLUDE_FROM_BACKUP=("$LMS_PATH/cache" "$LMS_PATH/logs")

# Variables for Organizr backup & restore
#
ORGANIZR_PATH="$CONFIG_LOCATION/organizr"
ORGANIZR_BACKUP_PATH="$BACKUP_LOCATION/docker/organizr"
ORGANIZR_PREFIX="organizr"
ORGANIZR_FILES_TO_BACKUP=("$ORGANIZR_PATH")
ORGANIZR_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Overseerr backup & restore
#
OVERSEERR_PATH="$CONFIG_LOCATION/overseerr"
OVERSEERR_BACKUP_PATH="$BACKUP_LOCATION/docker/overseerr"
OVERSEERR_PREFIX="overseerr"
OVERSEERR_FILES_TO_BACKUP=("$OVERSEERR_PATH")
OVERSEERR_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Petio backup & restore
#
PETIO_PATH="$CONFIG_LOCATION/petio"
PETIO_BACKUP_PATH="$BACKUP_LOCATION/docker/petio"
PETIO_PREFIX="petio"
PETIO_FILES_TO_BACKUP=("$PETIO_PATH")
PETIO_FILES_TO_EXCLUDE_FROM_BACKUP=("$PETIO_PATH/logs")

# Variables for Plex backup & restore
#
PLEX_PATH="$CONFIG_LOCATION/plex"
PLEX_BACKUP_PATH="$BACKUP_LOCATION/docker/plex"
PLEX_PREFIX="plex"
PLEX_FILES_TO_BACKUP=("$PLEX_PATH")
PLEX_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Prowlarr backup & restore
#
PROWLARR_PATH="$CONFIG_LOCATION/prowlarr"
PROWLARR_BACKUP_PATH="$BACKUP_LOCATION/docker/prowlarr"
PROWLARR_PREFIX="prowlarr"
PROWLARR_FILES_TO_BACKUP=("$PROWLARR_PATH")
PROWLARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$PROWLARR_PATH/Backups")

# Variables for qBittorrent backup & restore
#
QBITTORRENT_PATH="$CONFIG_LOCATION/qbittorrent"
QBITTORRENT_BACKUP_PATH="$BACKUP_LOCATION/docker/qbittorrent"
QBITTORRENT_PREFIX="qbittorrent"
QBITTORRENT_FILES_TO_BACKUP=("$QBITTORRENT_PATH")
QBITTORRENT_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Radarr backup & restore
#
RADARR_PATH="$CONFIG_LOCATION/radarr"
RADARR_BACKUP_PATH="$BACKUP_LOCATION/docker/radarr"
RADARR_PREFIX="radarr"
RADARR_FILES_TO_BACKUP=("$RADARR_PATH")
RADARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$RADARR_PATH/Backups" "$RADARR_PATH/MediaCover")

# Variables for Radarr3D backup & restore
#
RADARR3D_PATH="$CONFIG_LOCATION/radarr3D"
RADARR3D_BACKUP_PATH="$BACKUP_LOCATION/docker/radarr3D"
RADARR3D_PREFIX="radarr3D"
RADARR3D_FILES_TO_BACKUP=("$RADARR3D_PATH")
RADARR3D_FILES_TO_EXCLUDE_FROM_BACKUP=("$RADARR3D_PATH/Backups" "$RADARR3D_PATH/MediaCover")

# Variables for Readarr backup & restore
#
READARR_PATH="$CONFIG_LOCATION/readarr"
READARR_BACKUP_PATH="$BACKUP_LOCATION/docker/readarr"
READARR_PREFIX="readarr"
READARR_FILES_TO_BACKUP=("$READARR_PATH")
READARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$READARR_PATH/Backups")

# Variables for Sabnzb backup & restore
#
SABNZBD_PATH="$CONFIG_LOCATION/sabnzbd"
SABNZBD_BACKUP_PATH="$BACKUP_LOCATION/docker/sabnzbd"
SABNZBD_PREFIX="sabnzbd"
SABNZBD_FILES_TO_BACKUP=("$SABNZBD_PATH")
SABNZBD_FILES_TO_EXCLUDE_FROM_BACKUP=("$SABNZBD_PATH/Downloads")

# Variables for Sonarr backup & restore
#
SONARR_PATH="$CONFIG_LOCATION/sonarr"
SONARR_BACKUP_PATH="$BACKUP_LOCATION/docker/sonarr"
SONARR_PREFIX="sonarr"
SONARR_FILES_TO_BACKUP=("$SONARR_PATH")
SONARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$SONARR_PATH/Backups" "$SONARR_PATH/MediaCover")

# Variables for Spotweb backup & restore
#
SPOTWEB_PATH="$CONFIG_LOCATION/spotweb"
SPOTWEB_BACKUP_PATH="$BACKUP_LOCATION/docker/spotweb"
SPOTWEB_PREFIX="spotweb"
SPOTWEB_FILES_TO_BACKUP=("$SPOTWEB_PATH")
SPOTWEB_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for SpotwebDB backup & restore
#
SPOTWEBDB_PATH="$CONFIG_LOCATION/spotwebdb"
SPOTWEBDB_BACKUP_PATH="$BACKUP_LOCATION/docker/spotwebdb"
SPOTWEBDB_PREFIX="spotwebdb"
SPOTWEBDB_FILES_TO_BACKUP=("$SPOTWEBDB_PATH")
SPOTWEBDB_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Tautulli backup & restore
#
TAUTULLI_PATH="$CONFIG_LOCATION/tautulli"
TAUTULLI_BACKUP_PATH="$BACKUP_LOCATION/docker/tautulli"
TAUTULLI_PREFIX="tautulli"
TAUTULLI_FILES_TO_BACKUP=("$TAUTULLI_PATH")
TAUTULLI_FILES_TO_EXCLUDE_FROM_BACKUP=("$TAUTULLI_PATH/backups" "$TAUTULLI_PATH/cache")

# Variables for Tautulli backup & restore
#
TDARR_PATH="$CONFIG_LOCATION/tdarr"
TDARR_BACKUP_PATH="$BACKUP_LOCATION/docker/tdarr"
TDARR_PREFIX="tdarr"
TDARR_FILES_TO_BACKUP=("$TDARR_PATH")
TDARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$TDARR_PATH/server/pgid" "$TDARR_PATH/server/puid" "$TDARR_PATH/server/Tdarr/Backups" "$TDARR_PATH/server/Tdarr/Logs" "$TDARR_PATH/server/Tdarr/Samples" "$TDARR_PATH/logs" "$TDARR_PATH/transcode_cache")

# Variables for Whisparr backup & restore
#
UPTIME_KUMA_PATH="$CONFIG_LOCATION/uptime-kuma"
UPTIME_KUMA_BACKUP_PATH="$BACKUP_LOCATION/docker/uptime-kuma"
UPTIME_KUMA_PREFIX="uptime-kuma"
UPTIME_KUMA_FILES_TO_BACKUP=("$UPTIME_KUMA_PATH")
UPTIME_KUMA_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for Whisparr backup & restore
#
WHISPARR_PATH="$CONFIG_LOCATION/whisparr"
WHISPARR_BACKUP_PATH="$BACKUP_LOCATION/docker/whisparr"
WHISPARR_PREFIX="whisparr"
WHISPARR_FILES_TO_BACKUP=("$WHISPARR_PATH")
WHISPARR_FILES_TO_EXCLUDE_FROM_BACKUP=("$WHISPARR_PATH/Backups" "$WHISPARR_PATH/MediaCover")

# Variables for HOME_USER backup & restore
#
HOMES_PATH_<USERNAME>="$HOMES_LOCATION/<user>"
HOMES_<USERNAME>_BACKUP_PATH="$BACKUP_LOCATION/homes/<user>"
HOMES_<USERNAME>_PREFIX="<user>"
HOMES_<USERNAME>_FILES_TO_BACKUP=("$HOMES_PATH_<USERNAME>")
HOMES_<USERNAME>_FILES_TO_EXCLUDE_FROM_BACKUP=("")

# Variables for HOMES_ROOT backup & restore
#
HOMES_ROOT_BACKUP_PATH="$BACKUP_LOCATION/homes/root"
HOMES_ROOT_PREFIX="root"
HOMES_ROOT_FILES_TO_BACKUP=("$HOMES_ROOT_LOCATION")
HOMES_ROOT_FILES_TO_EXCLUDE_FROM_BACKUP=("")

##########################################################################################################################################################
# Function to return the application backup path based on the provided appication configuration parameter.
#
# Arguments: $1 the application configuration to return the application backup path for
##########################################################################################################################################################
function get_backup_path() {
    case $1 in
        "bazarr") echo "$BAZARR_BACKUP_PATH" ;;
        "deluge") echo "$DELUGE_BACKUP_PATH" ;;
        "gluetun") echo "$GLUETUN_BACKUP_PATH" ;;
        "homeassistant") echo "$HOMEASSISTANT_BACKUP_PATH" ;;
        "hydra2") echo "$HYDRA2_BACKUP_PATH" ;;
        "jackett") echo "$JACKETT_BACKUP_PATH" ;;
        "kavita") echo "$KAVITA_BACKUP_PATH" ;;
        "lidarr") echo "$LIDARR_BACKUP_PATH" ;;
        "lms") echo "$LMS_BACKUP_PATH" ;;
        "organizr") echo "$ORGANIZR_BACKUP_PATH" ;;
        "overseerr") echo "$OVERSEERR_BACKUP_PATH" ;;
        "petio") echo "$PETIO_BACKUP_PATH" ;;
        "plex") echo "$PLEX_BACKUP_PATH" ;;
        "prowlarr") echo "$PROWLARR_BACKUP_PATH" ;;
        "qbittorrent") echo "$QBITTORRENT_BACKUP_PATH" ;;
        "radarr") echo "$RADARR_BACKUP_PATH" ;;
        "radarr3D") echo "$RADARR3D_BACKUP_PATH" ;;
        "readarr") echo "$READARR_BACKUP_PATH" ;;
        "sabnzbd") echo "$SABNZBD_BACKUP_PATH" ;;
        "sonarr") echo "$SONARR_BACKUP_PATH" ;;
        "spotweb") echo "$SPOTWEB_BACKUP_PATH" ;;
        "spotwebdb") echo "$SPOTWEBDB_BACKUP_PATH" ;;
        "tdarr") echo "$TDARR_BACKUP_PATH" ;;
        "tautulli") echo "$TAUTULLI_BACKUP_PATH" ;;
        "uptime_kuma") echo "$UPTIME_KUMA_BACKUP_PATH" ;;
        "whisparr") echo "$WHISPARR_BACKUP_PATH" ;;
        "homes_<user>") echo "$HOMES_<USERNAME>_BACKUP_PATH" ;;
        "homes_root") echo "$HOMES_ROOT_BACKUP_PATH" ;;
        *) exit 1 ;;
    esac
}

##########################################################################################################################################################
# Function to return the application prefix based on the provided appication configuration parameter.
#
# Arguments: $1 the application configuration to return the application backup path for
##########################################################################################################################################################
function get_app_prefix() {
    case $1 in
        "bazarr") echo "$BAZARR_PREFIX" ;;
        "deluge") echo "$DELUGE_PREFIX" ;;
        "gluetun") echo "$GLUETUN_PREFIX" ;;
        "homeassistant") echo "$HOMEASSISTANT_PREFIX" ;;
        "hydra2") echo "$HYDRA2_PREFIX" ;;
        "jackett") echo "$JACKETT_PREFIX" ;;
        "kavita") echo "$KAVITA_PREFIX" ;;
        "lidarr") echo "$LIDARR_PREFIX" ;;
        "lms") echo "$LMS_PREFIX" ;;
        "organizr") echo "$ORGANIZR_PREFIX" ;;
        "overseerr") echo "$OVERSEERR_PREFIX" ;;
        "petio") echo "$PETIO_PREFIX" ;;
        "plex") echo "$PLEX_PREFIX" ;;
        "prowlarr") echo "$PROWLARR_PREFIX" ;;
        "qbittorrent") echo "$QBITTORRENT_PREFIX" ;;
        "radarr") echo "$RADARR_PREFIX" ;;
        "radarr3D") echo "$RADARR3D_PREFIX" ;;
        "readarr") echo "$READARR_PREFIX" ;;
        "sabnzbd") echo "$SABNZBD_PREFIX" ;;
        "sonarr") echo "$SONARR_PREFIX" ;;
        "spotweb") echo "$SPOTWEB_PREFIX" ;;
        "spotwebdb") echo "$SPOTWEBDB_PREFIX" ;;
        "tdarr") echo "$TDARR_PREFIX" ;;
        "tautulli") echo "$TAUTULLI_PREFIX" ;;
        "uptime_kuma") echo "$UPTIME_KUMA_PREFIX" ;;
        "whisparr") echo "$WHISPARR_PREFIX" ;;
        "homes_<user>") echo "$HOMES_<USERNAME>_PREFIX" ;;
        "homes_root") echo "$HOMES_ROOT_PREFIX" ;;
        *) exit 1 ;;
    esac
}

##########################################################################################################################################################
# Function to return the files to backup based on the provided appLication configuration parameter.
#
# Arguments: $1 the application configuration to return the files to backup for
##########################################################################################################################################################
function get_files_to_backup() {
    case $1 in
        "bazarr") create_files_to_backup "${BAZARR_FILES_TO_BACKUP[@]}" ;;
        "deluge") create_files_to_backup "${DELUGE_FILES_TO_BACKUP[@]}" ;;
        "gluetun") create_files_to_backup "${GLUETUN_FILES_TO_BACKUP[@]}" ;;
        "homeassistant") create_files_to_backup "${HOMEASSISTANT_FILES_TO_BACKUP[@]}" ;;
        "hydra2") create_files_to_backup "${HYDRA2_FILES_TO_BACKUP[@]}" ;;
        "jackett") create_files_to_backup "${JACKETT_FILES_TO_BACKUP[@]}" ;;
        "kavita") create_files_to_backup "${KAVITA_FILES_TO_BACKUP[@]}" ;;
        "lidarr") create_files_to_backup "${LIDARR_FILES_TO_BACKUP[@]}" ;;
        "lms") create_files_to_backup "${LMS_FILES_TO_BACKUP[@]}" ;;
        "organizr") create_files_to_backup "${ORGANIZR_FILES_TO_BACKUP[@]}" ;;
        "overseerr") create_files_to_backup "${OVERSEERR_FILES_TO_BACKUP[@]}" ;;
        "petio") create_files_to_backup "${PETIO_FILES_TO_BACKUP[@]}" ;;
        "plex") create_files_to_backup "${PLEX_FILES_TO_BACKUP[@]}" ;;
        "prowlarr") create_files_to_backup "${PROWLARR_FILES_TO_BACKUP[@]}" ;;
        "qbittorrent") create_files_to_backup "${QBITTORRENT_FILES_TO_BACKUP[@]}" ;;
        "radarr") create_files_to_backup "${RADARR_FILES_TO_BACKUP[@]}" ;;
        "radarr3D") create_files_to_backup "${RADARR3D_FILES_TO_BACKUP[@]}" ;;
        "readarr") create_files_to_backup "${READARR_FILES_TO_BACKUP[@]}" ;;
        "sabnzbd") create_files_to_backup "${SABNZBD_FILES_TO_BACKUP[@]}" ;;
        "sonarr") create_files_to_backup "${SONARR_FILES_TO_BACKUP[@]}" ;;
        "spotweb") create_files_to_backup "${SPOTWEB_FILES_TO_BACKUP[@]}" ;;
        "spotwebdb") create_files_to_backup "${SPOTWEBDB_FILES_TO_BACKUP[@]}" ;;
        "tdarr") create_files_to_backup create_files_to_backup "${TDARR_FILES_TO_BACKUP[@]}" ;;
        "tautulli") create_files_to_backup create_files_to_backup "${TAUTULLI_FILES_TO_BACKUP[@]}" ;;
        "uptime_kuma") create_files_to_backup create_files_to_backup "${UPTIME_KUMA_FILES_TO_BACKUP[@]}" ;;
        "whisparr") create_files_to_backup create_files_to_backup "${WHISPARR_FILES_TO_BACKUP[@]}" ;;
        "homes_<user>") create_files_to_backup "${HOMES_<USERNAME>_FILES_TO_BACKUP[@]}" ;;
        "homes_root") create_files_to_backup "${HOMES_ROOT_FILES_TO_BACKUP[@]}" ;;
        *) exit 1 ;;
    esac
}

##########################################################################################################################################################
# Function to return the files to exclude from the backup based on the provided appLication configuration parameter.
#
# Arguments: $1 the application configuration to return the files to backup for
##########################################################################################################################################################
function get_files_to_exclude_from_backup() {
    case $1 in
        "bazarr") create_files_to_exclude_from_backup "${BAZARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "deluge") create_files_to_exclude_from_backup "${DELUGE_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "gluetun") create_files_to_exclude_from_backup "${GLUETUN_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "homeassistant") create_files_to_exclude_from_backup "${HOMEASSISTANT_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "hydra2") create_files_to_exclude_from_backup "${HYDRA2_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "jackett") create_files_to_exclude_from_backup "${JACKETT_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "kavita") create_files_to_exclude_from_backup "${KAVITA_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "lidarr") create_files_to_exclude_from_backup "${LIDARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "lms") create_files_to_exclude_from_backup "${LMS_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "organizr") create_files_to_exclude_from_backup "${ORGANIZR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "overseerr") create_files_to_exclude_from_backup "${OVERSEERR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "petio") create_files_to_exclude_from_backup "${PETIO_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "plex") create_files_to_exclude_from_backup "${PLEX_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "prowlarr") create_files_to_exclude_from_backup "${PROWLARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "qbittorrent") create_files_to_exclude_from_backup "${QBITTORRENT_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "radarr") create_files_to_exclude_from_backup "${RADARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "radarr3D") create_files_to_exclude_from_backup "${RADARR3D_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "readarr") create_files_to_exclude_from_backup "${READARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "sabnzbd") create_files_to_exclude_from_backup "${SABNZBD_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "sonarr") create_files_to_exclude_from_backup "${SONARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "spotweb") create_files_to_exclude_from_backup "${SPOTWEB_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "spotwebdb") create_files_to_exclude_from_backup "${SPOTWEBDB_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "tdarr") create_files_to_exclude_from_backup "${TDARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "tautulli") create_files_to_exclude_from_backup "${TAUTULLI_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "uptime_kuma") create_files_to_exclude_from_backup "${UPTIME_KUMA_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "whisparr") create_files_to_exclude_from_backup "${WHISPARR_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "homes_<user>") create_files_to_exclude_from_backup "${HOMES_<USERNAME>_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        "homes_root") create_files_to_exclude_from_backup "${HOMES_ROOT_FILES_TO_EXCLUDE_FROM_BACKUP[@]}" ;;
        *) exit 1 ;;
    esac
}
