FROM java:8-jdk

ADD gradlew .
ADD gradle gradle/
RUN ./gradlew
RUN rm -rf gradlew; rm -rf gradle
