
BASE_DIR="/tmp"
IP_ADDRESS="192.168.1.105"             # 要传递的IP参数
LOG_FILE="$BASE_DIR/startup_log.log"
PID_FILE="$BASE_DIR/startup_pids.pid"

PROGRAM1="$BASE_DIR/udp_client"          
PROGRAM2="$BASE_DIR/modbus_gps"          
SCRIPT="$BASE_DIR/gpio_monitor.sh"      

: > "$LOG_FILE"
: > "$PID_FILE"

function run_in_bg() {
    local name=$1
    local cmd=$2
    shift 2
	
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] starting $name..." | tee -a "$LOG_FILE"
    cd /tmp
	
    "$cmd" "$@" >> /dev/null 2>&1 &
	#echo  "eeeeeeeeeeeee" | tee -a "$LOG_FILE"
    local pid=$!
    #echo  "wwwwwwwwwwwww" | tee -a "$LOG_FILE"
	cd -
}

{   
    run_in_bg "udp_client" "$PROGRAM1" "$IP_ADDRESS"
    run_in_bg "beidou" "$PROGRAM2"
    run_in_bg "gpio" "$SCRIPT"
    
} | tee -a "$LOG_FILE"

exit 0
