FROM centos:7.5.1804
MAINTAINER wangzy0327@qq.com

ADD CentOS-Base.repo /etc/yum.repos.d
ADD jdk-8u251-linux-x64.tar.gz /opt
ADD hadoop-2.9.2.tar.gz /opt

RUN yum install -y which

ENV JAVA_HOME /opt/jdk1.8.0_251
ENV HADOOP_HOME /opt/hadoop-2.9.2
ENV PATH $JAVA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
