# shell-script-project-deploy-ecommerce-website

# E-Commerce Application deployment using a shell script #

```
This is a fictional online store that sells electronic devices. Its a LAMP 
stack application deployed on a single Linux server (Centos) node with
Apache server and uses MariaDB database & PHP.

```
The script does the following:

```
* Install, enable & start the Firewall 
* Install, start & enable httpd
* Configure the Firewall
* start & enable httpd
* Install, start & configure Mariadb service
* configure the /etc/my.cnf with the right port settings etc (MySQL config file)
* enable the required firewall rules to enable acess to sql port 3306 & reload the config
* create a database
* Load data inside the database, create a user & grant acccess using MySQL cmd line utility
* Load inventory data about the website products to the database using an external script
* Install required packages for the website such as php for php to connect to MySQL
* add the Firewall rules to allow access to port 80 & reload the firewall rules
* configure httpd to use index.html instead of index.html
* Download the code from github using git (and install git if not already installed on the machine)

```

```
https://google.github.io/styleguide/shellguide.html
https://www.tecmint.com/useful-tips-for-writing-bash-scripts-in-linux/
https://www.looklinux.com/how-to-connect-mysql-server-without-password-prompt/
```
