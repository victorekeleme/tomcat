#!/bin/bash

TOMCAT="https://downloads.apache.org/tomcat/tomcat-9/v9.0.70/bin/apache-tomcat-9.0.70.zip"

#checking for java
java -version

if [ $? -eq 0 ]
then
	echo "Java is already installed"
else
	echo "Installing Java"
	sudo yum install java-1.8.0-openjdk-devel -y
fi

#Installing necessary packages
sudo yum install wget unzip -y


#Check if tomcat directory exists
if [ -d "/opt/tomcat" ]
then
	echo "Directory exists"
else
	sudo mkdir /opt/tomcat
fi


#Create System user for tomcat
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat


cd /opt/tomcat

#download tomcat
sudo wget $TOMCAT

#unzip zipped package
sudo unzip apache-tomcat-*.zip

#clean up zip package
sudo rm -rf /opt/tomcat/apache-tomcat-*.zip

#creating a soft link 
sudo ln -s /opt/tomcat/apache-tomcat-* /opt/tomcat/latest

#changing ownership to tomcat user
sudo chown -R tomcat: /opt/tomcat/apache-tomcat-* /opt/tomcat/latest

#giving executable permissions to all .sh in /bin
sudo chmod +x /opt/tomcat/latest/bin/*.sh

#setting up tomcat.service in systemd

if [ -e "/etc/systemd/system/tomcat.service" ]
then
	echo "You already have tomcat.service in systemd"
	exit 0
else
	sudo touch /etc/systemd/system/tomcat.service

	echo "[Unit]" >> /etc/systemd/system/tomcat.service
	echo "Description=Tomcat Service" >> /etc/systemd/system/tomcat.service
	echo "After=network.target" >> /etc/systemd/system/tomcat.service
	echo " " >> /etc/systemd/system/tomcat.service
	echo "[Service]" >> /etc/systemd/system/tomcat.service
	echo "Type=forking" >> /etc/systemd/system/tomcat.service
	echo "User=tomcat" >> /etc/systemd/system/tomcat.service
	echo "Group=tomcat" >> /etc/systemd/system/tomcat.service
	echo " " >> /etc/systemd/system/tomcat.service
	echo "Environment=JAVA_HOME=/usr/lib/jvm/jre" >> /etc/systemd/system/tomcat.service
	echo "Environment=JAVA_OPTS=-Djava.security.egd=file:///dev/urandom" >> /etc/systemd/system/tomcat.service
	echo "Environment=CATALINA_BASE=/opt/tomcat/latest" >> /etc/systemd/system/tomcat.service
	echo "Environment=CATALINA_HOME=/opt/tomcat/latest" >> /etc/systemd/system/tomcat.service
	echo "Environment=CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid" >> /etc/systemd/system/tomcat.service
	echo "Environment=CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC" >> /etc/systemd/system/tomcat.service
	echo " " >> /etc/systemd/system/tomcat.service
	echo "ExecStart=/opt/tomcat/latest/bin/startup.sh" >> /etc/systemd/system/tomcat.service
	echo "ExecStop=/opt/tomcat/latest/bin/shutdown.sh" >> /etc/systemd/system/tomcat.service
	echo " " >> /etc/systemd/system/tomcat.service
	echo "[Install]" >> /etc/systemd/system/tomcat.service
	echo "WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service

	#Reloading system daemon
	sudo systemctl daemon-reload
	
	#starting tomcat service
	sudo systemctl start tomcat
	if [ $? -eq 0 ]
	then
		echo "Tomcat service started"
	else:
		echo "Please Use \"sudo systemctl status tomcat\" to diagnose"
	fi

	echo "You've successfully installed tomcat as a service"
	echo "use sudo systemctl start|stop|restart|enable|disable tomcat"

fi
