
BASE_DIR=$(pwd)  # 获取脚本所在目录
IP_ADDRESS="192.168.1.101"             # 要传递的IP参数
LOG_FILE="$BASE_DIR/startup_$(date +%Y%m%d).log"
PID_FILE="$BASE_DIR/startup_pids.pid"

# 程序路径
PROGRAM1="$BASE_DIR/udp_client"          
PROGRAM2="$BASE_DIR/modbus_gps"          
SCRIPT="$BASE_DIR/gpio_monitor.sh"      

# 清空旧日志和PID文件
: > "$LOG_FILE"
: > "$PID_FILE"

# 后台启动函数
function run_in_bg() {
    local name=$1
    local cmd=$2
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] starting $name..." | tee -a "$LOG_FILE"
    
    # 后台运行并记录PID
    "$cmd" "$@" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid:$name" >> "$PID_FILE"
}

{   
    run_in_bg "udp_client" "$PROGRAM1" "$IP_ADDRESS"
    run_in_bg "beidou" "$PROGRAM2"
    run_in_bg "gpio" "$SCRIPT"
    
} | tee -a "$LOG_FILE"

# （后台进程继续运行）
exit 0
