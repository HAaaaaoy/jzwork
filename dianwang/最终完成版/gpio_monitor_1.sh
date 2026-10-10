
GPIO_BASE=411
GPIO_PIN_62_DEFINE=62
GPIO_PIN_62=$((GPIO_BASE + GPIO_PIN_62_DEFINE))
GPIO_PIN_DEFINE=63
GPIO_PIN=$((GPIO_BASE + GPIO_PIN_DEFINE))
GPIO_PIN_62_PATH="/sys/class/gpio/gpio${GPIO_PIN_62}"
GPIO_PIN_PATH="/sys/class/gpio/gpio${GPIO_PIN}"

CHECK_INTERVAL=1

if [ ! -d "$GPIO_PIN_62_PATH" ]; then
    echo "$GPIO_PIN_62" > /sys/class/gpio/export || {
        echo "[Error] can't export GPIO $GPIO_PIN_62" >&2
        exit 1
    }
    echo "exported GPIO $GPIO_PIN_62"
    sleep 1  
fi

if [ ! -d "$GPIO_PIN_PATH" ]; then
    echo "$GPIO_PIN" > /sys/class/gpio/export || {
        echo "[Error] can't export GPIO $GPIO_PIN" >&2
        exit 1
    }
    echo "exported GPIO $GPIO_PIN"
    sleep 1  
fi

current_direction_62=$(cat "$GPIO_PIN_62_PATH/direction" 2>/dev/null)
current_direction=$(cat "$GPIO_PIN_PATH/direction" 2>/dev/null)
if [ "$current_direction_62" != "out" ]; then
    echo "out" > "$GPIO_PIN_62_PATH/direction" || {
        echo "error: can't setting GPIO direction" >&2
        exit 1
    }
    echo "set the GPIO $GPIO_PIN_62 as out model"
fi

if [ "$current_direction" != "out" ]; then
    echo "out" > "$GPIO_PIN_PATH/direction" || {
        echo "error: can't setting GPIO direction" >&2
        exit 1
    }
    echo "set the GPIO $GPIO_PIN as out model"
fi

echo "0" > "$GPIO_PIN_62_PATH/value"
echo "1" > "$GPIO_PIN_PATH/value"


while true; do
	if [ -n $(iwpriv vap0 cfg view_users | grep -i 0b)]; then
		echo "1" > "$GPIO_PIN_62_PATH/value" || echo "GPIO write failed!" >&2
		echo "0" > "$GPIO_PIN_PATH/value" || echo "GPIO write failed!" >&2
		sleep "$CHECK_INTERVAL"
	fi
done