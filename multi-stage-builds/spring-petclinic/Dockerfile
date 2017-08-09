# Stage-1
# 
FROM alpine/git
WORKDIR /app
RUN git clone https://github.com/spring-projects/spring-petclinic.git (1)

#Stage-2
FROM maven:3.5-jdk-8-alpine
WORKDIR /app
COPY --from=0 /app/spring-petclinic /app (2)

#Stage-3
RUN mvn install (3)
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=1 /app/target/spring-petclinic-1.5.1.jar /app (4)
CMD ["java -jar spring-petclinic-1.5.1.jar"]
