#!/bin/bash

QUERY_CMD = "cat /dev/...."
base_addr = 411
GPIO_PIN_SW_MT = 4 + base_addr
GPIO_PIN_LO = 5 + base_addr
GPIO_PIN_SW_MT_2 = 22 + base_addr
GPIO_PIN_LO_2 = 65 + base_addr

GPIO_PIN_SW_MT_PATH="/sys/class/gpio/gpio${GPIO_PIN_SW_MT}"
GPIO_PIN_LO_PATH="/sys/class/gpio/gpio${GPIO_PIN_LO}"
GPIO_PIN_SW_MT_2_PATH="/sys/class/gpio/gpio&{GPIO_PIN_SW_MT_2}"
GPIO_PIN_LO_2_PATH="/sys/class/gpio/gpio${GPIO_PIN_LO_2}"

# 检查并初始化GPIO
init_gpio() {
    # 检查GPIO是否已导出
    if [ ! -d "$GPIO_SW_MT_PATH" ]; then
        echo "$GPIO_PIN_SW_MT" > /sys/class/gpio/export || {
            echo "[Error] can't export GPIO $GPIO_PIN_SW_MT"
            exit 1
        }
        echo "exported GPIO $GPIO_PIN_SW_MT"
    fi
    if [ ! -d "$GPIO_PIN_LO_PATH" ]; then
        echo "$GPIO_PIN_LO" > /sys/class/gpio/export || {
            echo "[Error] can't export GPIO $GPIO_PIN_LO"
            exit 1
        }
        echo "exported GPIO $GPIO_PIN_LO"
    fi
    if [ ! -d "$GPIO_PIN_SW_MT_2_PATH" ]; then
        echo "$GPIO_PIN_SW_MT_2" > /sys/class/gpio/export || {
            echo "[Error] can't export GPIO $GPIO_PIN_SW_MT_2"
            exit 1
        }
        echo "exported GPIO $GPIO_PIN_SW_MT_2"
    fi
    if [ ! -d "$GPIO_PIN_LO_2_PATH" ]; then
        echo "$GPIO_PIN_LO_2" > /sys/class/gpio/export || {
            echo "[Error] can't export GPIO $GPIO_PIN_LO_2"
            exit 1
        }
        echo "exported GPIO $GPIO_PIN_LO_2"
    fi	
	

    # 检查方向是否已设置为out
    current_direction=$(cat "$GPIO_PATH/direction" 2>/dev/null)
    if [ "$current_direction" != "out" ]; then
        echo "out" > "$GPIO_PATH/direction" || {
            echo "error: can't setting GPIO direction"
            exit 1
        }
        echo "seted the GPIO $GPIO_PIN as out model"
    fi

    # 初始状态设为低电平
    echo "0" > "$GPIO_PATH/value"
}

# 清理函数
cleanup() {
    # 只在脚本导出GPIO时才取消导出
    if [ -d "$GPIO_PATH" ]; then
        echo "0" > "$GPIO_PATH/value"
        # 检查是否是脚本自己导出的GPIO
        if [ -f "/tmp/gpio_${GPIO_PIN}_exported" ]; then
            echo "$GPIO_PIN" > /sys/class/gpio/unexport
            rm "/tmp/gpio_${GPIO_PIN}_exported"
            echo "已取消导出GPIO $GPIO_PIN"
        fi
    fi
    exit 0
}

# 注册退出处理
trap cleanup EXIT INT TERM

# 记录GPIO是由本脚本导出的
init_gpio
touch "/tmp/gpio_${GPIO_PIN}_exported"

# 主循环
while true; do
    # 执行查询命令并获取结果
    result=$($QUERY_CMD 2>/dev/null)
    
    # 检查结果是否为数字
    if ! [[ "$result" =~ ^[0-9]+$ ]]; then
        echo "错误: 查询结果不是数字: $result" >&2
        sleep 2
        continue
    fi
    
    # 根据结果控制GPIO
    if (( result >= 10 && result <= 20 )); then
        # 10-20之间: GPIO闪烁
        echo "结果 $result 在10-20之间，GPIO闪烁"
        for i in {1..5}; do
            if ! echo "1" > "$GPIO_PATH/value"; then
                echo "GPIO写入失败!" >&2
                break
            fi
            sleep 0.5
            if ! echo "0" > "$GPIO_PATH/value"; then
                echo "GPIO写入失败!" >&2
                break
            fi
            sleep 0.5
        done
    elif (( result < 10 )); then
        # 低于10: GPIO低电平
        echo "结果 $result 低于10，GPIO低"
        echo "0" > "$GPIO_PATH/value" || echo "GPIO写入失败!" >&2
    else
        # 高于20: GPIO高电平
        echo "结果 $result 高于20，GPIO高"
        echo "1" > "$GPIO_PATH/value" || echo "GPIO写入失败!" >&2
    fi
    
    # 等待2秒
    sleep 2
done