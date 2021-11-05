CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY '<your_password>';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER
    ON wordpress.*
    TO wordpress@localhost;

FLUSH PRIVILEGES;
quit
