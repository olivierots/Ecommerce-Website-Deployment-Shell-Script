#!/bin/bash
#
# Automate ECommerce Application Deployment
# Author: Olivier Ots. 
# Date: 17.11.2020


###########################################################
# re-usable block of code to Print a message in a given color.
# Arguments:
#   Colour. eg: green, red
# 
# notes:
# echo -e "\033[0;32m Hello there ...\033[0m" ==> printed in green colour
# NC = no colour
#
###########################################################

function print_color(){
  NC='\033[0m' # No Color

  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}



#####################################################################
# re-usable block of code to Check the status of a given service. If not active exit script
# Arguments:
#   Service Name. eg: firewalld, mariadb
#
#  notes:
#  sudo systemctl is-active <service> ==> check if a service is active
#
####################################################################

function check_service_status(){
  service_is_active=$(sudo systemctl is-active $1)

  if [ $service_is_active = "active" ]
  then
    echo "$1 is active and running"
  else
    echo "$1 is not active/running"
    exit 1
  fi
}


########################################################################
# re-usable block of code to Check the status of a firewalld rule. If not configured exit
# Arguments:
#   Port Number. eg: 3306, 80
########################################################################

function is_firewalld_rule_configured(){

  firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

  if [[ $firewalld_ports == *$1* ]]
  then
    echo "FirewallD has port $1 configured"
  else
    echo "FirewallD port $1 is not configured"
    exit 1
  fi
}


##############################################################################
# re-usable block of code to Check if a given item is present in an output
# Arguments:
#   1 - Output
#   2 - Item
#   
#   this function will be used to check whether the content inside
#   the website exist
#   
#############################################################################

function check_item(){
  if [[ $1 = *$2* ]]
  then
    print_color "green" "Item $2 is present on the web page"
  else
    print_color "red" "Item $2 is not present on the web page"
  fi
}



echo "---------------- Setup Database Server ------------------"

# Install and configure firewalld
print_color "green" "Installing FirewallD.. "
sudo yum install -y firewalld

print_color "green" "Installing FirewallD.. "
sudo service firewalld start
sudo systemctl enable firewalld

# Check FirewallD Service is running
check_service_status firewalld

# Install and configure Maria-DB
print_color "green" "Installing MariaDB Server.."
sudo yum install -y mariadb-server

print_color "green" "Starting MariaDB Server.."
sudo service mysqld start
sudo systemctl enable mysqld 
# Check FirewallD Service is running
check_service_status mysqld

# Configure Firewall rules for Database
print_color "green" "Configuring FirewallD rules for database.."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306


# Configuring Database
print_color "green" "Setting up database.."
cat > setup-db.sql <<-EOF
  CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'Ecompassword12$';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF

# configure passworless db access ==> https://www.looklinux.com/how-to-connect-mysql-server-without-password-prompt/
mysql -u root < setup-db.sql

# Loading inventory into Database
print_color "green" "Loading inventory data into database"
cat > db-load-script.sql <<-EOF
USE ecomdb1;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

mysql -u root < db-load-script.sql

mysql_db_results=$( mysql -u root -e "use ecomdb; select * from products;")

if [[ $mysql_db_results == *Laptop* ]]
then
  print_color "green" "Inventory data loaded into MySQl"
else
  print_color "red" "Inventory data not loaded into MySQl"
  exit 1
fi


print_color "green" "---------------- Setup Database Server - Finished ------------------"

print_color "green" "---------------- Setup Web Server ------------------"

# Install web server packages
print_color "green" "Installing Web Server Packages .."
sudo yum install -y httpd php php-mysql

# Configure firewalld rules
print_color "green" "Configuring FirewallD rules.."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

# Update httpd.conf otherwise index.php will be picked up default
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
print_color "green" "Start httpd service.."
sudo service httpd start
sudo systemctl enable httpd

# Check FirewallD Service is running
check_service_status httpd

# Download code
print_color "green" "Install GIT.."
sudo yum install -y git   # install git if not yet installed
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

print_color "green" "Updating index.php.."
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "---------------- Setup Web Server - Finished ------------------"

# Test elements / content from the website - Script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
  check_item "$web_page" $item
done




