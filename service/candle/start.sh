printf "Starting\n"
nohup ruby main.rb 1>stdout.log 2>stderr.log &
PID=$!
sleep 1
if ps -p $PID > /dev/null
then
  printf "process $PID started\n"
  printf $PID > pid
  exit 0
else
  printf "process failed to start\n"
  exit 1
fi
