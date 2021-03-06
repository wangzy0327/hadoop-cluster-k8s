#!/bin/bash

    cd /root/bootstrap

    # Don't override slaves、core-site.xml and yarn-site.xml
    rm -f $HADOOP_HOME/etc/hadoop/slaves $HADOOP_HOME/etc/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml

    # Copy original hadoop file to $HADOOP_CONF_DIR
    cp -a $HADOOP_HOME/etc/hadoop/* $HADOOP_CONF_DIR

    # Get this node's FQDN
    FQDN=`ping $HOSTNAME -c 1 | grep PING | awk '{print $2}'`
    
    sed -i '/'$FQDN'/d' /root/hosts
    echo "FQDN : "$FQDN"  MY_POD_IP : "$MY_POD_IP
    sed -i '$a '$FQDN'  '$MY_POD_IP'' /root/hosts
    # If this node is nameNode, set it's FQDN to core-site.xml file and yarn-site.xml file
    if [[ "$NODE_TYPE" =~ "NN" ]]; then
      # Apply custom config file context
      for cfg in ./*; do
        if [[ ! "$cfg" =~ bootstrap.sh ]]; then
          cat $cfg > $HADOOP_CONF_DIR/${cfg##*/}
        fi
      done

      # Set nameNode's FQDN to file
      echo $FQDN > $HADOOP_CONF_DIR/NameNode

      # Replace nameNode's FQDN
      sed -i 's/${NAME_NODE_FQDN}/'$FQDN'/g' `grep '${NAME_NODE_FQDN}' -rl $HADOOP_CONF_DIR`

      # Format HDFS if not formatted yet
      if [[ ! -e $HADOOP_CONF_DIR/hdfs-namenode-format.out ]]; then
        $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive &> $HADOOP_CONF_DIR/hdfs-namenode-format.out
        $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive &> $HADOOP_CONF_DIR/hdfs-namenode-format.out
      fi

      # Start hadoop nameNode daemon
      $HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
    fi

    # If this node is ResourceManager
    if [[ "$NODE_TYPE" =~ "RM" ]]; then
      $HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
    fi

    # If this node is nodeManager, add it to slave
    if [[ "$NODE_TYPE" =~ "NM" ]]; then
      sed -i '/'$FQDN'/d' $HADOOP_CONF_DIR/slaves
      echo $FQDN >> $HADOOP_CONF_DIR/slaves

      # Waiting nameNode set NAME_NODE_FQDN
      while [[ ! -e $HADOOP_CONF_DIR/NameNode || -z $NAME_NODE_FQDN ]]; do
        echo "Waiting for nameNode set NAME_NODE_FQDN" && sleep 2 && NAME_NODE_FQDN=`cat $HADOOP_CONF_DIR/NameNode`
      done

      # Start hadoop nodeManager daemon
      while [[ -z `curl -sf http://$NAME_NODE_FQDN:8088/ws/v1/cluster/info` ]]; do
        echo "Waiting for $FQDN" && sleep 2
      done
      $HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager
    fi

    # If this node is dataNode, add it to slave
    if [[ "$NODE_TYPE" =~ "DN" ]]; then
      sed -i '/'$FQDN'/d' $HADOOP_CONF_DIR/slaves
      echo $FQDN >> $HADOOP_CONF_DIR/slaves

      # Waiting nameNode set NAME_NODE_FQDN
      while [[ ! -e $HADOOP_CONF_DIR/NameNode || -z $NAME_NODE_FQDN ]]; do
        echo "Waiting for nameNode set NAME_NODE_FQDN" && sleep 2 && NAME_NODE_FQDN=`cat $HADOOP_CONF_DIR/NameNode`
      done

      # Start hadoop dataNode daemon
      while [[ -z `curl -sf http://$NAME_NODE_FQDN:50070` ]]; do
        echo "Waiting for $NAME_NODE_FQDN" && sleep 2
      done
      $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
    fi

    # keep running
    sleep infinity
