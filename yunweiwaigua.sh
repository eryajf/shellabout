#!/bin/bash

#author:eryajf
#blog:www.eryajf.net
#time:2018-7
set -e
ip=192.168.10.10

nginx(){
    dir=`pwd`
    [ -d /usr/local/nginx ] && echo "检测到本机已经安装ngixn，请检查之后再进行安装！" && exit 0
    yum install wget gcc gcc-c++ pcre pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    wget $ip/pack/nginx-1.9.3-1.x86_64.rpm
    yum -y install nginx-1.9.3-1.x86_64.rpm
    ln -s /usr/local/nginx/sbin/* /usr/local/sbin
    rm -rf $dir/nginx*

}

tomcat(){
    dir=`pwd`
    [ -d /usr/local/tomcat ] && echo "检测到本机已经安装tomcat，请检查之后再进行安装！" && exit 0
    yum -y install wget && wget $ip/pack/tomcat.tar.gz
    tar xf tomcat.tar.gz && mv tomcat /usr/local/tomcat
    rm -rf $dir/tomcat.tar.gz
}

jdk(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/jdk.tar.gz
    tar xf jdk.tar.gz -C /usr/local/
    echo 'JAVA_HOME=/usr/local/jdk1.8.0_191' >> /etc/profile
    echo 'PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
    echo 'export PATH' >> /etc/profile
    echo "进入root目录,运行 source /etc/profile  命令正式完成！"
    rm -rf $dir/jdk*
}

maven(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/maven.tar.gz
    tar -xf maven.tar.gz && mv maven /usr/local/maven
    rm -rf $dir/maven.tar.gz
    echo 'MAVEN_HOME=/usr/local/maven' >> /etc/profile
    echo 'PATH=$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin' >> /etc/profile
    echo "进入root目录,运行 source /etc/profile 命令正式完成！"
}

mysql(){
    yum -y install wget
    wget $ip/pack/mysql-5.6.16.tar.gz && echo "获取mysql安装包"
    mqnu=`cat /etc/passwd | grep mysql |wc -l`
    if [ $mqnu -ne 1 ];then
        echo "mysql用户不存在，新建用户"
        groupadd mysql
        useradd -g mysql -s /sbin/nologin mysql
    else
        echo "mysql已经存在"
    fi

    yum install gcc gcc-c++ autoconf automake zlib* libxml* ncurses-devel libtool-ltdl-devel* make cmake -y

    [ ! -d /usr/local/mysql/data ] && mkdir -p /usr/local/mysql/data && chown -R mysql.mysql /usr/local/mysql
    echo "开始编译安装！！"
    tar -xf mysql-5.6.16.tar.gz && cd mysql-5.6.16 && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci && make && make install
    echo "注册为服务！！"
    cd /usr/local/mysql/scripts && ./mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
    cd /usr/local/mysql/support-files && cp mysql.server /etc/rc.d/init.d/mysql && yes | cp my-default.cnf /etc/my.cnf && chkconfig --add mysql && chkconfig mysql on && service mysql start

    echo 'PATH=/usr/local/mysql/bin:$PATH' >> /etc/profile
    echo 'export PATH' >> /etc/profile

    rm -rf $dir/mysql*
}

node(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/node-v10.6.0-linux-x64.tar.xz
    tar -xf node-v10.6.0-linux-x64.tar.xz && mv node-v10.6.0-linux-x64  /usr/local/node
    rm -rf $dir/*node*
        echo 'NODE=/usr/local/node' >> /etc/profile
        echo 'PATH=$PATH:$NODE/bin' >> /etc/profile
    echo "进入root目录,运行 source /etc/profile 加载并可使用 node -v检验安装！"
}

php(){
    [ -d /usr/local/php ] && exho "已经安装PHP" && exit 0
    dir=`pwd`
    yum -y install wget && wget $ip/pack/php-7.0.25.tar.gz
    [ ! -f $dir/php-7.0.25.tar.gz ] && exit 1
    yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel mysql pcre-devel curl-devel libxslt-devel openssl-devel
    tar -xf php-7.0.25.tar.gz && cd php-7.0.25 && ./configure --prefix=/usr/local/php --with-curl --with-freetype-dir --with-gd \
    --with-gettext --with-iconv-dir --with-kerberos --with-libdir=lib64 --with-libxml-dir \
    --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite \
    --with-pear --with-png-dir --with-xmlrpc --with-xsl --with-zlib --enable-fpm \
    --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf \
    --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop \
    --enable-soap --enable-sockets --enable-sysvsem --enable-xml --enable-zip  && make && make test && make install
    \cp php.ini-development /usr/local/php/etc/php.ini
    \cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
    \cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
    \cp -R ./sapi/fpm/php-fpm /etc/init.d/php-fpm
    /etc/init.d/php-fpm
    rm -rf $dir/*php*
}

zabbix(){
    #安装被监控端的软件
    dir=`pwd`
    yum install wget curl -y

    wget $ip/pack/zabbix-agent-3.4.11-1.el7.x86_64.rpm

    a=$(pwd)
    b=$(hostname)
    yum -y install $a/zabbix-agent-3.4.11-1.el7.x86_64.rpm
    #修改相应的配置文件
    sed -i '97cServer=192.168.106.23' /etc/zabbix/zabbix_agentd.conf
    sed -i '138cServerActive=192.168.106.23' /etc/zabbix/zabbix_agentd.conf
    sed -i "149cHostname=$b"  /etc/zabbix/zabbix_agentd.conf
    #开启服务
    systemctl restart zabbix-agent
    systemctl enable zabbix-agent

    rm -rf $dir/zabbix*

}
py3(){
    dir=`pwd`
    yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel wget gcc gcc-c++
    yum -y install wget && wget $ip/pack/Python-3.6.3.tgz
    tar -xf Python-3.6.3.tgz && mv Python-3.6.3 /usr/local/Python-3.6.3 && cd /usr/local/Python-3.6.3
    ./configure --prefix=/usr/local && make && make altinstall
    cd /usr/bin && mv  python python.backup && ln -s /usr/local/bin/python3.6 /usr/bin/python &&ln -s /usr/local/bin/python3.6 /usr/bin/python3 && ln -s /usr/local/bin/pip3.6 /usr/bin/pip

    sed -i '1s/python/python2/g' /usr/bin/yum
    sed -i '1s/python/python2/g' /usr/libexec/urlgrabber-ext-down

    rm -rf $dir/Python-3.6.3.tgz
}
redis(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/redis-4.0.6.tar.gz
    tar -xf redis-4.0.6.tar.gz && cd redis-4.0.6 && make && make install
    sed  -i '136s/no/yes/g' redis.conf
    sed -i '166s/notice/warning/g' redis.conf
    mv $dir/redis-4.0.6 /usr/local/redis
    /usr/local/redis/src/redis-server /usr/local/redis/redis.conf
    rm -rf $dir/redis-4.0.6.tar.gz
}
idocker(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/ca.crt
    grep "idocker.io" /etc/hosts || echo "$ip idocker.io" >> /etc/hosts
    mkdir -p /etc/docker/certs.d/idocker.io
    \mv ca.crt /etc/docker/certs.d/idocker.io
    yum -y install ntpdate && ntpdate -u cn.pool.ntp.org
    echo -e  "\e[33m 现在可以在加载配置并重启docker之后，通过 docker login -u admin -p admin123 idocker.io 登陆私服！如果登陆失败，可能是主机时间与私服时间不同步导致的！\e[39m"
}
autotrash(){
    dir=`pwd`
    yum -y install wget && wget $ip/pack/autotrash.tar.gz
    tar xf autotrash.tar.gz && cd autotrash-0.2.1
    python setup.py install && cp autotrash /usr/bin/
    yum -y install ntpdate && ntpdate -u cn.pool.ntp.org
    echo "@daily /usr/bin/autotrash -d 7" >> /var/spool/cron/root
    rm -rf $dir/autotrash.tar.gz
}


OPTION=$(whiptail --title "一步到位-安装脚本" --menu "请选择想要安装的项目，上下键进行选择，回车即安装！" 25 55 15 \
"1" "安装-nginx-1.9.3" \
"2" "安装-jdk-1.8" \
"3" "安装-tomcat-8" \
"4" "安装-mysq-l-5.6" \
"5" "安装-node-10" \
"6" "安装-maven-3.3" \
"7" "安装-php-7" \
"8" "安装-zabbix3.4客户端" \
"9" "安装-py-3.6" \
"10" "安装-redis-4" \
"11" "配置docker私服连接" \
"12" "配置清空7天前回收站内容" \
"13" "暂时未定义" \
"14" "暂时未定义" \
"15" "暂时未定义"  3>&1 1>&2 2>&3  )

exitstatus=$?

if [ $exitstatus = 0 ]; then
    if [ $OPTION = 1 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nnginx\n，\n现\n在\n开\n始\n安\n装\nnginx\n****  \e[39m"
        sleep 3
        nginx
    elif [ $OPTION = 2 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\njdk\n，\n现\n在\n开\n始\n安\n装\njdk\n****  \e[39m"
        sleep 3
        jdk
    elif [ $OPTION = 3 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\ntomcat\n，\n现\n在\n开\n始\n安\n装\ntomcat\n****  \e[39m"
        sleep 3
        tomcat
    elif [ $OPTION = 4 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nmysql\n，\n现\n在\n开\n始\n安\n装\nmysql\n****  \e[39m"
        sleep 3
        mysql
    elif [ $OPTION = 5 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nnode\n，\n现\n在\n开\n始\n安\n装\nnode\n****  \e[39m"
        sleep 3
        node
    elif [ $OPTION = 6 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nmaven\n，\n现\n在\n开\n始\n安\n装\nmaven\n****  \e[39m"
        sleep 3
        maven
    elif [ $OPTION = 7 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nphp\n，\n现\n在\n开\n始\n安\n装\nphp\n****  \e[39m"
        sleep 3
        php
    elif [ $OPTION = 8 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nzabbix-agent\n，\n现\n在\n开\n始\n安\n装\nzabbix-agent\n****  \e[39m"
        sleep 3
        zabbix
    elif [ $OPTION = 9 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\npy-3.6\n，\n现\n在\n开\n始\n安\n装\npy-3.6\n****  \e[39m"
        sleep 3
        py3
    elif [ $OPTION = 10 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nredis-4\n，\n现\n在\n开\n始\n安\n装\nredis-4\n****  \e[39m"
        sleep 3
        redis
    elif [ $OPTION = 11 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\ndocker私服\n，\n现\n在\n开\n始\n安\n装\ndocker私服\n****  \e[39m"
        sleep 3
        idocker
    elif [ $OPTION = 12 ];then
        echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\nautotrash\n，\n现\n在\n开\n始\n安\n装\nautotrash私服\n****  \e[39m"
        sleep 3
        autotrash
    else
        echo "****您选择的安装项目暂时未定义！****"
    fi

else
    echo "You chose Cancel."
fi
