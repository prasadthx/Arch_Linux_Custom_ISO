#!bin/bash

#===========================================
#Defining Variables
#===========================================

LOCALE="en_IN"

KEYMAP="uk"

USERNAME="arch"

PASSWORD="arch"

HOSTNAME="ArchLinux"

#Functions

checkRoot () {
    if [[ "$EUID" == 0 ]]; then
        continue
    else
        echo "Run the file as root !"
        sleep 3
        exit
    fi        
}

errorHandle () {
    clear
    set -uo pipefail
    trap 'Status Code=$?; echo "${0}: Error on line "${LINENO}: ${BASH_COMMAND}"; exit $s' ERR
}

cleanup () {
    [[ -d ./ArchReleng ]] && rm -r ./ArchReleng
    [[ -d ./work ]] && rm -r ./work 
    [[ -d ./out ]] && mv ./out ../
    sleep
}

prerequisites () {
    pacman -S --noconfirm archlinux-keyring
    pacman -S --needed --noconfirm archiso mkinitcpio-archiso
}

copyArchReleng () {
    cp -r /usr/share/archiso/configs/releng ./ArchReleng
    rm -r ./ArchReleng/efiboot
    rm -r ./ezreleng/syslinux
}

copyXcalibRepo () {
    cp -r ./opt/xcalibrepo /opt/
}

removeXcalibRepo () {
    rm -r /opt/xcalibrepo
}

copyCustomFiles () {
    cp packages.x86_64 ./ArchReleng
    cp pacman.conf ./ArchReleng
    cp profiledef.sh ./ArchReleng
    cp -r efiboot ./ArchReleng
    cp -r syslinux ./ArchReleng
    cp -r usr ./ArchReleng/airootfs
    cp -r etc ./ArchReleng/airootfs
    cp -r opt ./ArchReleng/airootfs
}

setHostName () {
    echo "${HOSTNAME}" > ./ArchReleng/airootfs/etc/hostname
}

createPasswordFile () {
    echo "root:x:0:0:root:/root:/usr/bin/zsh
    "${USERNAME}":x:1010:1010::/home/"${USERNAME}":/bin/zsh" > ./ArchReleng/airootfs/etc/passwd
}

createGroupFile () {
    echo "root:x:0:root
    sys:x:3:"${USERNAME}"
    adm:x:4:"${USERNAME}"
    wheel:x:10:"${USERNAME}"
    log:x:19:"${USERNAME}"
    network:x:90:"${USERNAME}"
    floppy:x:94:"${USERNAME}"
    scanner:x:96:"${USERNAME}"
    power:x:98:"${USERNAME}"
    rfkill:x:850:"${USERNAME}"
    users:x:985:"${USERNAME}"
    video:x:860:"${USERNAME}"
    storage:x:870:"${USERNAME}"
    optical:x:880:"${USERNAME}"
    lp:x:840:"${USERNAME}"
    audio:x:890:"${USERNAME}"
    "${USERNAME}":x:1010:" > ./ArchReleng/airootfs/etc/group
}

setLayout () {
    echo "KEYMAP="${KEYMAP}"" > ./ArchReleng/airootfs/etc/vconsole.conf
}

runMkArchIso () {
    mkarchiso -v -w ./work -o ./out ./ArchReleng
}