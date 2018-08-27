FROM jenkins/jenkins:lts

USER root
RUN apt-get update \
      && apt-get install -y sudo curl\
      && apt-get install -y libltdl7 \
      apt-transport-https \
      ca-certificates \
      software-properties-common\
      && rm -rf /var/lib/apt/lists/*
# https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository      
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# RUN apt-key fingerprint 0EBFCD88
# RUN sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# RUN sudo apt-get install docker-ce

RUN apt update
RUN apt install apt-transport-https ca-certificates curl software-properties-common -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt update -y
RUN apt-cache policy docker-ce
RUN apt install docker-ce -y
# RUN sudo systemctl status docker

# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# RUN apt-get update
# RUN apt-cache policy docker-ce
# RUN apt-get install -y docker-ce
# RUN systemctl status docker

RUN sudo usermod -aG docker jenkins

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
# RUN usermod -a -G docker jenkins

# getting the docker-cli
# --- Attention: docker.sock needs to be mounted as volume in docker-compose.yml
# see: https://issues.jenkins-ci.org/browse/JENKINS-35025
# see: https://get.docker.com/builds/
# see: https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Custom+Build+Environment+Plugin#CloudBeesDockerCustomBuildEnvironmentPlugin-DockerinDocker
# RUN curl -sSL -o /bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest
# RUN chmod +x /bin/docker

USER jenkins

# installing specific list of plugins. see: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# Adding default Jenkins Seed Job
COPY jobs/job-dsl-seed-job.xml /usr/share/jenkins/ref/jobs/job-dsl-seed-job/config.xml

############################################
# Configure Jenkins
############################################
# Jenkins settings
COPY config/config.xml /usr/share/jenkins/ref/config.xml

# Jenkins Settings, i.e. Maven, Groovy, ...
COPY config/hudson.tasks.Maven.xml /usr/share/jenkins/ref/hudson.tasks.Maven.xml
COPY config/hudson.plugins.groovy.Groovy.xml /usr/share/jenkins/ref/hudson.plugins.groovy.Groovy.xml
COPY config/maven-global-settings-files.xml /usr/share/jenkins/ref/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml

# SSH Keys & Credentials
COPY config/credentials.xml /usr/share/jenkins/ref/credentials.xml
COPY config/ssh-keys/cd-demo /usr/share/jenkins/ref/.ssh/id_rsa
COPY config/ssh-keys/cd-demo.pub /usr/share/jenkins/ref/.ssh/id_rsa.pub

# tell Jenkins that no banner prompt for pipeline plugins is needed
# see: https://github.com/jenkinsci/docker#preinstalling-plugins
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
