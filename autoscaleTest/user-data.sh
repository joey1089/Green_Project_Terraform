  #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    echo '<head><title>Terraform Deployment Test</title></head>'  >> /var/www/html/index.html
    echo '<body style="background-color:rgb(109, 185, 109);">' >> /var/www/html/index.html
    echo '<h1 style="color:rgb(100, 27, 27);">Terraform deployed web server-03.</h1>' >> /var/www/html/index.html