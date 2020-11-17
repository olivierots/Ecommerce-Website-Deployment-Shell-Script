  CREATE DATABASE ecomdb1;
  CREATE USER 'ecomuser1'@'localhost' IDENTIFIED BY 'Password12$';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser1'@'localhost';
  FLUSH PRIVILEGES;
