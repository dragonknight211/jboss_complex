#!/bin/bash
#
# setup_jboss.sh
#
# Download and extract JBoss, config it to listen on all IP address and set Jboss to be daemon and auto start with machine

DOWNLOAD_LINK="http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz";
TARGET_DIR="/opt";
JBOSS_HOME="$TARGET_DIR/Jboss/"
# Check if the script is ran as root
if [ `id -u` -ne 0 ]; then
    # Not the root
    echo "Please make sure this script is ran as root!";
    exit 1;
fi

# Create JBOSS_HOME directory and cd there to prepare
mkdir -p $JBOSS_HOME;
cd $TARGET_DIR;

# Download and extract Jboss
wget $DOWNLOAD_LINK;
jboss_tar_file=${DOWNLOAD_LINK##*/};
echo "Extracting $jboss_tar_file";
tar xzvf $jboss_tar_file -C $JBOSS_HOME --strip=1
chown -R vagrant:vagrant $JBOSS_HOME;

# Modify standalone profile to listen on all IP addresses
sed -iE "s/<inet-.*127.*/<any-ipv4-address\/>/" "$JBOSS_HOME/standalone/configuration/standalone.xml"

# Make JBoss a Daemon and set it to automatically startic
ln -s $JBOSS_HOME/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss
chmod +x /etc/init.d/jboss
# chkconfig --level 356 jboss on

# Configuration dir for JBOSS
mkdir /etc/jboss-as
echo -e "JBOSS_HOME=$JBOSS_HOME" > /etc/jboss-as/jboss-as.conf
echo "JBOSS_CONSOLE_LOG=/var/log/jboss-console.log" >> /etc/jboss-as/jboss-as.conf
echo "JBOSS_USER=root" >> /etc/jboss-as/jboss-as.conf

# Download a simple Helloworld to deply to Jboss
cd "$JBOSS_HOME/standalone/deployments/";
#wget --no-check-certificate https://github.com/spagop/quickstart/raw/master/management-api-examples/mgmt-deploy-application/application/jboss-as-helloworld.war
wget --no-check-certificate https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war


# Start JBoss
service jboss start
