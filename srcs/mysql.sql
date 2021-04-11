CREATE DATABASE wpdb;
CREATE USER 'wpuser'@'localhost' identified by 'dbpassword';
GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;

