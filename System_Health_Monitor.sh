#!/bin/bash

# System Health Monitoring Script
# Logs system statistics and sends alerts if thresholds are exceeded.

# Configuration
LOG_FILE="/var/log/system_health.log"
THRESHOLD_CPU=80  # CPU usage percentage
THRESHOLD_MEM=80  # Memory usage percentage
THRESHOLD_DISK=80 # Disk usage percentage
EMAIL="shivdj.singh78@gmail.com" # Email for alerts
CHECK_INTERVAL=15 # Time in seconds between checks

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Usage: $CPU_USAGE%" | tee -a "$LOG_FILE"
    if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
        echo "High CPU usage detected: $CPU_USAGE%" | tee -a "$LOG_FILE"
        send_alert "CPU usage is at $CPU_USAGE%."
    fi
}

# Function to check memory usage
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo "Memory Usage: $MEM_USAGE%" | tee -a "$LOG_FILE"
    if (( $(echo "$MEM_USAGE > $THRESHOLD_MEM" | bc -l) )); then
        echo "High memory usage detected: $MEM_USAGE%" | tee -a "$LOG_FILE"
        send_alert "Memory usage is at $MEM_USAGE%."
    fi
}

# Function to check disk usage
check_disk() {
    DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: $DISK_USAGE%" | tee -a "$LOG_FILE"
    if (( DISK_USAGE > THRESHOLD_DISK )); then
        echo "High disk usage detected: $DISK_USAGE%" | tee -a "$LOG_FILE"
        send_alert "Disk usage is at $DISK_USAGE%."
    fi
}

# Function to send email alerts
send_alert() {
    local message=$1
    echo "$message" | mail -s "System Health Alert" "$EMAIL"
}

# Function to log network activity
log_network() {
    RX=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    TX=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    echo "Network Activity - RX: $RX bytes, TX: $TX bytes" | tee -a "$LOG_FILE"
}

# Main monitoring loop
while true; do
    echo "--- System Health Check: $(date) ---" | tee -a "$LOG_FILE"
    check_cpu
    check_memory
    check_disk
    log_network
    echo "------------------------------------" | tee -a "$LOG_FILE"
    sleep "$CHECK_INTERVAL"
done