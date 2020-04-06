read -r -p "是否自动停止容器并删除springcloud-eureka相关镜像? [y/n] " input

if [[ $input == "Y" || $input == "y" ]]
then
    # 移除原有docker镜像
    for im in $(docker images | awk '{print $1}' | sed -n '2,$p')
    do
        result=$(echo $im | grep "springcloud-eureka")
        if [[ $result != "" ]]
        then
            imid=$(docker images | grep $im | awk '{print $3}')
            cmid=$(docker ps -a | grep $im | awk '{print $1}')
            echo $imid
            echo $cmid
            docker stop $cmid
            docker rm -f $cmid
            docker rmi -f $imid
            echo $im" has been removed"
        fi
    done
fi


read -r -p "请输入项目目录" dirpath

servicepath=$dirpath'/springcloud-eureka-service';

cd $servicepath;
mvn clean;
mvn install -Dmaven.test.skip=true;

# 打包镜像
cd $servicepath/springcloud-eureka-registry-service;
mvn package -Dmaven.test.skip=true docker:build
cd $servicepath/springcloud-eureka-consumer-service/springcloud-eureka-consumer-service-core;
mvn package -Dmaven.test.skip=true docker:build
cd $servicepath/springcloud-eureka-providerfirst-service/springcloud-eureka-providerfirst-service-core
mvn package -Dmaven.test.skip=true docker:build
cd $servicepath/springcloud-eureka-providersecond-service/springcloud-eureka-providersecond-service-core
mvn package -Dmaven.test.skip=true docker:build

# 构建docker网络
docker network create --driver bridge springcloud_bridge

# 启动容器
docker run -p 8761:8761 --name springcloud-8761 --network springcloud_bridge -d javendk/docker-springcloud-eureka-registry:1.0
docker run -p 8090:8090 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-providerfirst:1.0
docker run -p 8091:8091 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-providersecond:1.0
docker run -p 8080:8080 --network springcloud_bridge --env eureka.server.host=springcloud-8761 -d javendk/docker-springcloud-eureka-consumer:1.0
