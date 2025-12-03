#!/bin/bash

SENSOR_LEFT="/sys/bus/iio/devices/iio:device0/in_illuminance_input"
SENSOR_RIGHT="/sys/bus/iio/devices/iio:device1/in_illuminance_input"
CACHE_FILE="/tmp/als_cache.txt"

INTERVAL=0.5  # seconds between updates
L_SCALE=12000  # lux scale for exponential mapping

while true; do
    LEFT=$(cat "$SENSOR_LEFT" 2>/dev/null || echo 0)
    RIGHT=$(cat "$SENSOR_RIGHT" 2>/dev/null || echo 0)

    # Convert float lux to integer
    LEFT_INT=${LEFT%.*}
    RIGHT_INT=${RIGHT%.*}

    # Pick strongest sensor
    if [ "$LEFT_INT" -gt "$RIGHT_INT" ]; then
        LUX=$LEFT_INT
    else
        LUX=$RIGHT_INT
    fi

    # Exponential mapping (0 = dark, 255 = bright)
    SOLAR=$(awk -v lux="$LUX" -v scale="$L_SCALE" '
        BEGIN {
            val = 255 * (1 - exp(-lux/scale));  # exponential curve
            if (val < 0) val = 0;
            if (val > 255) val = 255;
            printf("%d\n", val + 0.5);
        }')

    # Debug output
    echo "[DEBUG] LEFT: $LEFT_INT  RIGHT: $RIGHT_INT  ->  LUX: $LUX  SOLAR: $SOLAR"

    # Write atomically
    echo "$SOLAR" > "${CACHE_FILE}.tmp"
    chmod 666 "${CACHE_FILE}.tmp"
    mv "${CACHE_FILE}.tmp" "$CACHE_FILE"

    sleep "$INTERVAL"
done
