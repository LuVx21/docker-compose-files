FROM maven:3-eclipse-temurin-8 AS builder
WORKDIR /build
ARG VERSION='2.0.0'

RUN apt-get update && apt-get install -y git
RUN git clone --depth=1 -b rocketmq-dashboard-${VERSION} https://github.com/apache/rocketmq-dashboard && cd rocketmq-dashboard && mvn clean package -Dmaven.test.skip=true && mv target/rocketmq-dashboard-*.jar /build/rocketmq-dashboard.jar

FROM eclipse-temurin:8-jre AS rocketmq-dashboard

WORKDIR /app
COPY --from=builder /build/rocketmq-dashboard.jar .
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar ./rocketmq-dashboard.jar" ]
