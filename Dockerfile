FROM ubuntu:14.04

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# update apt repositories
RUN apt-get update

#Install common repositories, unzip and git
RUN apt-get -y install software-properties-common
RUN apt-get install unzip
RUN apt-get install -y wget git

#Install java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

#Install sbt
RUN \
  wget https://dl.bintray.com/sbt/debian/sbt-0.13.6.deb && \
  dpkg -i sbt-0.13.6.deb && \
  apt-get update && \
  sudo apt-get install -y sbt

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

EXPOSE 9217

#Clone my-app and build it
RUN \
  cd ../usr/src && \
  git clone https://github.com/AMileikis/play-scala-docker.git && \
  cd play-scala-docker/my-app && \
  sbt dist

RUN mkdir -p /usr/src/play-scala-docker/app

RUN mv /usr/src/play-scala-docker/my-app/target/universal/my-app-1.0.0-SNAPSHOT.zip /usr/src/play-scala-docker/app

#Unzip the build, remove the leftover zip file
RUN cd /usr/src/play-scala-docker/app && \
    unzip my-app-1.0.0-SNAPSHOT.zip && \
    rm *.zip

#At run-time, this command is executed - run the application on port 9217
CMD /usr/src/play-scala-docker/app/my-app-1.0.0-SNAPSHOT/bin/my-app -Dhttp.port=9217

