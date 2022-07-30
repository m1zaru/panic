#!/bin/bash

if [ $EUID -ne 0 ]; then echo "i need perms bro wtf"; exit 1; fi
which cryptsetup >/dev/null; if [[ $? -eq 0 ]]; then echo "cryptsetup already on the machine"; else apt-get install cryptsetup; fi

partsname=$(lsblk | tail -n2 | awk '{print $1}')
for i in $partsname; do
	echo "encrypting /dev/$i..."
	cryptsetup luksFormat --hash=sha512 --key-size=512 --cipher=aes-xts-plain64 --verify-passphrase /dev/$i #AES-XTS ;)
	echo "unlocking /dev/$i..."
	cryptsetup luksOpen /dev/$i /dev/mapper/crypt_$i
	echo "ADDING THESES 0s TO DA FUCKING DRIVE (may take some times, especially if da fucking drive is large)"
	dd if=/dev/zero of=/dev/mapper/crypt_$i status=progress
	echo "creating ext4 fs"
	mkfs.ext4 /dev/mapper/crypt_$i
	cryptsetup luksClose crypt_$i
	echo "/dev/$i encrypted bro, u just have to mount it now"
done

