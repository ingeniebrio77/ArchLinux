# BackUps mit Borg
Archlinux:
    sudo pacman -S borg
auf Client und Server Installieren

### Config
    
    borg init -e none||repokey||keyfile user@server-ip:/home/user/path
    borg create --progress --stats user@server-ip:/home/user/path::irgendein-name /folder/to/backup/

### Quellen

[link1]: https://www.howtoforge.com/append-only-backups-with-borg-to-another-vps-or-dedicated-server/
[link2]: https://it-notes.dragas.net/2020/06/30/searching-for-a-perfect-backup-solution-borg-and-restic/
[link3]: https://gp2mv3.com/easy-backups-with-borg/
[link4]: https://bitschieber.com/2022/01/07/einfache-und-sichere-backups-mit-borg-backup/
[link5]: https://color-of-code.de/backup/borg
[link6]: https://thomas-leister.de/server-backups-mit-borg/
[link7]: https://jstaf.github.io/2018/03/12/backups-with-borg-rsync.html
[link8]: https://wiki.ubuntuusers.de/BorgBackup/
[link9]: https://linuxconfig.org/introduction-to-borg-backup
[link10]: https://ostechnix.com/backup-restore-files-borg-linux/
