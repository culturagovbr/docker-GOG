#!/bin/bash

if [ "$JBOSS_PASS" = "**Random**" ]; then
    unset JBOSS_PASS
fi

if [ ! -f /.jboss_admin_pass_configured ]; then
    /opt/set_jboss_admin_pass.sh
fi

echo "Vai configurar o nome do HOST de banco de dados"
HOSTNAME="10.0.0.217"
# Verifica o valor da variável de ambiente
if [ -n "$HOSTNAMELINK" ]; then
    HOSTNAME=$HOSTNAMELINK
fi
echo $HOSTNAME
sed -i -r "s/HOSTNAME/$HOSTNAME/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml


echo "Vai iniciar o Jboss ..."
/opt/jboss-as-7.1.1.Final/bin/standalone.sh -b=0.0.0.0 &
# Aguardar o jboss subir...
sleep 5

echo "Vai realizar o deploy ..."
/opt/jboss-as-7.1.1.Final/bin/jboss-cli.sh --connect --command="deploy /opt/GOG/GOG/target/GOG.war --force"
echo "Jboss iniciado com o depĺoy realizado"

#sleep 30
echo "...Agora vamos carregar os dados do sistema..."
sh /opt/carregaDados.sh 

echo -e "\n\n\n\t...A aplicação está funcionando!"

# /bin/bash
while :
do
	sleep 1
done
