#!/bin/bash
# Monitor all running builds

echo "=== Yocto Build Monitor ==="
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
    clear
    echo "=== $(date) ==="
    echo ""
    
    # Check running builds
    RUNNING=$(ps aux | grep -E "bitbake|build.sh|docker.*yocto.*build" | grep -v grep | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
        echo "📊 Active Builds: $RUNNING"
        ps aux | grep -E "bitbake|build.sh|docker.*yocto.*build" | grep -v grep | head -3
    else
        echo "📊 No active builds"
    fi
    echo ""
    
    # Show latest log tail
    LATEST_LOG=$(ls -t /home/picopiece/yocto_multi_platform/logs/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        echo "📝 Latest log: $(basename $LATEST_LOG)"
        echo "Last 10 lines:"
        tail -10 "$LATEST_LOG" 2>/dev/null | sed 's/^/  /'
    fi
    echo ""
    
    # System resources
    echo "💾 Disk: $(df -h /home/picopiece | tail -1 | awk '{print $4 " free (" $5 " used)"}')"
    echo "🧠 Memory: $(free -h | grep Mem | awk '{print $3 "/" $2 " (" $3/$2*100 "%)"}')"
    echo "⚡ Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    echo "Refreshing in 5 seconds... (Ctrl+C to stop)"
    sleep 5
done

