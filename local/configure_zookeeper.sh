cd /local && wget http://apache.cs.utah.edu/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar -zxvf /local/zookeeper-3.4.6.tar.gz
cd /local/zookeeper-3.4.6/src/c
./configure
make
sudo make install
cd ../../conf
echo "tickTime=5500" > zoo.cfg
echo "dataDir=/var/lib/zookeeper" >> zoo.cfg
echo "clientPort=2181" >> zoo.cfg
#cd /local/zookeeper-3.4.6/ && sudo bin/zkServer.sh start
