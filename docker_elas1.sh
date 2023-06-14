
#### 可选
docker network create es-net

docker pull   elasticsearch:6.8.6


rm -rf /elk/elasticsearch

mkdir -p /elk/elasticsearch/config
mkdir -p /elk/elasticsearch/data
mkdir -p /elk/elasticsearch/logs
chown -R 1000:1000  /elk/elasticsearch


###########################  
tee /elk/elasticsearch/config/es.yml <<-'EOF'

cluster.name: myes1
node.name: ${HOSTNAME}
network.host: 192.168.79.11
# 开启x-pack插件,用于添加账号密码
#xpack.security.enabled: true

EOF

######################
# chown -R 1000:1000  /elk/elasticsearch


############# 不使用    --privileged=true                   \

docker run -d --name ES             \
  -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
  -v /elk/elasticsearch/config/es.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
  -v /elk/elasticsearch/data:/usr/share/elasticsearch/data \
  -v /elk/elasticsearch/logs:/usr/share/elasticsearch/logs \
  -v /elk/elasticsearch/plugins:/usr/share/elasticsearch/plugins  \
  -e "discovery.type=single-node"     \
  --network=host                      \
  --restart=always                    \
  -p 9200:9200                        \
  -p 9300:9300                        \
  --privileged=true                   \
  elasticsearch:6.8.6



#### 处理插件 pinyin
##拷贝 elasticsearch-analysis-pinyin-6.8.6.zip
## 到 /elk/elasticsearch/plugins 目录下
mkdir /root/pinyin
unzip /software/es/elasticsearch-analysis-pinyin-6.8.6.zip -d  /root/pinyin
chown -R 1000:1000  /root/pinyin
mv /root/pinyin  /elk/elasticsearch/plugins/

### 处理插件  elasticsearch-analysis-ik-6.8.6.zip
##拷贝 elasticsearch-analysis-ik-6.8.6.zip
## 到 /elk/elasticsearch/plugins 目录下
mkdir /root/ik
unzip /software/es/elasticsearch-analysis-ik-6.8.6.zip -d  /root/ik
chown -R 1000:1000  /root/ik
mv /root/ik  /elk/elasticsearch/plugins/

#docker cp /root/pinyin  ES:/usr/share/elasticsearch/plugins/

### 重启ES
docker restart ES

### 测试pinyin插件 kibana里输入
POST /_analyze
{
  "text": ["如家酒店还不错"],
  "analyzer": "pinyin"
} 


####################################
docker exec -it ES bash
elasticsearch-setup-passwords interactive
输入密码  elastic123

192.168.79.11:9200
  elastic  elastic123







