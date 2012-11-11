#/sbin/sandbox 
sandbox_mounts() {
	# $1 = target path
	echo MOUNT $1
	mount -n --bind /chroot $1/
	mount -n --bind /dev $1/dev
	mount -n --bind /dev/pts $1/dev/pts
	mount -n -t sysfs sysfs $1/sys
	mount -n -t tmpfs temp$$ $1/tmp
	export SANDBOX_TMP="/mnt"
}

run_environment()
{
	mount -n -t proc proc /proc
	echo "+++++SANDBOX INIT+++++"
	bash
	echo "+++++SANDBOX TERM+++++"
}

