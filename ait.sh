#!/bin/bash
# Copyright (c) 2012 fbt <fbt@fleshless.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#   - Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#   - Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Arch Linux install tool
# Warning! This script assumes that network has already been configured

### Configuration ###

EDITOR='vim'

cfg_part_file='/tmp/ait_partitions.cfg'
cfg_part_tool='cfdisk'

cfg_bootloader='syslinux'

runtime_pkgs=( 'vim' )
base_pkgs=( 'base' )
extra_pkgs=( 'vim' 'screen' 'openssh' 'syslog-ng' )

syslinux_config='/mnt/boot/syslinux/syslinux.cfg'

### Functions ###

ait.msg() { echo "[ ait ] $1"; }
ait.die() { ait.msg "[ error ] $2"; exit "$1"; }

ait.get_info() {
	read -p 'Choose your timezone [Europe/Moscow]: ' cfg_timezone
	[[ "$cfg_timezone" ]] || { cfg_timezone='Europe/Moscow'; }

	read -p 'Choose your locale [en_US.UTF-8]: ' cfg_locale
	[[ "$cfg_locale" ]] || { cfg_locale='en_US.UTF-8'; }

	read -p 'Choose a hostname [anus]: ' cfg_hostname
	[[ "$cfg_hostname" ]] || { cfg_hostname='anus'; }

	read -n1 -p 'Install base-devel? [Y/n] ' ans
	[[ "$ans" == 'n' ]] || { base_pkgs+=( 'base-devel' ); }
	echo

	read -n1 -p 'Do you want to install openrc side-by-side with systemd? [y/N] ' ans
	[[ "$ans" == 'y' ]] && {
		cfg_openrc='true'
		extra_pkgs+=( 'net-tools' )
	    runtime_pkgs+=( 'git' 'base-devel' )
	}
	echo

	read -n1 -p 'Do you need a bootloader? Only syslinux is supported right now. [Y/n] ' ans
	[[ "$ans" == 'n' ]] || {
		flag_bootloader='1'
		extra_pkgs+=( 'syslinux' )
	}
	echo
}

ait.preinstall() {
	ait.get_info
	[[ "$runtime_pkgs" ]] && { pacman --noconfirm -Sy "${runtime_pkgs[@]}"; }
	ait.pacman_config
}

ait.partition() {
	answer='foo'

	while [[ "$answer" ]]; do
		for i in `find /dev -maxdepth 1 -name 'sd*'`; do
			echo "$i"
		done | sort -h

		read -p "Select a device for partitioning (exit on blank): " answer
		[[ "$answer" ]] && { "$cfg_part_tool" "$answer"; }
	done
}

ait.mountconfig() {
	read -n1 -p "You will now be tasked with selecting mountpoints. Press any key to continue." foo
	"$EDITOR" "$cfg_part_file";
}

ait.mount_all() {
	cat "$cfg_part_file" | grep -vE '^#|^(\s+)?$' | while read line; do
		local device=`echo "$line" | awk '{print $1}'`

		local device_cfg=`echo "$line" | awk '{print $2}'`
		local device_cfg_mountpoint=`echo "$device_cfg" | cut -d ',' -f 1`
		local device_cfg_fstype=`echo "$device_cfg" | cut -d ',' -f 2`
		local device_cfg_mkfs=`echo "$device_cfg" | cut -d ',' -f 3`

		[[ "$device_cfg_mountpoint" == '/' ]] && { echo "$device" | cut -d '/' -f3 > /tmp/rootdevice; }

		case "$device_cfg_fstype" in
			swap)
				mkswap "$device"
			;;

			*)
				[[ "$device_cfg_mkfs" == 'y' ]] && {
					ait.msg "Creating $device_cfg_fstype on $device"
					"mkfs.${device_cfg_fstype}" "$device"
				}
				[[ -d "/mnt${device_cfg_mountpoint}" ]] || { mkdir "/mnt${device_cfg_mountpoint}"; }
				mount "$device" "/mnt${device_cfg_mountpoint}"
			;;
		esac
	done

	root_device=`cat /tmp/rootdevice`
}

ait.pacman_config() {
	read -n1 -p 'Do you want to configure your mirrorlist? It will go into the installed system as well [Y/n]' ans
	[[ "$ans" == 'n' ]] || { "$EDITOR" '/etc/pacman.d/mirrorlist'; }
}

