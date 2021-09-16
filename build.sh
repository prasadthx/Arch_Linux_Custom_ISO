#!bin/bash

#===========================================
#Defining Variables
#===========================================

LOCALE="en_IN"

KEYMAP="in"

KEYMOD="pc104"

USERNAME="arch"

PASSWORD="arch"

ROOTPASSWORD="root"

HOSTNAME="ArchLinux"

#Functions

checkRoot () {
    if [[ "$EUID" == 0 ]]; then
        continue
    else
        echo "Run the file as root !"
        sleep 2
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
    sleep 2
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

removeAutomaticLogin () {
    [[ -d ./ArchReleng/airootfs/etc/systemd/system/getty@tty1.service.d ]] && rm -r ./ArchReleng/airootfs/etc/systemd/system/getty@tty1.service.d
}

addSLinks () {
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/bluetooth.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/bluetooth.target.wants
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/network-online.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/network-online.target.wants
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/multi-user.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/multi-user.target.wants
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/printer.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/printer.target.wants
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/sockets.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/sockets.target.wants
    [[ ! -d ./ArchReleng/airootfs/etc/systemd/system/timers.target.wants ]] && mkdir -p ./ArchReleng/airootfs/etc/systemd/system/timers.target.wants
    ln -sf /usr/lib/systemd/system/bluetooth.service ./ArchReleng/airootfs/etc/systemd/system/bluetooth.target.wants/bluetooth.service
    ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service ./ArchReleng/airootfs/etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service
    ln -sf /usr/lib/systemd/system/NetworkManager.service ./ArchReleng/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service
    ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service ./ArchReleng/airootfs/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    ln -sf /usr/lib/systemd/system/sddm.service ./ArchReleng/airootfs/etc/systemd/system/display-manager.service
    ln -sf /usr/lib/systemd/system/haveged.service ./ArchReleng/airootfs/etc/systemd/system/sysinit.target.wants/haveged.service
    ln -sf /usr/lib/systemd/system/cups.service ./ArchReleng/airootfs/etc/systemd/system/printer.target.wants/cups.service
    ln -sf /usr/lib/systemd/system/cups.socket ./ArchReleng/airootfs/etc/systemd/system/sockets.target.wants/cups.socket
    ln -sf /usr/lib/systemd/system/cups.path ./ArchReleng/airootfs/etc/systemd/system/multi-user.target.wants/cups.path
    ln -sf /usr/lib/systemd/system/pamac-cleancache.timer ./ArchReleng/airootfs/etc/systemd/system/timers.target.wants/pamac-cleancache.timer
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
    "${USERNAME}":x:1000:1000::/home/"${USERNAME}":/bin/zsh" > ./ArchReleng/airootfs/etc/passwd
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
    "${USERNAME}":x:1000:" > ./ArchReleng/airootfs/etc/group
}

createShadow () {
userPasswordHash=$(openssl passwd -6 "${PASSWORD}")
rootPasswordHash=$(openssl passwd -6 "${ROOTPASSWORD}")
echo "root:"${rootPasswordHash}":14871::::::
"${MYUSERNM}":"${userPasswordHash}":14871::::::" > ./ArchReleng/airootfs/etc/shadow
}

createGShadow () {
echo "root:!*::root
"${USERNAME}":!*::" > ./ArchReleng/airootfs/etc/gshadow
}

setKeyLayout () {
    echo "KEYMAP="${KEYMAP}"" > ./ArchReleng/airootfs/etc/vconsole.conf
}

createKeyboard () {
mkdir -p ./ezreleng/airootfs/etc/X11/xorg.conf.d
echo "Section \"InputClass\"
        Identifier \"system-keyboard\"
        MatchIsKeyboard \"on\"
        Option \"XkbLayout\" \""${KEYMAP}"\"
        Option \"XkbVariant\" \""${KEYMOD}"\"
EndSection" > ./ArchReleng/airootfs/etc/X11/xorg.conf.d/00-keyboard.conf
}

# Fix 40-locale-gen.hook and create locale.conf
crtlocalec () {
sed -i "s/en_US/"${LCLST}"/g" ./ezreleng/airootfs/etc/pacman.d/hooks/40-locale-gen.hook
echo "LANG="${LCLST}".UTF-8" > ./ezreleng/airootfs/etc/locale.conf
}

runMkArchIso () {
    mkarchiso -v -w ./work -o ./out ./ArchReleng
}


#Run The Functions

checkRoot

errorHandle

prerequisites

copyArchReleng

copyXcalibRepo

copyCustomFiles

setHostName

createPasswordFile

createGroupFile

setKeyLayout

runMkArchIso

removeXcalibRepo


