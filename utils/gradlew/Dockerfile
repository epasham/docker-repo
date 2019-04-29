FROM java:8-jdk

ADD gradlew .
RUN chmod +x /gradlew
ADD gradle gradle/
RUN ./gradlew
RUN rm -rf gradlew; rm -rf gradle
