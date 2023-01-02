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
curl http://169.254.169.254/latest/meta-data/instance-id -o index.html
echo '<!DOCTYPE html>' > /var/www/html/index.html
echo '<html lang="en">' >> /var/www/html/index.html
echo '<head><title>Welcome to LUIT </title></head>'  >> /var/www/html/index.html
echo '<body style="background-color:green;">' >> /var/www/html/index.html
echo '<h1 style="color:black;">Welcome Green Team !!!</h1>' >> /var/www/html/index.html
#curl https://raw.githubusercontent.com/hashicorp/learn-terramino/master/index.php -O
