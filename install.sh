#!/bin/bash
# Install: bash <(curl -O http://172.30.120.63:8080/install.sh)
# VirtualBox# VirtualBox# VirtualBox

set -o errexit                      # Falls Error, Script Abbrechen

# Variabel erstellen aus das Ergebniss von Befehl 'lsblk'

DISK=/dev/sda

# Fix IAD network
ip route add default via 172.30.100.20 || :

loadkeys de                         # Tastatur Layout
timedatectl set-ntp true            # Network Time Protocol
# Alles Aushängen
umount /mnt/boot/efi || :
umount /mnt || :
swapoff --all
sleep 2
# Überpruefen ob EFI vorhanden ist, dann "fdisk" Partition Tool ausfueren
if [ -e /sys/firmware/efi ]; then
    fdisk "${DISK}" <<EOF
g
n


+300M
y
t

1
n


+512M
y
t

swap
n



y
w
EOF
    mkfs.fat -F 32 "${DISK}1"
    mkswap "${DISK}2"
    swapon "${DISK}2"
    mkfs.ext4 "${DISK}3" <<<"y"
    mount "${DISK}3" /mnt
    mount --mkdir "${DISK}1" /mnt/boot/efi
# Wenn keine EFI vorhanden ist, dann BIOS Installation ausfuehren
else
    fdisk "${DISK}" <<EOF
o
n
p


+512M
y
t

82
n
p



y
w
EOF
    mkswap "${DISK}1"
    swapon "${DISK}1"
    mkfs.ext4 "${DISK}2" <<<"y"
    mount "${DISK}2" /mnt
fi                                      # Ende Funktion "if"
# Grundlegende Pakette Installieren 
pacstrap /mnt base linux linux-firmware grub efibootmgr lxde virtualbox-guest-utils

# File System Table generieren
genfstab -U /mnt >>/mnt/etc/fstab
# Symbolik Link
ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
# Locales 
echo 'de_DE.UTF-8 UTF-8' >>/mnt/etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >>/mnt/etc/locale.gen
echo 'LANG=de_DE.UTF-8' >>/mnt/etc/locale.conf

# Tastatur Layout
echo 'KEYMAP=de' >>/mnt/etc/vconsole.conf
cat >/mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "de"
EndSection
EOF

# Hostname
echo 'vm' >>/mnt/etc/hostname

# Network Config
cat >/mnt/etc/systemd/network/20-wired.network <<EOF
[Match]
Name=en*                                # Falls andere Netzwerkkarte aus 'ip addr' hier eingeben zum Beispiel Name=et*

[Network]
DHCP=yes
EOF

# Rest der Skript nochmal Schreiben
cat >/mnt/install.sh <<EOF
#!/bin/bash
set -o errexit

hwclock --systohc                       # Zeit Synchronisieren
locale-gen                              # Locales generieren
mkinitcpio -P                           # Create an initial ramdisk environment

# Grub-install
if [ -e /sys/firmware/efi ]; then
    grub-install
else
    grub-install "${DISK}"
fi
grub-mkconfig -o /boot/grub/grub.cfg
# Dienste aktivieren
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable lxdm
systemctl enable vboxservice
# Root ohne Password 
passwd -d root
EOF
chmod +x /mnt/install.sh                # Ausfuerbare Rechte
arch-chroot /mnt /install.sh            # Sich al Root Einlogen und ./install.sh Ausfuehren
rm /mnt/install.sh
echo FINISHED
