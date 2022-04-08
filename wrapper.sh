#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

K8_BASH_MODE=${1:sh}

osprey_login() {
   osprey user login
}

select_context() {
   ${SCRIPT_DIR}/context.rb
}

docker_exec() {
    ${SCRIPT_DIR}/exec.rb -d
    CONTAINER_ID=$( sed -n '1p' < "$SCRIPT_DIR/pod_id.tmp" )
    docker exec -it "$CONTAINER_ID" /bin/bash
}

kubernetes_exec() {
    ${SCRIPT_DIR}/exec.rb -k
    POD_ID=$( sed -n '1p' < "$SCRIPT_DIR/pod_id.tmp" )
    kubectl exec -it "$POD_ID" -- "/bin/$K8_BASH_MODE"
}

clean_up() {
   rm ${SCRIPT_DIR}/*.tmp
}

usage() {
   INDENT="  "
   echo "Usage: kb [options]"
   echo "${INDENT}-c   select kubernetes context first"
   echo "${INDENT}-l   login to osprey"
   echo "${INDENT}-d   exec into docker container"
   echo "${INDENT}-k   exec into kubernetes pod"
}

while getopts "lcdk" arg; do
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
        *)
            usage
            ;;
    esac
done

clean_up
