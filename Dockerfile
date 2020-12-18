FROM maven:3-openjdk-11-slim
ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/share/myservice/spring-boot-prometheus-0.0.1-SNAPSHOT.jar"]
ADD target/spring-boot-prometheus-0.0.1-SNAPSHOT.jar  /usr/share/myservice/lib
ARG JAR_FILE
ADD target/${JAR_FILE} /usr/share/myservice/spring-boot-prometheus-0.0.1-SNAPSHOT.jar
EXPOSE 8080
