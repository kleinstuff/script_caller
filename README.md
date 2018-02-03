# SCRIPT_CALLER.SH
Shell script to call other scripts controlling their execution

# Options
###--preexec
pre-execution, like "php" or "sh"

###--script
The script you will run (with full path)

###--log_folder
Where to store logs?
Set only the path, the filename will always be the script_name.log

###--lock_folder
Where to store lock_files?
Defaults to /tmp if null

###--timeout
Set a timeout for the script. If null there will be no timeout

# Examples
```
./script_caller.sh --script test.sh  --preexec sh  --log_folder /tmp     --timeout 10
```
```
./script_caller.sh --script test.php --preexec php --log_folder /var/log --lock_folder /var/run
```
