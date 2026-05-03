polybar-msg cmd quit
killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo "---" | tee -a /tmp/polybar1.log 
polybar bar 2>&1 | tee -a /tmp/polybar1.log & disown

echo "Bars launched..."