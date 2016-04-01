# Debian JessiE with Java 7 installed.
# Build image with:  docker build -t clelson/gog:v1 .
FROM java:openjdk-7-jdk
#MAINTAINER Clelson Salles Rodrigues, https://github.com/clelson

# Configura o locale para pt_BR.UTF-8
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
ENV LANG pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

# Instalação do java7
#RUN \
#    echo "GOG - Passo 01 - Adicionando o repositório webupd8"  && \
#    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
#    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
#    apt-get update  && \
#    \
#    \
#    echo "GOG - Passo 02 - Instalando o Java"  && \
#    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
#    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
#    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java7-installer oracle-java7-set-default  && \
#    \
#    \
#    echo "===> clean up..."  && \
#    rm -rf /var/cache/oracle-jdk7-installer  && \
#    apt-get clean  && \
#    rm -rf /var/lib/apt/lists/*
    

# Instalação do Maven
ENV MAVEN_VERSION 3.3.9

RUN echo "GOG - Passo 03 - Instalando o Maven"

RUN apt-get update && \
    apt-get -y install curl && \
    curl --insecure -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

# Instalação do git commands
RUN echo "GOG - Passo 04 - Instalando o Git"
RUN apt-get -y install git

# Instalação do Jboss
RUN echo "GOG - Passo 05 - Instalando o Jboss"
ENV JBOSS_HOME /opt/jboss-as-7.1.1.Final
WORKDIR /opt
RUN wget --quiet http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz \
 && tar -zxf jboss-as-7.1.1.Final.tar.gz -C /opt \
 && rm -rf /opt/jboss-as-7.1.1.Final.tar.gz

# Obtem o código do GOG e realiza a build do sistema
RUN echo "GOG - Passo 06 - Obtendo o código do GOG no GitHub"
RUN mkdir /opt/GOG 
WORKDIR /opt/GOG 
RUN git clone https://github.com/culturagovbr/GOG.git

# Configura a aplicação para criar o modelo de dados quando executar a primeira vez.
RUN echo "GOG - Passo 07 - Configurando o Jboss para executar na primeira vez"
RUN sed -i -r 's/<!-- <property name=\"hibernate.hbm2ddl.auto\" value=\"update\" \/>  -->/<property name=\"hibernate.hbm2ddl.auto\" value=\"update\" \/>/' /opt/GOG/GOG/src/main/resources/META-INF/persistence.xml 
RUN cat /opt/GOG/GOG/src/main/resources/META-INF/persistence.xml

# Monta a Build do sistema "GOG.war"
RUN echo "GOG - Passo 08 - Monta a build do GOG utilizando o Maven"
WORKDIR /opt/GOG/GOG
RUN mvn --quiet package

RUN echo "GOG - Passo 09 - Prepara o ambiente para execução da aplicação"

# Instala  -client, visando executar comandos SQL no banco de dados
RUN apt-get install -qy postgresql-client
# Prepara as portas do servidor de aplicação
EXPOSE 8080 8443 9990

# Instala o vim, para posibilitar edição de texto no modo interativo
RUN apt-get install -y -q vim

# Preparação do ambiente para o Jboss
WORKDIR /opt
COPY arquivos/standalone.xml /opt/jboss-as-7.1.1.Final/standalone/configuration/
COPY arquivos/modules_jboss /opt/jboss-as-7.1.1.Final/modules

# Inclui os arquivos bash com de comandos para configurar e iniciar o Jboss
ADD arquivos/run.sh /opt/run.sh
ADD arquivos/set_jboss_admin_pass.sh /opt/set_jboss_admin_pass.sh

# Prepara ambiente para a carga de dados
RUN echo "... Inclui os arquivos para execução da carga de dados"
COPY arquivos/carregaDados.sh /opt/
COPY arquivos/bancoDados/ScriptCargaDominio.sql /opt/
COPY arquivos/bancoDados/ScriptCargaComplementar.sql /opt/
COPY arquivos/bancoDados/ScriptCreateVWEstatisticasManifestacao.sql /opt/
COPY arquivos/bancoDados/ScriptCreateVWUltimoTramite.sql /opt/

RUN chmod +xwr /opt/*.sh

VOLUME /root/.m2
VOLUME /opt


RUN echo "GOG - Passo 10 - Disponibiliza o comando de execução"
CMD ["sh", "-c", "/opt/run.sh"]
