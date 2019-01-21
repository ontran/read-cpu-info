#!/system/bin/sh
SUDO=

##!/bin/bash
#SUDO=sudo

###!/system/bin/sh
## https://www.kernel.org/doc/Documentation/cpu-freq/user-guide.txt
## https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-devices-system-cpu

CPUDIR=/sys/devices/system/cpu
CPUMAX=$($SUDO cat $CPUDIR/kernel_max)
NCORES=$(($CPUMAX+1))

echo ""

DOMORE="no"
if [ ! -z "$1" ]; then

    if [ $1 == "-a" ]; then
	DOMORE="yes"
    fi
  
    ### Just show commands
    if [ "$1" == "-show" ]; then
	echo "ONLINE    : cat $CPUDIR/online"
	echo "For CPU0::"
	echo "  Online : cat $CPUDIR/cpu0/online"
	echo "  Freq   : cat $CPUDIR/cpu0/cpufreq/cpuinfo_cur_freq"
	echo "  Freqs  : cat $CPUDIR/cpu0/cpufreq/scaling_available_frequencies"
	echo "  Gov    : cat $CPUDIR/cpu0/cpufreq/scaling_governor"
	echo "  Govs   : cat $CPUDIR/cpu0/cpufreq/scaling_available_governors"
	echo "  Temp[QCOM]   : cat /sys/class/thermal/thermal_zone5/temp"
	echo "NOTE: may need sudo"
	exit 0
    fi
fi

if [ $DOMORE == "yes" ]; then
    echo "N CORES  : $NCORES"
    echo " "
fi

#ONLINE=$($SUDO cat $CPUDIR/online)
#echo "ONLINE  : $(cat $CPUDIR/online)"
#echo "OFFLINE : $(cat $CPUDIR/offline)"

#echo "CPUMAX=$CPUMAX"
#echo ""

for CPUN_DIR in $CPUDIR/cpu*
do

    #echo " ----------- CPU: $CPUN_DIR"
    if [ ! -e "$CPUN_DIR/online" ]; then
	### Somehow cpu0 on ubuntu do not have online but still alive
	LEN=${#CPUN_DIR}
	STRE="${CPUN_DIR:$(($LEN-1)):1}"
	#echo "STRE = $STRE"
	if [ $STRE != "0" ]; then
	    continue;
	fi
    fi

    echo "CPU: $CPUN_DIR"
    if [ $(cat $CPUN_DIR/online) == "0" ]; then
	echo "offline"
	echo ""
	continue;
    fi

    KHZ=$($SUDO cat $CPUN_DIR/cpufreq/cpuinfo_cur_freq)
    MHZ=$(($KHZ/1000))
    FREQMAX=$($SUDO cat $CPUN_DIR/cpufreq/cpuinfo_max_freq)
    FREQMAX=$(($FREQMAX/1000))
    FREQMIN=$($SUDO cat $CPUN_DIR/cpufreq/cpuinfo_min_freq)
    FREQMIN=$(($FREQMIN/1000))
    #FREQS=$($SUDO cat $CPUN_DIR/cpufreq/scaling_available_frequencies)
    GOV=$($SUDO cat $CPUN_DIR/cpufreq/scaling_governor)
    GOVS=$($SUDO cat $CPUN_DIR/cpufreq/scaling_available_governors)

    echo "$KHZ KHz ($MHZ MHz) | MAX $FREQMAX MHz | MIN $FREQMIN MHz"
    #echo "    temp: $TEMP C"
    echo "gov: $GOV"
    if [[ "$DOMORE" -eq 1 ]]; then
        echo "     govs: $GOVS"
        #echo "    freqs: $FREQS"
    fi

    echo ""
done

TEMP5=/sys/class/thermal/thermal_zone5/temp
TEMP0=/sys/class/thermal/thermal_zone0/temp
if [ -e $TEMP5 ]; then
    echo "TEMP (zone5) : $(cat $TEMP5) C [QCOM]"
fi
if [ -e $TEMP0 ]; then
    TEMP=$(($(cat $TEMP0)/1000))
    if [ $TEMP -gt 10 ]; then
	echo "TEMP (zone0) : $TEMP C"
    fi
fi

echo ""

