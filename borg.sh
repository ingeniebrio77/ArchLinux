    #!/bin/bash
    PATH="/usr/local/jdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/pkg/bin:/usr/pkg/sbin"
    export PATH
    server=172.30.120.13
    export server
   # STATE=`upower -i /org/freedesktop/UPower/devices/battery_BAT0|grep state|grep discharging`
   # export STATE
   # if [[ $STATE == *'discharging'* ]]; then
   #        exit
   # fi
   # if nc -w 10 -z $server 22 2>/dev/null; then
   # echo "$server ✓";
   # else
   # echo "$server ✗";
   #        exit;
   # fi
    if mkdir /tmp/backuphappening; then
      echo "Locking succeeded" >&2
    else
      echo "Lock failed - exit" >&2
      exit 1
    fi
    exec > /tmp/borg_backup_log
    exec 2>&1
    date;
    /usr/local/share/urbackup/dattobd_create_filesystem_snapshot 1 /
    REPOSITORY=renato@$server:/home/renato/Downloads
    TAG=daily
    ionice -c3 borg create -v --progress --compression zlib --stats                          \
        $REPOSITORY::$TAG'-{now:%Y-%m-%dT%H:%M:%S}'          \
        /mnt/urbackup_snaps/ /boot /boot/efi                                       \
        --exclude '*.cache*'                  \
        --exclude '*/home/*/.cache*'                  \
        --exclude '*/home/*/Scaricati*'                  \
        --exclude '*.datto*'                  \
        --exclude '*.overlay*'                  \
        --exclude '*.crdownload'                  \
        --exclude '*.rpm'                  \
        --exclude '*.deb'                  \
        --exclude '*swapfile*'                  \
        --exclude '*/home/*/Virtualbox VMs*'          \
        --exclude '*/home/*/VirtualBox VMs*'          \
        --exclude '*/home/*/.vagrant.d*'              \
        --exclude '*/root/.cache*'                    \
        --exclude '*/var/lib/docker*'                    \
        --exclude '*/tmp'
    /usr/local/share/urbackup/dattobd_remove_filesystem_snapshot 1 /mnt/urbackup_snaps/1
    borg prune -v $REPOSITORY --stats --prefix $TAG'-' \
        --keep-hourly=12 --keep-daily=60 --keep-weekly=12 --keep-monthly=24
    rm -Rf /tmp/backuphappening
    date;
