#!/usr/bin/env bash

# 0 - SKIP | 1 - INSTALL
INSTALL_GO=1
INSTALL_JAVA=1
INSTALL_MAVEN=1
INSTALL_DOCKER=1
INSTALL_DOCKER_REGISTRY=1
INSTALL_PYTHON_PIP=1
INSTALL_ANSIBLE=1
CONFIG_SSH_KEYS=1
CONFIG_MYENV=1

GO_VERSION="1.12.4"
JAVA_RELEASE="10"
JAVA_VERSION="10.0.2"
JAVA_PACKAGE="jdk"
MAVEN_VERSION="3.5.4"


initial_setup () {
    echo Initializing...
    sudo apt-get update
    sudo apt-get install -y \
    apt-transport-https \
    vim \
    git \
    expect \
    ftp \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    python-pip \
    python3-pip \
    ruby ruby-dev rubygems build-essential         
}

install_go () {    
    echo "Installing GO $GO_VERSION"    
    sudo curl -ksL \
        https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz \
        | sudo tar -xzf - -C /opt
   sudo update-alternatives --install /usr/bin/go go /opt/go/bin/go 100    
}

install_java () {

echo "Installing Java JDK ${JAVA_PACKAGE}-${JAVA_VERSION}"

sudo curl -ksL \
    https://download.java.net/java/GA/jdk10/${JAVA_VERSION}/19aef61b38124481863b1413dce1855f/13/openjdk-${JAVA_VERSION}_linux-x64_bin.tar.gz \
        | sudo tar -xzf - -C /opt \
        && sudo ln -s /opt/${JAVA_PACKAGE}-${JAVA_VERSION} /opt/jdk \
        && sudo rm -rf /opt/jdk/*src.zip \
        /opt/jdk/lib/missioncontrol \
        /opt/jdk/lib/visualvm \
        /opt/jdk/lib/*javafx* \
        /opt/jdk/jre/lib/plugin.jar \
        /opt/jdk/jre/lib/ext/jfxrt.jar \
        /opt/jdk/jre/bin/javaws \
        /opt/jdk/jre/lib/javaws.jar \
        /opt/jdk/jre/lib/desktop \
        /opt/jdk/jre/plugin \
        /opt/jdk/jre/lib/deploy* \
        /opt/jdk/jre/lib/*javafx* \
        /opt/jdk/jre/lib/*jfx* \
        /opt/jdk/jre/lib/amd64/libdecora_sse.so \
        /opt/jdk/jre/lib/amd64/libprism_*.so \
        /opt/jdk/jre/lib/amd64/libfxplugins.so \
        /opt/jdk/jre/lib/amd64/libglass.so \
        /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
        /opt/jdk/jre/lib/amd64/libjavafx*.so \
        /opt/jdk/jre/lib/amd64/libjfx*.so   

    sudo update-alternatives --install /usr/bin/java java /opt/jdk/bin/java 100 \
    && sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/bin/javac 100
}

install_maven () {
  echo "Installing MAVEN $MAVEN_VERSION"
  sudo curl -ksL \
        http://ftp.unicamp.br/pub/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
        | sudo tar -xzf - -C /opt

   update-alternatives --install /usr/bin/mvn mvn /opt/apache-maven-$MAVEN_VERSION/bin/mvn 100

}

install_ansible () {
    echo "Install Ansible"
    if ! apt -qq list ansible  2>/dev/null | grep -q installed ; then   

        sudo apt-get install ansible sshpass -y 
    else
        echo "Ansible already installed"
    fi


}

# DOCKER

docker_add_gpg_key(){
    echo Adding gpg key
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
}

docker_add_repository() {
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"
}


docker_install () {
    echo Installing docker...    
    docker_add_gpg_key
    docker_add_repository
    sudo apt-get update -y
    sudo apt-get install -y docker-ce    
    sudo groupadd docker
    sudo usermod -aG docker $(whoami)
    sudo gpasswd -a $(whoami) docker
}

docker_registry_cert() {
    echo "Getting Docker registry certs"
    sudo mkdir -p /etc/docker/certs.d/$DOCKER_REGISTRY_HOSTNAME
    sudo touch /etc/docker/certs.d/$DOCKER_REGISTRY_HOSTNAME/ca.crt
    sudo curl -s https://$GHE_TOKEN@raw.github.houston.entsvcs.net/amov/dockerlib-registry/master/2/certs/ca.pem -o /etc/docker/certs.d/$DOCKER_REGISTRY_HOSTNAME/ca.crt
}

docker_registry_host_entry() {
    sudo -- sh -c "echo '$DOCKER_REGISTRY_IP $DOCKER_REGISTRY_HOSTNAME' >> /etc/hosts"    
}

docker_registry_proxy() {
      sudo mkdir -p /etc/systemd/system/docker.service.d
      sudo bash -c 'echo "[Service]" >> /etc/systemd/system/docker.service.d/http-proxy.conf'
      sudo bash -c 'echo "Environment=\"HTTP_PROXY=http://16.85.88.10:8080/\" \"HTTPS_PROXY=http://16.85.88.10:8080/\" \"NO_PROXY=$DOCKER_REGISTRY_HOSTNAME\"
" >> /etc/systemd/system/docker.service.d/http-proxy.conf'

}

docker_registry_setup() {
    echo "Configuring DXC docker registry"    
    docker_registry_cert
    docker_registry_host_entry    
    docker_registry_proxy    
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}


install_docker () {
    docker_install
}

install_pip () {
    echo "Installing PIP"
    sudo curl -s  https://bootstrap.pypa.io/get-pip.py  | sudo  python - 'pip<10'
}

config_ssh_keys () {
    echo "Extracting ssh keys to ~/.ssh"
    ls -lh /home/vagrant/dev
    for a in $(ls -1 /home/vagrant/dev/keys/*.tar.gz); do tar -zxvf $a -C /home/vagrant/.ssh; done
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    ssh-keyscan -H $GHE_ENTERPRISE_ADDR >> ~/.ssh/known_hosts
}

install_env_defs (){
    echo "Configuring my env"
    sudo rm -Rf /tmp/myenv
    git clone https://github.com/alexlopes/myenv.git -- /tmp/myenv
    cd /tmp/myenv
    cp ssh/config /home/vagrant/.ssh/config
    cat Makefile
    make clean
    make
}

# BEGIN

#initial_setup

if [ $INSTALL_GO = 1 ]; then
  install_go
fi

if [ $INSTALL_JAVA = 1 ]; then
  install_java
  if [ $INSTALL_MAVEN = 1 ]; then
    install_maven
  fi
fi

if [ $INSTALL_ANSIBLE = 1 ]; then
  install_ansible
fi


if [ $INSTALL_PYTHON_PIP = 1 ]; then
  install_pip
fi

if [ $INSTALL_DOCKER = 1 ]; then
  install_docker
  if [ $INSTALL_DOCKER_REGISTRY = 1 ]; then
    docker_registry_setup
  fi
fi

if [ $CONFIG_SSH_KEYS = 1 ]; then
  config_ssh_keys
fi

if [ $CONFIG_MYENV = 1 ]; then
  install_env_defs
fi


