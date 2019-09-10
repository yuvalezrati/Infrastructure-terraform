FROM jenkins/jenkins:2.194 
USER root
EXPOSE 8080/tcp
EXPOSE 50000/tcp
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && apt update \
    && apt install -y ansible && apt install -y vim && apt install -y locate && apt install -y sudo && apt install -y python3 && apt install -y default-jre && apt install -y nodejs \
    && apt install -y awscli && apt install -y mongodb && apt-get install -y
USER jenkins

