#!/bin/bash

HOST="sftp server adress or hostname"
SFTP_DIR="sftp directory"
LOCAL_DIR="local directory"
FILES=$(find $LOCAL_DIR -name "*.svd" -type f)
EXCLUDE="--exclude some_local_directory/ "

#Define date function for loging
log_date () {
	NOW=$(date +"%d/%m/%Y %H:%M:%S")
	echo $NOW
}  

echo `log_date` "checking $LOCAL_DIR for files to send..."

#Change file format to windows if needed (this is optional.)

for i in $FILES
do

if [[ $(grep -c $'\r' $i) -eq 0 ]] && [[ $(wc -c <$i) -ne 0 ]] 
then
	echo `log_date` "$i" " file is reformatted for windows..."
	unix2dos -k $i
fi
	

STATUS="/sbin/lsof $i"
eval $STATUS > /dev/null
ret_code=$?

slp=1
count=0
try=60

#Check if file is processed or open right now, wait for closure.  
until [ $ret_code -eq 1 ] || [ $count -ge $try ]
        do
                eval $STATUS > /dev/null
		ret_code=$?
        	
		echo `log_date` "$i file is open, waiting for closure..."
        
		sleep $slp
                let count=$count+1
	done
	
	if [ $ret_code -eq 0 ]
	then
		filestatus="NOK"
	elif [ $ret_code -eq 1 ]
	then
		filestatus="OK"
	fi

	if [ "$filestatus" == "NOK" ] 
	then
		echo `log_date` "$i file is still open and checked as do not send because of time out"
		#Aggregate files which are marked as do not send to EXCLUDE variable
		EXCLUDE=$EXCLUDE"--exclude $(basename $i) "
	fi
done

#Sync files to sftp server which are not marked as do not send.
(
	echo set ftp:list-options -a
	echo set cmd:fail-exit true
	echo set cmd:default-protocol sftp
	echo open $HOST
	echo cd $SFTP_DIR
	echo lcd $LOCAL_DIR
	echo mirror -R -v -n --include-glob *.svd $EXCLUDE $LOCAL_DIR $SFTP_DIR
	echo quit
) | lftp -f /dev/stdin 2>&1
