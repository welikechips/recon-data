histdeln(){
  # Get the current history number
  delete_num=$1; n=$(history 1 | awk '{print $1}'); for h in $(seq $(( $n - $delete_num )) $(( $n - 1 ))); do history -d $(( $n - $delete_num )); done; history -d $(history 1 | awk '{print $1}')
}