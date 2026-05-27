FROM jenkins/jenkins:latest

USER root

RUN apt-get update && apt-get install -y \
    ansible \
    sshpass \
    git \
    curl \
    docker.io \
    && apt-get clean

USER jenkins
