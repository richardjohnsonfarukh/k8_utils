#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASH_MODE=""

test_exit_code() {
  EXIT_CODE=$(echo $?)
  if [[ $EXIT_CODE != 0 ]]; then 
    exit 1
  fi
}

osprey_login() {
   osprey user login
}

select_context() {
   ${SCRIPT_DIR}/context.rb
}

docker_exec() {
    MODE=bash
    if [[ ! -z $BASH_MODE ]]; then
      MODE=$BASH_MODE
    fi
    ${SCRIPT_DIR}/exec.rb -d
    test_exit_code
    CONTAINER_ID=$( sed -n '1p' < "$SCRIPT_DIR/pod_id.tmp" )
    docker exec -it "$CONTAINER_ID" "/bin/$MODE"
}

kubernetes_exec() {
    MODE=sh
    if [[ ! -z $BASH_MODE ]]; then
      MODE=$BASH_MODE
    fi
    ${SCRIPT_DIR}/exec.rb -k
    test_exit_code    
    POD_ID=$( sed -n '1p' < "$SCRIPT_DIR/pod_id.tmp" )
    kubectl exec -it "$POD_ID" -- "/bin/$MODE"
}

clean_up() {
   rm ${SCRIPT_DIR}/*.tmp
}

usage() {
   INDENT="  "
   echo "Usage: cl [options]"
   echo "${INDENT}-c   select kubernetes context first"
   echo "${INDENT}-l   login to osprey"
   echo "${INDENT}-d   exec into docker container"
   echo "${INDENT}-k   exec into kubernetes pod"
   echo "${INDENT}-m   select a mode to exec into a pod/container"
}

while getopts "lcdkm:" arg; do
    case "${arg}" in
        l)
            osprey_login
            ;;
        c)  
            select_context
            ;;
        d)
            docker_exec
            ;;
        k)
            kubernetes_exec
            ;;
        m)  BASH_MODE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

clean_up
