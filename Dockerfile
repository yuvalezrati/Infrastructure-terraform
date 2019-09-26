FROM jenkins/jenkins
USER root
RUN yum -y update
RUN yum -y install ansible
EXPOSE 8080/tcp
EXPOSE 50000/tcp
USER jenkins

