#!/system/bin/sh

UUID_RE="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

NEW_ADID=
generate_adid () {
	# raw 16 bytes
	NEW_ADID=`hexdump -n16 -e "/4 \"%08x\" /2 \"-%04x\" /2 \"-%04x\" /2 \"-%04x\" /2 \"-%04x\" /4 \"%08x\"" /dev/urandom`

	# now massage it to conform to RFC 4122/DCE 1.1 aka Leach–Salz
	# UUID version 4, MSB nibble of 7th byte must be hex digit 4
	# UUID variant 1, MSB nibble of 9th byte must be 10xx, so hex digit must be one of 8,9,a,b
	rnd=`hexdump -n2 -e "/2 \"%4u\n\"" /dev/urandom`
	byte9_nibble_val="$(( ($rnd % 4) + 8))"
	byte9_nibble_hex_digit="$byte9_nibble_val"
	[ $byte9_nibble_val -eq 10 ] && byte9_nibble_hex_digit="a"
	[ $byte9_nibble_val -eq 11 ] && byte9_nibble_hex_digit="b"
	NEW_ADID=`echo $NEW_ADID | sed -e "s/./4/15" -e "s/./$byte9_nibble_hex_digit/20"`
}

[ -s $ADID_SETTINGS ]	|| { echo "ERROR: $ADID_SETTINGS not found"; exit 1; }

# Desired settings
#    <string name="adid_key">xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx</string>
#    <int name="adid_reset_count" value="1" />

{ generate_adid; sed -ri -e "s/name=\"adid_key\"\>$UUID_RE/name=\"adid_key\"\>$NEW_ADID/" $ADID_SETTINGS; }																|| { RET=$?; echo "ERROR $RET running sed"; exit $RET; }
# if fake_adid_key non-empty, reset it too
grep -q "fake_adid_key\"><" $ADID_SETTINGS	|| { generate_adid; sed -ri -e "s/name=\"fake_adid_key\"\>$UUID_RE/name=\"fake_adid_key\"\>$NEW_ADID/" $ADID_SETTINGS; }	|| { RET=$?; echo "ERROR $RET running sed"; exit $RET; }
sed -ri -e "s/name=\"(.*adid_reset_count.*)\"[[:space:]]+value=\"[0-9]+\"/name=\"\1\" value=\"1\"/" $ADID_SETTINGS														|| { RET=$?; echo "ERROR $RET running sed"; exit $RET; }
# TODO don't set enable_limit_ad_tracking (Opt out of Ads Personalization) - it'd be unnecessary and an extra distinguishing trait
#sed -ri -e "s/name=\"(.*enable_limit_ad_tracking.*)\"[[:space:]]+value=\"false\"/name=\"\1\" value=\"true\"/" $ADID_SETTINGS											|| { RET=$?; echo "ERROR $RET running sed"; exit $RET; }
