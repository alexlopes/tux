# Vagrantfile

## O que vem ? 
- Debian GNU/Linux 9.3 (stretch)

## Opcional:

- Binário para Go lang
- Java JDK 10
- Maven
- Ansible
- Python PIP
- Docker API (from Stable)
- Docker Registry
- Configuração de chave SSH 
- Ambiente customizado com [myenv](https://github.com/alexlopes/myenv)

## Como funciona ?

No início do arquivo [provision.sh](https://github.houston.entsvcs.net/alex-lopes/tux/blob/master/vagrant/provision.sh) existem variáveis que decidem o que será instalado, caso o valor da variável seja 0 será dado skip, valendo 1 irá instalar a ferramenta ou configuração. (por padrão todos valem 1)

## O que voce precisa ter?

- [Vagrant](https://www.vagrantup.com/downloads.html) + [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (últimas versões)
- ``` vagrant plugin install vagrant-proxyconf```

### Caso deseje a instalação full 

- Você deve possuir as variáveis de ambiente abaixo setadas na máquina host:

Linux / Git Bash env
```
export DOCKER_REGISTRY_HOSTNAME="<docker registry hostnamem>"
export DOCKER_REGISTRY_IP="<docker registry ip>"
export SSH_USER="<ansible ssh user>"
export SSH_PASS="<ansible SSH password>"
export GITHUB_USER="<github user>"
export GHE_ENTERPRISE_ADDR="<endereço github enterprise>"
export GHE_ENTERPRISE_USER="<github enterprise user>"
export GHE_TOKEN="<github enterprise token>"
```

ou 

Windows / Cmd env
```
set DOCKER_REGISTRY_HOSTNAME="<docker registry hostnamem>"
set DOCKER_REGISTRY_IP="<docker registry ip>"
set SSH_USER="<ansible SSH user>"
set SSH_PASS="<ansible SSH password>"
set GITHUB_USER="<github user>"
set GHE_ENTERPRISE_ADDR="<endereço github enterprise>"
set GHE_ENTERPRISE_USER="<github enterprise user>"
set GHE_TOKEN="<github enterprise token>"
```

- Deve ter as chaves ssh (publica/privada) compactadas no formato e caminho abaixo abaixo:

```
~/dev/keys/github_ssh.tar.gz

~/dev/keys/githubenterprise_ssh.tar.gz
```


## Como rodar?

- No diretório do arquivo ```Vagrantfile```, executar o comando ```vagrant up```
- Thats it

### Como acessar ?

- Você pode executar ```vagrant ssh```no mesmo diretório do ```Vagrantfile```
- Ou você pode acessar via SSH com as credenciais vagrant/vagrant



### Opcional Vagrantfile

- No arquivo Vagrantfile [aqui](https://github.dxc.com/alopes6/tux/blob/master/vagrant/Vagrantfile#L32) existem dois diretórios pré-definidos para compartilhamento com a máquina host. Sinta-se a vontade para alterá-las.

- Também existem alguns direcionamentos de portas pré-definidas [aqui](https://github.dxc.com/alopes6/tux/blob/master/vagrant/Vagrantfile#L32). Sinta-se a vontade para alterá-las.
