sandbox_mounts() {
	# $1 = target path
	mount -n --bind /chroot $1/
	mount -n --bind /dev $1/dev
	mount -n --bind /dev/pts $1/dev/pts
	mount -n -t proc proc $1/proc
	mount -n -t sysfs sysfs $1/sys
	mount -n -t tmpfs temp$$ $1/tmp
	export SANDBOX_TMP="/mnt"
}
sandbox_network() {
	# $1 = sandbox temp directory
	# $2 = Sandbox PID
	sleep 1
}
sandbox_cleanup() {
	# $1 = sandbox temp directory
	# $2 = Sandbox PID
	sleep 1
}
run_environment()
{
	echo "+++++SANDBOX INIT+++++"
	ls /
	cat /proc/mounts
	ifconfig -a
	bash
	echo "+++++SANDBOX TERM+++++"
}
