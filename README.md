# GOG com Docker
Repositório com arquivos para "dockerizar" o sistema GOG: códigos para criar "images" e "containers" do sistema GOG utilizando-se do Docker

## Comandos para utilização do docker neste projeto 

> **Nota**
> - Instale o Docker e o Docker Compose na sua máquina para utilizar este projeto https://www.docker.com/

### Como usar
Este projeto deve ser utilizado para a montagem e execução do sistema GOG em um ambiente configurado com os serviços oferecidos pelo Docker. 

Para usar este projeto e montar o sistema GOG em sua máquina execute apenas quatro passos principais

> - Baixe o projeto 
```
git clone https://github.com/culturagovbr/docker-GOG.git
```
> - Monte as imagens

> É necessário criar as duas "images" docker do projeto: uma para o serviço de Banco de Dados (que pode ser acessada a partir do Dockerfile mantido no diretório "postgresql_9.3")
```
docker-compose build
```
> - Execute os containers

```
docker-compose up
```
> - Acesse a aplicação
>   - http://localhost:8080/GOG

A imagem a seguir ilustra como este projeto deve ser utilizado:
![Como utilizar este projeto](/arquivos/DockerFluxoUtilizacao.jpg)

### Como foi projetado
Projetamos o Docker mantendo em mente o conceito de micro serviços. Neste sentido, dividimos o ambiente de instalação do sistema GOG em dois serviços:

- Um serviço para o Banco de Dados da aplicação
  - utilizando duas imagens: 
    - debian:jessie
    - postgres:9.3 - postgresql 9.3
- Um outro serviço para o Servidor de Aplicação
  - utilizando basicamente:
    - debian:jessie
    - Java7
    - Maven3
    - Git - command line
    - Jboss7.1.1 
    - postgresql-client
    - vim
    - GOG - deploy

A imagem a seguir ilustra a utilização do Docker foi projetada para o sistema GOG; isto ajuda a entender como utilizar o docker para montar os serviços envolvidos:
![Como foi projetada a utilização do Docker no sistema GOG](/arquivos/DockerMontagemAmbiente.jpg)


