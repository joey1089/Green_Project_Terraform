#!/bin/bash
yum update -y
yum -y remove httpd
yum -y remove httpd-tools
yum install -y httpd24 
systemctl start httpd
systemctl enable httpd

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
cd /var/www/html
EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo '<center><h1>This Amazon EC2 instance is located in Availability Zone:AZID </h1></center>' > /var/www/html/index.txt
    sed"s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
echo '<!DOCTYPE html>' >> /var/www/html/index.html
echo '<html lang="en">' >> /var/www/html/index.html
echo '<head><title>Welcome to LUIT </title></head>'  >> /var/www/html/index.html
echo '<body style="background-color:green;">' >> /var/www/html/index.html
echo '<h1 style="color:black;">Welcome Green Team !!!</h1>' >> /var/www/html/index.html

