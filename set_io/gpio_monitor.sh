


GPIO_BASE=411
GPIO_PIN_DEFINE=63
GPIO_PIN=$((GPIO_BASE + GPIO_PIN_DEFINE))
file="rssi_date.txt"
GPIO_PIN_PATH="/sys/class/gpio/gpio${GPIO_PIN}"

# 检查间隔时间（秒）
CHECK_INTERVAL=5

# 检查是否导出GPIO
if [ ! -d "$GPIO_PIN_PATH" ]; then
    echo "$GPIO_PIN" > /sys/class/gpio/export || {
        echo "[Error] can't export GPIO $GPIO_PIN" >&2
        exit 1
    }
    echo "exported GPIO $GPIO_PIN"
    sleep 1  # 等待设备创建
fi

# 测试是否设置输出模式
current_direction=$(cat "$GPIO_PIN_PATH/direction" 2>/dev/null)
if [ "$current_direction" != "out" ]; then
    echo "out" > "$GPIO_PIN_PATH/direction" || {
        echo "error: can't setting GPIO direction" >&2
        exit 1
    }
    echo "set the GPIO $GPIO_PIN as out model"
fi

# 初始时刻设置为低电平
echo "0" > "$GPIO_PIN_PATH/value"

# 主循环
while true; do
    while [ ! -f "$file" ]; do
        sleep 0.1
    done
    
    #result=$(cat "$file" 2>/dev/null)
	cat "$file" 2>/dev/null || echo "0"
    
    # 检查结果是否为数字
	if ! echo "$result" | grep -qE '^-?[0-9]+$'; then
        result=0  # 如果不是有效数字，强制设为0
        echo "warning result set as 0" >&2
    fi
	
    
    # 根据结果控制GPIO
    if [ "$result" -le -60 ] && [ "$result" -ge -70 ]; then
        # -60到-70之间: GPIO闪烁
        for i in 1 2 3 4 5; do
            if ! echo "1" > "$GPIO_PIN_PATH/value"; then
                echo "GPIO写入失败!" >&2
                break
            fi
            sleep 0.5
            if ! echo "0" > "$GPIO_PIN_PATH/value"; then
                echo "GPIO写入失败!" >&2
                break
            fi
            sleep 0.5
        done
    elif [ "$result" -le -70 ] && [ "$result" -ge -80 ]; then
        # -70到-80: GPIO低电平
        echo "0" > "$GPIO_PIN_PATH/value" || echo "GPIO write failed!" >&2
    elif [ "$result" -le -50 ] && [ "$result" -ge -60 ]; then
        # -50到-60: GPIO高电平
        echo "1" > "$GPIO_PIN_PATH/value" || echo "GPIO write failed!" >&2
	elif [ "$result" -ge -61 ]; then
        # -50到-60: GPIO高电平
        echo "1" > "$GPIO_PIN_PATH/value" || echo "GPIO write failed!" >&2
    else
        # 其余情况: 不认可，GPIO低电平
        echo "0" > "$GPIO_PIN_PATH/value" || echo "GPIO write failed!" >&2
    fi

    sleep "$CHECK_INTERVAL"
done