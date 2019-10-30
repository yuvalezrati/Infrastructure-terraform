FROM jenkins/jenkins
USER root
RUN apt -y update
RUN apt -y install python3-pip
RUN pip3 install ansible
RUN wget https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
RUN unzip terraform_0.12.12_linux_amd64.zip
RUN mv terraform /usr/bin
RUN rm -f terraform_0.12.12_linux_amd64.zip
RUN pip3 install awscli
RUN wget https://releases.hashicorp.com/packer/1.4.4/packer_1.4.4_linux_amd64.zip
RUN unzip packer_1.4.4_linux_amd64.zip
RUN mv packer /usr/bin
RUN rm -f packer_1.4.4_linux_amd64.zip
RUN apt -y install vim curl wget
USER jenkins