




GPIO_BASE=411
GPIO_PIN_4_DEFINE=4
GPIO_PIN_3_DEFINE=3
GPIO_PIN_4=$((GPIO_BASE + GPIO_PIN_4_DEFINE))
GPIO_PIN_3=$((GPIO_BASE + GPIO_PIN_3_DEFINE))
GPIO_PIN_4_PATH="/sys/class/gpio/gpio${GPIO_PIN_4}"
GPIO_PIN_3_PATH="/sys/class/gpio/gpio${GPIO_PIN_3}"

CHECK_INTERVAL=1

if [ ! -d "$GPIO_PIN_4_PATH" ]; then
    echo "$GPIO_PIN_4" > /sys/class/gpio/export || {
        echo "[Error] can't export GPIO $GPIO_PIN_4" >&2
        exit 1
    }
    echo "exported GPIO $GPIO_PIN_4"
    sleep 1  
fi

if [ ! -d "$GPIO_PIN_3_PATH" ]; then
    echo "$GPIO_PIN_3" > /sys/class/gpio/export || {
        echo "[Error] can't export GPIO $GPIO_PIN_3" >&2
        exit 1
    }
    echo "exported GPIO $GPIO_PIN_3"
    sleep 1  
fi

current_direction_4=$(cat "$GPIO_PIN_4_PATH/direction" 2>/dev/null)
current_direction_3=$(cat "$GPIO_PIN_3_PATH/direction" 2>/dev/null)


if [ "$current_direction_4" != "out" ]; then
    echo "out" > "$GPIO_PIN_4_PATH/direction" || {
        echo "error: can't setting GPIO direction" >&2
        exit 1
    }
    echo "set the GPIO $GPIO_PIN_4 as out model"
fi

if [ "$current_direction_3" != "out" ]; then
    echo "out" > "$GPIO_PIN_3_PATH/direction" || {
        echo "error: can't setting GPIO direction" >&2
        exit 1
    }
    echo "set the GPIO $GPIO_PIN_3 as out model"
fi

echo "1" > "$GPIO_PIN_3_PATH/value"

#没参数默认600M
if [ $# -eq 0 ];then
	echo "0" > "$GPIO_PIN_4_PATH/value"
	echo "1" > "$GPIO_PIN_3_PATH/value"
	exit 1
fi

CMD="$1"

#600M
if [ "$CMD" = "1" ]; then
	echo "0" > "$GPIO_PIN_4_PATH/value"
	echo "1" > "$GPIO_PIN_3_PATH/value"
else
	echo "1" > "$GPIO_PIN_4_PATH/value"
	echo "1" > "$GPIO_PIN_3_PATH/value"
fi



