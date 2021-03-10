#!/system/bin/sh

export ASH_STANDALONE=1
BUSYBOX=/data/adb/magisk/busybox
export MODDIR=${0%/*}
RESET_SCRIPT="$MODDIR/reset_adid.sh"
export ADID_SETTINGS=/data/data/com.google.android.gms/shared_prefs/adid_settings.xml

# minimum and maximum for random amount of time to sleep between re-generating ADID, in seconds
MIN_SLEEP=300
MAX_SLEEP=600

SLEEP_TIME=
set_sleep_time() {
	rnd=`hexdump -n2 -e "/2 \"%4u\n\"" /dev/urandom`
	SLEEP_TIME="$(( $MIN_SLEEP + $rnd % ( $MAX_SLEEP - $MIN_SLEEP + 1 ) ))"
}

# wait for /data/data to become available
# if the phone doesn't have Google Mobile Services installed, we'll keep on spinning in this loop forever - shouldn't use much CPU
while [ ! -s $ADID_SETTINGS ]; do sleep 10; done

# keep on resetting after random waits; tolerate 3 errors
ERRORS=0
while [ $ERRORS -le 3 ]; do
	$BUSYBOX sh $RESET_SCRIPT || ((ERRORS++))
	set_sleep_time
	sleep $SLEEP_TIME
done

exit $ERRORS
