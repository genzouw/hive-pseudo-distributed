#!/usr/bin/env bash

readonly local HADOOP_HOST_NAME="hive.pseudo.distributed"
readonly local MYSQL_ROOT_PASS="root"

cat > /etc/hosts <<EOF
127.0.0.1     localhost
192.168.33.40 ${HADOOP_HOST_NAME}
EOF

# Start
yum -y update


# JDK1.8
cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.rpm" -O jdk-8u101-linux-x64.rpm
yum -y --nogpgcheck localinstall jdk-8u101-linux-x64.rpm
echo "export JAVA_HOME=/usr/java/default" > /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh


# CDH5
cd /opt/
wget http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm
yum -y --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm
rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
yum -y install hadoop-conf-pseudo


# Hadoop conf
sed -i "s/localhost/${HADOOP_HOST_NAME}/g" /etc/hadoop/conf/core-site.xml
sed -i "s/localhost/${HADOOP_HOST_NAME}/g" /etc/hadoop/conf/mapred-site.xml


# Format the Namenode
sudo -u hdfs hdfs namenode -format


# Disabled dfs permissions
sed -i 's#^</configuration>#<property><name>dfs.permissions.enabled</name><value>false</value></property></configuration>#' /etc/hadoop/conf/hdfs-site.xml


# Start HDFS
for service in `cd /etc/init.d ; ls hadoop-hdfs-*`
do
  service $service start
done


# Create directories
/usr/lib/hadoop/libexec/init-hdfs.sh


# Start YARN
service hadoop-yarn-resourcemanager start
service hadoop-yarn-nodemanager start
service hadoop-mapreduce-historyserver start


# Create hdfs directorie
sudo -u hdfs hadoop fs -mkdir /user/hdfs


# Cleanup
rm -f /opt/jdk-8u45-linux-x64.rpm
rm -f /opt/cloudera-cdh-5-0.x86_64.rpm
yum clean all


# MySQL
yum install -y \
  mysql \
  mysql-server \
;

chkconfig mysqld on
service mysqld start

/usr/bin/mysqladmin -u root password "${MYSQL_ROOT_PASS}"
/usr/bin/mysqladmin -u root -h "${HADOOP_HOST_NAME}" password "${MYSQL_ROOT_PASS}"


# Hive
yum install -y \
  hive \
  hive-metastore \
  hive-server2 \
;

mysql -u root -p${MYSQL_ROOT_PASS} --silent -e """\
create database metastore default character set utf8;
grant all privileges on metastore.* to hive@'%' identified by 'hive';
grant all privileges on metastore.* to hive@'localhost' identified by 'hive';
grant all privileges on metastore.* to hive@'${HADOOP_HOST_NAME}' identified by 'hive';
"""

chkconfig hive-server2 on
service hive-server2 start
chkconfig hive-metastore on
service hive-metastore start


# HiveServer2
cp /etc/hive/conf/hive-site.xml{,.bk}
cat /vagrant/hive-site.xml > /etc/hive/conf/hive-site.xml

cd /usr/lib/hive/lib/; ln -s /usr/local/src/mysql-connector-java-5.1.40/mysql-connector-java-5.1.40-bin.jar
ls /etc/init.d/{hadoop,hive}*| xargs -n 1 -i{} sudo {} restart

# Sqoop
yum install -y \
  sqoop \
;


# Append "vagrant" user to "hdfs" group
gpasswd -a vagrant hdfs
gpasswd -a vagrant hive


#
cd /usr/local/src
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.40.tar.gz
tar xf mysql-connector-java-5.1.40.tar.gz

