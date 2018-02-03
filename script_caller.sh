#!/bin/bash

### script_caller.sh
#
#	Site..: www.google.com
#	Author.: Ricardo Felipe Klein / klein.rfk@gmail.com
#
#---------------------------------------------------------------------
#
#   Call simple scripts with a lock mechanism to avoid double execution
#   if the first instance is not ended yet. Very usefull in cron.
#
#   There is a timeout setting too, so you can stop the script if it
#   runs for more then $SCRIPT_TIMEOUT (--timeout) in seconds.
#
#---------------------------------------------------------------------
#
#	Changelog:
#
#       v0.1 2018-02-03, By: Klein
#               - First version.
#
#---------------------------------------------------------------------
#
#	ToDo:
#       Allow user commands on error
#
#---------------------------------------------------------------------
#
#	Depends on:
#		bash
#       timeout
#       grep
#
#------------------------------------------------------------------


# IF SCRIPT_TIMEOUT IS SET, ADD timeout
check_timeout() {
    if [ -n "${SCRIPT_TIMEOUT}" ]
    then
        SCRIPT_TIMEOUT="timeout ${SCRIPT_TIMEOUT}"
    fi
}

# CHECK IF THERE IS NO PROCESS ALREADY RUNNING
check_lock_file() {
    # IF NO LOCK_FOLDER IS SET, LETS SAVE IT ON /tmp
    if [ -z "${LOCK_FOLDER}" ]
    then
        LOCK_FOLDER="/tmp"
        LOCK_FILE="${LOCK_FOLDER}/${SCRIPT}"
    fi
    if [ -e "${LOCK_FILE}" ]
    then
        echo "There is already a process running: ${SCRIPT}"
        echo "With $(grep PID ${LOCK_FILE})"
        exit 1
    fi
}

# CREATE A LOCK FILE BEFORE RUN
create_lock_file() {
    echo "Script ${SCRIPT} started at $(date)" > ${LOCK_FILE}
    echo "PID: $$" >> ${LOCK_FILE}
}

# YOLO
run_command() {
    ${SCRIPT_TIMEOUT} ${SCRIPT_PREEXEC} ${SCRIPT_PATH}/${SCRIPT} > ${LOG_FILE} 2>&1
    EXIT_CODE="$?"
    if [ "${EXIT_CODE}" != "0" ]
    then
        if [ "${EXIT_CODE}" == "124" ]
        then
            echo "$(date) - CANCELLING ${SCRIPT} DUE TO TIMEOUT" >> ${LOG_FILE}
        fi
        echo "SCRIPT ERROR!"
    fi

    rm -rf ${LOCK_FILE}
}

# GET PARAMETERS
while (( "$#" ))
do 
    case "${1}" in
        "--preexec")
            shift
            SCRIPT_PREEXEC=${1}
            ;;
        "--script")
            shift
            SCRIPT=$(basename ${1})
            SCRIPT_PATH=$(dirname ${1})
            ;;
        "--log_folder")
            shift
            LOG_FOLDER=${1}
            LOG_FILE="${LOG_FOLDER}/${SCRIPT}.log"
            ;;
        "--lock_folder")
            shift
            LOCK_FOLDER=${1}
            LOCK_FILE="${LOCK_FOLDER}/${SCRIPT}.lock"
            ;;
        "--timeout")
            shift
            SCRIPT_TIMEOUT=${1}
            ;;
    esac
  shift 
done


# RUN
check_timeout
check_lock_file
create_lock_file
run_command
