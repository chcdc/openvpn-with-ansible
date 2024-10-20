#!/bin/bash

COLOR_INFO="\e[34m"
COLOR_WARNING="\e[33m"
COLOR_ERROR="\e[31m"
COLOR_RESET="\e[0m"

ANSIBLE_DIR="${PWD}"
ANSIBLE_PLAYBOOK="${ANSIBLE_DIR}/ansible/main.yml"
ANSIBLE_HOSTS="${ANSIBLE_DIR}/ansible/hosts"
ANSIBLE_CONFIG_FILE="${ANSIBLE_DIR}/ansible/ansible.cfg"
VPN_CONFIG_DIR="${ANSIBLE_DIR}/vpn-config"

usage() {
    echo -e "${COLOR_INFO}Usage:${COLOR_RESET}"
    echo -e "    $0 -h                         Display this help message."
    echo -e "    $0 -u <user> -p <password> -c  Create OpenVPN user."
    echo -e "    $0 -d <user>                  Delete OpenVPN user."
    exit 0
}

if [ $# -eq 0 ]; then
    echo -e "${COLOR_WARNING}Missing options!${COLOR_RESET}"
    echo -e "(run $0 -h for help)"
    echo ""
    exit 1
fi

export ANSIBLE_CONFIG="${ANSIBLE_CONFIG_FILE}"

while getopts "huc:d:" opt; do
    case ${opt} in
        h ) usage ;;

        u ) uname=$OPTARG ;;

        c )
            if [[ -n "${uname}" && -n "${OPTARG}" ]]; then
                upass=${OPTARG}
                ansible-playbook --extra-vars "uname=${uname} upass=${upass}" \
                                 -i "${ANSIBLE_HOSTS}" \
                                 -t create_user "${ANSIBLE_PLAYBOOK}"
                echo -e "${COLOR_INFO}User ${uname} created and credentials saved.${COLOR_RESET}"
                echo -e "${COLOR_INFO}${uname}\n${upass}${COLOR_RESET}" > "${VPN_CONFIG_DIR}/${uname}.txt"
            else
                echo -e "${COLOR_ERROR}Error: Missing username or password!${COLOR_RESET}"
            fi
        ;;

        d )
            if [ -n "${OPTARG}" ]; then
                uname=${OPTARG}
                ansible-playbook --extra-vars "uname=${uname}" \
                                 -i "${ANSIBLE_HOSTS}" \
                                 -t delete_user "${ANSIBLE_PLAYBOOK}"
                echo -e "${COLOR_INFO}User ${uname} deleted.${COLOR_RESET}"
            else
                echo -e "${COLOR_ERROR}Error: Missing username!${COLOR_RESET}"
            fi
        ;;

        \? )
            echo -e "${COLOR_ERROR}Invalid Option: -$OPTARG${COLOR_RESET}" 1>&2
            exit 1
        ;;
    esac
done
shift $((OPTIND -1))

