#!/bin/bash

# 配置项
BASE_DIR=$(dirname "$(realpath "$0")")  # 获取脚本所在目录
IP_ADDRESS="192.168.1.100"             # 要传递的IP参数
LOG_FILE="$BASE_DIR/startup_$(date +%Y%m%d).log"
PID_FILE="$BASE_DIR/startup_pids.pid"

# 程序路径（相对脚本目录）
PROGRAM1="$BASE_DIR/program1"          # 第一个程序
PROGRAM2="$BASE_DIR/program2"          # 第二个程序
SCRIPT="$BASE_DIR/your_script.sh"      # 要启动的脚本

# 清空旧日志和PID文件
: > "$LOG_FILE"
: > "$PID_FILE"

# 后台启动函数（带错误检查）
function run_in_bg() {
    local name=$1
    local cmd=$2
    local arg=$3  # IP参数
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动 $name..." | tee -a "$LOG_FILE"
    
    # 后台运行并记录PID
    "$cmd" "$arg" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid:$name" >> "$PID_FILE"
    
    # 检查是否启动成功
    sleep 0.3
    if ! ps -p $pid > /dev/null; then
        echo "[error] $name setup failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    echo "[success] $name (PID: $pid)" | tee -a "$LOG_FILE"
}

# 主流程
{
    
    # 启动程序1（带IP参数）
    run_in_bg "程序1" "$PROGRAM1" "$IP_ADDRESS"
    
    # 启动程序2（带IP参数）
    run_in_bg "程序2" "$PROGRAM2" "$IP_ADDRESS"
    
    # 启动脚本（带IP参数）
    run_in_bg "控制脚本" "$SCRIPT" "$IP_ADDRESS"
    
    echo "==== 所有程序已在后台运行 ===="
    echo "日志文件: $LOG_FILE"
    echo "进程列表: $PID_FILE"
} | tee -a "$LOG_FILE"

# （后台进程继续运行）
exit 0