ait.base_install() { pacstrap /mnt "${base_pkgs[@]}" "${extra_pkgs[@]}"; }

ait.booloader_install() {
	local root_device=`cat /tmp/rootdevice`

	case "$cfg_bootloader" in
		grub) ait.die 10 "Can't handle GRUB2 yet, sorry";;
		syslinux)
			local syslinux_config='/mnt/boot/syslinux/syslinux.cfg'

			sed -ir "s/sda3/${root_device}/g" "$syslinux_config"
		;;
	esac
}

ait.genfstab() {
	ait.msg "Generating fstab..."
	genfstab -p /mnt >> /mnt/etc/fstab
}

ait.postinstall() {
	ait.msg "Setting hostname... "
	echo "$cfg_hostname" > /mnt/etc/hostname

	ait.msg "Setting locales... "
	echo -e "LANG=${cfg_locale}\nLC_ALL=${cfg_locale}" > /mnt/etc/locale.conf
	sed -ir "s/#${cfg_locale}/${cfg_locale}/" '/mnt/etc/locale.gen'
	arch-chroot /mnt locale-gen

	ait.msg "Setting timezone... "
	arch-chroot /mnt ln -s "/usr/share/zoneinfo/${cfg_timezone}" /etc/localtime

	ait.msg "Generating initrd image... "
	arch-chroot /mnt mkinitcpio -p linux

	ait.msg "Generating SSH keys... "
	arch-chroot /mnt ssh-keygen -A

	[[ "$flag_bootloader" ]] && {
		ait.msg "Writing MBR..."
		arch-chroot /mnt syslinux-install_update -i -a -m
	}

	[[ "$cfg_openrc" == 'true' ]] && { ait.openrc; }

	read -n1 -p 'Please make sure that the bootloader config is correct. Press any key to continue.'
	"$EDITOR" "$syslinux_config"
}

ait.openrc() {
	local openrc_pkgs=( 'openrc-sysvinit' 'openrc' 'openrc-arch-services-git' )
	export PKGDEST='/mnt/pkg'

	[[ -d "$PKGDEST" ]] || mkdir -p "$PKGDEST"

	for i in ${openrc_pkgs[@]}; do
		curl -skL "https://aur.archlinux.org/packages/${i:0:2}/${i}/${i}.tar.gz" | gzip -d | tar xf -
		cd "$i"
		makepkg -d --asroot
		cd
	done

	openrc_pkgs=( `arch-chroot /mnt find /pkg -type f` )

	arch-chroot /mnt pacman -U "${openrc_pkgs[@]}"

	arch-chroot /mnt ln -s /etc/openrc/init.d/udev /etc/openrc/runlevels/boot/
	arch-chroot /mnt ln -s /etc/openrc/init.d/syslog-ng /etc/openrc/runlevels/boot/
	arch-chroot /mnt ln -s /etc/openrc/init.d /etc/init.d

	echo "hostname=\"$cfg_hostname\"" > '/mnt/etc/openrc/conf.d/hostname'
	sed -i 's/\/run\/systemd\/journal\/syslog/\/dev\/log/' '/mnt/etc/syslog-ng/syslog-ng.conf'

	curl -skL 'zfh.so/arch-syslinux-openrc.patch' | sed -r "s/sda3/${root_device}/" | patch '/mnt/boot/syslinux/syslinux.cfg'
}

ait.umount_all() {
	cat "$cfg_part_file" | grep -vE '^#|^(\s+)?$' | awk '{print $1}' | while read line; do
		umount "$line"
	done
}

### Main part ###

# Preinstall actions
ait.preinstall

# Checking if our chosen editor exists in the system
which "$EDITOR" &>/dev/null || { ait.die 9 "$EDITOR not found in the system"; }

# Example partitioning configuration
cat > "$cfg_part_file" << EOF
# Partitioning config
# device	mountpoint,fs,mkfs

/dev/sda1	swap
/dev/sda2	/,ext4,y
EOF

ait.partition
ait.mountconfig
ait.mount_all
ait.base_install
ait.booloader_install
ait.genfstab
ait.postinstall
ait.umount_all
