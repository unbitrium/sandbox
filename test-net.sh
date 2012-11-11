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
sandbox_cleanup() {
	# $1 = sandbox temp directory
	# $2 = Sandbox PID
	iptables -t nat -D POSTROUTING -s 100.64.0.0/32 -j MASQUERADE
}
sandbox_network() {
	# $1 = sandbox temp directory
	# $2 = Sandbox PID
	echo NETWORK $1 $2
	ip link add name sandbox$$ type veth peer name uplink
	ip link set uplink netns $2
	
	ifconfig sandbox$$ 169.255.255.255/32 up
	ip -6 addr add fe80::/128 dev sandbox$$
	ip route add 100.64.0.0/32 dev sandbox$$
	echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
	echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
	ip -6 route add 2001:470:6936:fffe::10/128 dev sandbox$$
	iptables -t nat -A POSTROUTING -s 100.64.0.0/32 -j MASQUERADE
}

run_environment()
{
	mount -n -t proc proc /proc
	sleep 1
	ifconfig uplink 100.64.0.0/32 up
	ip route add 169.255.255.255/32 dev uplink
	ip -6 addr add 2001:470:6936:fffe::10/128 dev uplink
	ip route add default via 169.255.255.255
	ip -6 route add default via fe80:: dev uplink
	
	echo "+++++SANDBOX INIT+++++"
	bash
	echo "+++++SANDBOX TERM+++++"
}

