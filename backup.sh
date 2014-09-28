#!/bin/bash

#Dependencies:
#OpenSSH server and client
#RSync
#A remote server to sync your files to
#SSH keys with your public key on your remote server
#Cron (Optional - Only needed for automated backups)
#Tar (Optional - Only needed if $GZIP="1")

#0 is false, 1 is true.
#Date
DATE="$(date +"%d-%m-%y")"
#What files are we going to backup? Example: ~/www/
BACKUP=""
#SSH key
SSHKEY="id_rsa.pub"
#Log file
LOGFILE="backup.log"
#Are we going to gzip this and rsync it over? 0=false 1=true
GZIP=""
#Gzip output log
GZIPLF="gzip.log"
#SSH port for rsync
SSHPORT=""
#Remote user
REMOTEUSER=""
#Remote IP
REMOTEIP=""
#Remote path.
REMOTEPATH=""
#Backup a MySQL database?
MYSQLBACKUP=""
#We need MySQL info so we can backup the data. If $MYSQLBACKUP="0", you can ignore this.
MYSQLUSER=""
MYSQLDATABASE=""

#Start our functions
function sanityCheck {

        #Check if /etc/debian_version exists
        if [[ ! -e /etc/debian_version ]];
        then
        echo "Only Debian 7 and Ubuntu 12.04+ are supported, exiting." | tee -a $LOGFILE
        exit 1;
    fi
    #Check for an SSH key.
    if [[ ! -e ~/.ssh/$SSHKEY ]];
    then
        echo "Fatal error, SSH key does not exist!" | tee -a $LOGFILE
        exit 1;
    fi
}

function main {

     if [[ $GZIP = "1" ]];
    then
        tar -zcvf $DATE.tar.gz $BACKUP | tee -a $GZIPLF
        rsync -avz -e "ssh -p $SSHPORT" $BACKUP $REMOTEUSER@$REMOTEIP:$REMOTEPATH
    else
        rsync -avz -e "ssh -p $SSHPORT" $BACKUP $REMOTEUSER@$REMOTEIP:$REMOTEPATH
    fi

}

function mySQL {
    #Start work on implementing MySQL support.
    #Sanity checking
    if [[ ! -e ~/.my.cnf ]];
    then
        echo "my.cnf file doesn't exist! Please create one to use this feature."
    else
        mysqldump -u $MYSQLUSER $MYSQLDATABASE > $MYSQLDATABASE.sql
    fi
}
#Run our functions
sanityCheck
#We need to check if the user wants MySQL to be backed up. We are going to run this before the main function so the sql database can be rsynced over also.
if [[ $MYSQLBACKUP = 0 ]];
then
    echo "MYSQLBACKUP set to false, not backing any MySQL databases up."
else
    mySQL
fi
main
