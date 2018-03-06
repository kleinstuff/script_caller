# SCRIPT_CALLER.SH
Shell script to call other scripts controlling their execution

# Options
### --preexec
pre-execution, like "php" or "sh"

### --script
The script you will run (with full path)

### --log_folder
Where to store logs?
Set only the path, the filename will always be the script_name.log

### --lock_folder
Where to store lock_files?
Defaults to /tmp if null

### --timeout
Set a timeout for the script. If null there will be no timeout

### --extra_rror_log
To log failed attempts on running the script because another script was already running.

### help
Help info

# Examples
```
./script_caller.sh --script test.sh  --preexec sh  --log_folder /tmp     --timeout 10
```
```
./script_caller.sh --script test.php --preexec php --log_folder /var/log --lock_folder /var/run
```
