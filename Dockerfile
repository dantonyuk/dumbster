FROM maven:3.6.3-ibmjava-8-alpine as builder

WORKDIR /src

COPY ./pom.xml ./pom.xml
RUN mvn dependency:go-offline -B

COPY ./src ./src
RUN mvn package

FROM openjdk:8u212-jre-alpine3.9

WORKDIR /app

ADD https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.18/slf4j-api-1.7.18.jar /app/slf4j-api.jar
ADD https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/1.7.18/slf4j-simple-1.7.18.jar /app/slf4j-simple.jar
COPY --from=builder /src/target/dumbster-1.8-SNAPSHOT.jar /app/dumbster.jar

ENTRYPOINT ["java", \
    "-cp", "slf4j-api.jar:slf4j-simple.jar:dumbster.jar", \
    "-Dorg.slf4j.simpleLogger.defaultLogLevel=trace", \
    "com.dumbster.smtp.SimpleSmtpServer"]
