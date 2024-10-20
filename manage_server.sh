#!/bin/bash

COLOR_INFO="\e[34m"
COLOR_WARNING="\e[33m"
COLOR_ERROR="\e[31m"
COLOR_RESET="\e[0m"

ANSIBLE_DIR="${PWD}"
ANSIBLE_PLAYBOOK="${ANSIBLE_DIR}/ansible/main.yml"
ANSIBLE_HOSTS="${ANSIBLE_DIR}/ansible/hosts"
ANSIBLE_CONFIG_FILE="${ANSIBLE_DIR}/ansible/ansible.cfg"


usage() {
    echo -e ""
    echo -e "${COLOR_INFO}Usage:${COLOR_RESET}"
    echo -e "    $0 -h                         Display this help message."
    echo -e "    $0 -s                         Configure OpenVPN server."
    echo -e "    $0 -r <routes>                Configure OpenVPN routes."
    exit 0
}

if [ $# -eq 0 ]; then
    echo -e "${COLOR_WARNING}Missing options!${COLOR_RESET}"
    echo -e "(run $0 -h for help)"
    echo ""
    exit 1
fi

export ANSIBLE_CONFIG="${ANSIBLE_CONFIG_FILE}"

while getopts "hsr:" opt; do
    case ${opt} in
        h ) usage ;;

        s )
            ansible-playbook -i "${ANSIBLE_HOSTS}" "${ANSIBLE_PLAYBOOK}"
            echo -e "${COLOR_INFO}OpenVPN server configured.${COLOR_RESET}"
        ;;

        r )
            if [ -n "${OPTARG}" ]; then
                ansible-playbook --extra-vars "routes=${OPTARG}" \
                                 -i "${ANSIBLE_HOSTS}" \
                                 -t routes "${ANSIBLE_PLAYBOOK}"
                echo -e "${COLOR_INFO}Routes configured for OpenVPN.${COLOR_RESET}"
            else
                echo -e "${COLOR_ERROR}Error: Missing routes!${COLOR_RESET}"
            fi
        ;;

        \? )
            echo -e "${COLOR_ERROR}Invalid Option: -$OPTARG${COLOR_RESET}" 1>&2
            exit 1
        ;;
    esac
done
shift $((OPTIND -1))

