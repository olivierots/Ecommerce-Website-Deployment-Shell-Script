  CREATE DATABASE ecomdb1;
  CREATE USER 'ecomuser1'@'localhost' IDENTIFIED BY 'Ecompassword12$';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser1'@'localhost';
  FLUSH PRIVILEGES;
