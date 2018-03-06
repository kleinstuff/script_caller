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
#       Create a statistics file to save how much time each run takes
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
        LOCK_FILE="${LOCK_FOLDER}/${SCRIPT}.lock"
    fi
    if [ -e "${LOCK_FILE}" ]
    then
        echo "There is already a process running: ${SCRIPT}"
        echo -ne "\n\n$(date) Skipping because there is already a process running with $(grep PID ${LOCK_FILE}) \n\n" >> ${LOG_FILE}
        if [ -n "${EXTRA_ERROR_LOG}" ]
        then
            echo -ne  "\n$(date) Aborting the run of: ${SCRIPT}\n$(date) Skipping because there is already a process running with $(grep PID ${LOCK_FILE}) \n\n" >> ${EXTRA_ERROR_LOG}
        fi

        exit 1
    fi
}

# CREATE A LOCK FILE BEFORE RUN
create_lock_file() {
    echo "Script ${SCRIPT} started at $(date)" > ${LOCK_FILE}
    echo "PID: $$" >> ${LOCK_FILE}
}

# ENSURES THAT THE LOG FOLDER EXISTS
create_log_folder() {
    if [ ! -d ${LOG_FOLDER} ]
    then
        mkdir ${LOG_FOLDER}
    fi
}

# YOLO
run_command() {
    echo -ne "\n\n\n$(date) Starting ${SCRIPT} with PID $$\n" >> ${LOG_FILE}
    ${SCRIPT_TIMEOUT} ${SCRIPT_HANDLER} ${SCRIPT_PATH}/${SCRIPT} >> ${LOG_FILE} 2>&1
    echo "$(date) ENDING..." >> ${LOG_FILE}
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


abouthelp() {
    echo -ne " 
    Options:\n
    \t --script_handler: The handler to run the script ex.: /bin/bash, /usr/bin/php, python \n
    \t --script: The actual script to be running \n
    \t --log_folder: Folder to save logs, the logname will be the script name.log \n
    \t --lock_folder: Place to save the lock file. Default: /tmp \n
    \t --timeout: Sets a timeout and cancel execution if exceeded. Optional, Default: null \n
    \t --extra_error_log: Sets a secondary error log to save info about executions canceled 
    \t\t because another process was already running.
    \t\t This can be good to monitor and check if your processes had not stopped running
    
    Example:
    script_caller.sh \\
        --script_handler php \\
        --script /foo/bar.php \\
        --log_folder /var/log \\
        --lock_folder /tmp \\
        --timeout 10 \\
        --extra_error_log /var/log/script_errors.log\n\n"
}

# GET PARAMETERS
while (( "$#" ))
do 
    case "${1}" in
        "--script_handler")
            shift
            SCRIPT_HANDLER=${1}
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
        "--extra_error_log")
            shift
            EXTRA_ERROR_LOG=${1}
            ;;
        "help")
            abouthelp
            exit 0
            ;;
    esac
  shift 
done


# RUN
check_timeout
check_lock_file
create_lock_file
create_log_folder
run_command
