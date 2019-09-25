FROM jenkins/jenkins
USER root
RUN apt -y update
RUN apt -y install ansible
EXPOSE 8080/tcp
EXPOSE 50000/tcp
USER jenkins

