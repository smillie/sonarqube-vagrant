#!/bin/sh

JDK=jdk1.7.0_67
JDK_FILE=jdk-7u67-linux-x64.tar.gz

MYSQL_PASSWORD=admin

SONARQUBE=sonarqube-4.5.1
SONARQUBE_FILE=sonarqube-4.5.1.zip
SONARQUBE_USER=vagrant
SONARQUBE_GROUP=vagrant

SONARQUBE_DB_NAME=sonar
SONARQUBE_DB_USER=sonar
SONARQUBE_DB_PASS=sonar

# Update box
apt-get update -y
apt-get install -y -q unzip

# Install MySQL
echo mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD | debconf-set-selections
apt-get install -y -q mysql-server
apt-get clean

# Create database
mysql -u root -p$MYSQL_PASSWORD -e 'show databases;'| grep sonarqube > /dev/null
if [ "$?" = "1" ]; then
    cat > /tmp/database-setup.sql <<EOF
CREATE DATABASE $SONARQUBE_DB_NAME DEFAULT CHARACTER SET utf8;

CREATE USER '$SONARQUBE_DB_USER'@'%' IDENTIFIED BY '$SONARQUBE_DB_PASS';
GRANT ALL ON $SONARQUBE_DB_NAME.* TO '$SONARQUBE_DB_USER'@'%';

DROP USER ''@'localhost';
DROP USER ''@'sonarqube.localdomain';
EOF
# flush privileges;
    mysql -u root -p$MYSQL_PASSWORD < /tmp/database-setup.sql
fi

# Install Java
mkdir -p /opt
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi

# Install SonarQube
if [ ! -d /opt/$SONARQUBE ]; then
	unzip /vagrant/files/$SONARQUBE_FILE -d /opt/
	cp /vagrant/files/init.d.sh /etc/init.d/sonar
fi

sed -i "s%\wrapper.java.command.*%wrapper.java.command=/opt/$JDK/bin/java%"  /opt/$SONARQUBE/conf/wrapper.conf

echo "" >> /opt/$SONARQUBE/conf/sonar.properties
echo "sonar.jdbc.url=jdbc:mysql://localhost:3306/$SONARQUBE_DB_NAME?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance" >> /opt/$SONARQUBE/conf/sonar.properties
echo "sonar.jdbc.username=$SONARQUBE_DB_USER" >> /opt/$SONARQUBE/conf/sonar.properties
echo "sonar.jdbc.password=$SONARQUBE_DB_PASS" >> /opt/$SONARQUBE/conf/sonar.properties

chown -R $SONARQUBE_USER:$SONARQUBE_GROUP /opt/$SONARQUBE

if [ ! -d /usr/bin/sonar ]; then
    ln -s /opt/$SONARQUBE/bin/linux-x86-64/sonar.sh /usr/bin/sonar
fi
chmod 755 /etc/init.d/sonar
update-rc.d sonar defaults

# Start SonarQube
service sonar start
