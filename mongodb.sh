#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs" 
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python" "nginx" "httpd")

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

#check for root access
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR: $N Please run this script with root access" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access, Script is being installed" | tee -a $LOG_FILE
fi

#Validate function takes input as exit status, what command they tried to install
VALIDATE ()
    {
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$2 is $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
    }

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongodb server"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb server"  

sed -i 's/127.0.0.1 0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing Mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongodb server"