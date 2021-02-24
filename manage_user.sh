#!/bin/bash

ANSIBLE_DIR="${PWD}"

if [ $# -eq 0 ]
then
        echo "Missing options!"
        echo "(run $0 -h for help)"
        echo ""
        exit 0
fi

while getopts "d:hp:u:cs" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "    $0 -h                         Display this help message."
      echo "    $0 -u <user> -p <password> -c Create user openvpn."
      echo "    $0 -d <user>                  Delete user openvpn."
      echo "    $0 -s                         Configure OpenVPN Server."
      echo "    $0 -r <routes>                 Configure routes openvpn."
      exit 0
      ;;
    
    u ) uname=$OPTARG
    ;;
    p ) upass=$OPTARG
    ;;
    c )
        if [ -n "${uname}" ] && [ -n "${upass}" ]; then
          export ANSIBLE_CONFIG=${ANSIBLE_DIR}/ansible/ansible.cfg
          ansible-playbook --extra-vars "uname=${uname} upass=${upass}" \
                           -i "${ANSIBLE_DIR}"/ansible/hosts \
                           -t create_user "${ANSIBLE_DIR}"/ansible/main.yml
          echo -e "${uname}\n${upass}" > "${ANSIBLE_DIR}"/vpn-config/"${uname}".txt
        else
          echo -e "Missing username or password!"
        fi
    ;;
    d ) uname=$OPTARG
        export ANSIBLE_CONFIG=${ANSIBLE_DIR}/ansible/ansible.cfg
        ansible-playbook --extra-vars "uname=${uname} " \
                         -i ${ANSIBLE_DIR}/hosts \
                         -t delete_user "${ANSIBLE_DIR}"/main.yml
    ;;
    s ) export ANSIBLE_CONFIG=${path.module}/ansible.cfg
        ansible-playbook -i "${ANSIBLE_DIR}"/ansible/hosts \
                            "${ANSIBLE_DIR}"/ansible/main.yml

    r ) routes=$OPTARG
        export ANSIBLE_CONFIG=${ANSIBLE_DIR}/ansible/ansible.cfg
        ansible-playbook --extra-vars "uname=${uname} " \
                         -i "${ANSIBLE_DIR}"/ansible/hosts \
                         -t routes "${ANSIBLE_DIR}"/ansible/main.yml
    
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))
