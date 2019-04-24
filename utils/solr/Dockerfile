FROM centos:7

# Install dependencies
RUN yum -y update && \
 yum -y install wget tar java-1.8.0-openjdk.x86_64

# Prepare environment 
ENV CATALINA_HOME /opt/tomcat 
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install Tomcat
ARG TOMCAT_MAJOR 9
ARG TOMCAT_VERSION 9.0.19

RUN wget http://apache.ip-connect.vn.ua/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
 tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
 rm apache-tomcat*.tar.gz && \
 mv apache-tomcat* ${CATALINA_HOME}

RUN chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD scripts $CATALINA_HOME
RUN chmod +x $CATALINA_HOME/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat && \
 useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
 chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /opt/tomcat

EXPOSE 8080
EXPOSE 8009

USER tomcat

# Install solr
ENV SOLR_VERSION 4.4.0

RUN wget https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz && \
tar xzf solr-${SOLR_VERSION}.tgz && \
mv solr-${SOLR_VERSION} solr && \
cd solr && \
cp example/webapps/solr.war example/solr/solr.war && \
cp example/lib/ext/* /opt/tomcat/lib/ && \
cp example/resources/log4j.properties /opt/tomcat/lib && \
cp example/webapps/solr.war /opt/tomcat/webapps/solr.war

# Configure baseDir for Solr
COPY solr.xml /opt/tomcat/conf/Catalina/localhost/solr.xml

CMD ["run.sh"]
