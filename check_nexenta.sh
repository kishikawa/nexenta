#!/bin/bash

# Nexenta Zabbix check script
# 2015/11/13

## if [ "$1" == "" ] || [ $2 == "" ] || [ $3 == "" ]

if [ "$1" == "" ] || [ $2 == "" ] 
then
	echo Invalid usage : check_nexenta Nexenta HostName or IPAddress Command
	exit 3
fi

Nexenta=$1
COMMAND=$2
USERNAME=root
TMPDIR=/tmp

CONNECTCOMMAND="ssh $USERNAME@$Nexenta"

if [ $COMMAND == "check_vdev" ]
then
	$CONNECTCOMMAND zpool status -v | egrep raid > $TMPDIR/nexenta_$COMMAND.$Nexenta.out 2>> $TMPDIR/log.out
	if [ $? -gt 0 ]
	then
		echo Could not connect to NexetaStore $Nexenta
		exit 3
	fi

	if [ `grep -c FAULTED $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
	then
		echo CRITICAL! The following VirtualDevice have abnormal status : `egrep -v "ONLINE|AVAIL"  $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
		rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
		exit 2
	else
		if [ `egrep -c "UNAVAIL|DEGRADED" $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
		then	
	        	echo WARNING! The following VirtualDevice have abnormal status : `egrep -v "ONLINE|AVAIL" $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 1
		else
			echo OK : All VirtualDevice have normal status
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 0
		fi
	fi
fi

if [ $COMMAND == "check_physical_disk" ]
then
	$CONNECTCOMMAND zpool status -v | egrep c[0-9] > $TMPDIR/nexenta_$COMMAND.$Nexenta.out 2>> $TMPDIR/log.out
	if [ $? -gt 0 ]
	then
		echo Could not connect to NexetaStore $Nexenta
		exit 3
	fi

	if [ `grep -c FAULTED $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
	then
		echo CRITICAL! The following PhysicalDisks have abnormal status : `egrep -v "ONLINE|AVAIL"  $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
		rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
		exit 2
	else
		if [ `grep -c UNAVAIL $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
		then	
	        	echo WARNING! The following PhysicalDisks have abnormal status : `egrep -v "ONLINE|AVAIL" $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 1
		else
			echo OK : All PhysicalDisks have normal status
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 0
		fi
	fi
fi

if [ $COMMAND == "check_nms" ]
then
	$CONNECTCOMMAND svcs nms|grep nms > $TMPDIR/nexenta_$COMMAND.$Nexenta.out 2>> $TMPDIR/log.out
	if [ $? -gt 0 ]
	then
		echo Could not connect to NexetaStore $Nexenta
		exit 3
	fi

	if [ `grep -c -i offline $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
	then
		echo CRITICAL! The following FMRI have abnormal status : `grep -i offline $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
		rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
		exit 2
	else
		if [ `grep -c -i maintenance $TMPDIR/nexenta_$COMMAND.$Nexenta.out` -gt 0 ]
		then	
	        	echo WARNING! The following FMRI have maintenance status : `grep -i maintenance $TMPDIR/nexenta_$COMMAND.$Nexenta.out | tr -d '\n'`
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 1
		else
			echo OK : NMS Service have normal status
			rm -f $TMPDIR/nexenta_$COMMAND.$Nexenta.out
			exit 0
		fi
	fi
fi
