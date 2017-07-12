FROM debian:jessie

RUN apt-get update -qq
RUN apt-get install ruby ruby-dev build-essential --no-install-recommends -qqy
ENV REDMON_VERSION=2.4.6

ADD http://production.cf.rubygems.org/rubygems/rubygems-${REDMON_VERSION}.tgz /

RUN tar xvf /rubygems-${REDMON_VERSION}.tgz && cd /rubygems-${REDMON_VERSION} && ruby setup.rb
RUN gem install redmon

EXPOSE 4567

ENTRYPOINT ["redmon"]
