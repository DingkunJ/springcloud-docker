# 移除原有docker镜像

for m in $(docker ps -a | awk '{print $2}' | sed -n '2,$p')
do
    result=$(echo $m | grep "springcloud-eureka") # 这里的等号不能有空格
    if [[ $result != "" ]]              # 这里的等号要有空格
    then
        mid=$(docker ps -a | grep $m | awk '{print $1}')
        echo $mid
        docker rm -f $mid
    fi
done

for im in $(docker images | awk '{print $1}' | sed -n '2,$p')
do
    result=$(echo $im | grep "springcloud-eureka") # 这里的等号不能有空格
    if [[ $result != "" ]]              # 这里的等号要有空格
    then
        imid=$(docker images | grep $im | awk '{print $3}')
        docker rmi -f $imid
        echo $im" has been removed"
    fi
done

dirpath=$1

servicepath=$dirpath'/springcloud-eureka-service';

cd $servicepath;
mvn clean;
mvn install -Dmaven.test.skip=true;

cd $servicepath/springcloud-eureka-registry-service;
mvn package -Dmaven.test.skip=true docker:build

cd $servicepath/springcloud-eureka-consumer-service/springcloud-eureka-consumer-service-core;
mvn package -Dmaven.test.skip=true docker:build

cd $servicepath/springcloud-eureka-providerfirst-service/springcloud-eureka-providerfirst-service-core
mvn package -Dmaven.test.skip=true docker:build
cd $servicepath/springcloud-eureka-providersecond-service/springcloud-eureka-providersecond-service-core
mvn package -Dmaven.test.skip=true docker:build

docker network create --driver bridge springcloud_bridge

# 启动容器
docker run -p 8761:8761 --name springcloud-8761 --network springcloud_bridge -d javendk/docker-springcloud-eureka-registry:1.0
docker run -p 8090:8090 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-providerfirst:1.0
docker run -p 8091:8091 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-providersecond:1.0
docker run -p 8080:8080 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-consumer:1.0
