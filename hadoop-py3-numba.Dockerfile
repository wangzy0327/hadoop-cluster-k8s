FROM centos:7.5.1804
MAINTAINER wangzy0327@qq.com

ADD jdk-8u251-linux-x64.tar.gz /opt
ADD hadoop-2.9.2.tar.gz /opt
ADD Python-3.8.2.tgz /root

WORKDIR /root

RUN yum makecache && yum install -y which bc && \
    yum install -y wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel && \
    cd Python-3.8.2/ && \
    ./configure prefix=/usr/local/python3 && \
    make && make install && \
    ln -sf /usr/local/python3/bin/python3.8 /usr/bin/python3 && \
    ln -sf /usr/local/python3/bin/pip3.8 /usr/bin/pip3 && \
    pip3 install numpy numba pandas && \
    yum clean all && \
    cd /root && rm -rf Python-3.8.2.tgz && rm -rf Python-3.8.2
    
    

ENV JAVA_HOME /opt/jdk1.8.0_251
ENV HADOOP_HOME /opt/hadoop-2.9.2
ENV PATH $JAVA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
