#!/bin/bash
echo "Realizando update"
sudo apt-get update -y
echo "Realizando Upgrade"
sudo apt-get upgrade -y

#Variable de Hostname Para instalacion de Bigbluebutton, el nombre de la maquina debe concordar con el dns aplicado a la instancia minisculas.

hostname="`hostname`.eastus.cloudapp.azure.com"

wget -qO- https://ubuntu.bigbluebutton.org/bbb-install-2.5.sh | bash -s -- -v focal-250-2.5.14  -s $hostname -e wilmar.aguilar@territorio.com  -a -w

#Modificando TLS en el VIRTUALHOST de Nginx focal-250-2.5.14 

sed -i "s/ssl_protocols TLSv1.2 TLSv1.3/ssl_protocols TLSv1.2/g" /etc/nginx/sites-available/bigbluebutton
echo "iniciando Servicio Nginx"

/etc/init.d/nginx start
echo "###Reiniciar BBB"

bbb-conf --restart

###################Opciones PRESENTACION E IDIOMA####
##Cambiar la presentation
cp /home/azureuser/bigbluebutton/default.pdf /var/www/bigbluebutton-default/default.pdf

####CAMBIANDO BBB-PROPERTIES  SETTINGS

sed -i "s/Welcome to/Bienvenido a/g"  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties 
#For help on using BigBlueButton see these
sed -i "s/For help on using BigBlueButton see these/Para obtener ayuda sobre el uso de BigBlueButton, puede consultara/g"  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
#To join the audio bridge click the speaker button
sed -i "s/To join the audio bridge click the speaker button/Para unirse al puente de audio, haga clic en el bot&oacute;n del altavoz/g"  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
#Use a headset to avoid causing background noise for others
sed -i "s/Use a headset to avoid causing background noise for others/Use un auricular para evitar causar ruido de fondo a los dem&aacute;s/g"  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
#This server is running
sed -i "s/This server is running/Este servidor esta activo/g"  /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

#########################################
## CAMBIA PARAMETROS DEL VIDEO RB
cp /usr/local/bigbluebutton/core/lib/recordandplayback/generators/video.rb /usr/local/bigbluebutton/core/lib/recordandplayback/generators/video.rb.old
cp /home/azureuser/bigbluebutton/video.rb   /usr/local/bigbluebutton/core/lib/recordandplayback/generators/video.rb
#####

####CAMBIANDO BBB-PROPERTIES  SETTINGS

sed -i "s/defaultMeetingDuration=0/defaultMeetingDuration=240/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/clientLogoutTimerInMinutes=0/clientLogoutTimerInMinutes=240/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/meetingExpireIfNoUserJoinedInMinutes=5/meetingExpireIfNoUserJoinedInMinutes=30/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/meetingExpireWhenLastUserLeftInMinutes=1/meetingExpireWhenLastUserLeftInMinutes=15/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/userActivitySignResponseDelayInMinutes=5/userActivitySignResponseDelayInMinutes=250/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/meetingCameraCap=0/meetingCameraCap=8/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
##########CAMBIANDO WEBM TO MP4
sed -i "s/webm/mp4/g" /usr/local/bigbluebutton/core/scripts/presentation.yml


####CARPETA PARA SCRIPTS

sudo mkdir /ansible/
chmod 777 /ansible/
cp /home/azureuser/bigbluebutton/recoveryRecordingsJobV2.sh /ansible/
chmod 777 /ansible/recoveryRecordingsJobV2.sh

######Archivos Para scalelite

cp /home/azureuser/bigbluebutton/scalelite.yml  /usr/local/bigbluebutton/core/scripts/scalelite.yml

cp /home/azureuser/bigbluebutton/scalelite_post_publish.rb /usr/local/bigbluebutton/core/scripts/post_publish/

cp /home/azureuser/bigbluebutton/scalelite_batch_import.sh  /home/azureuser
chmod 777 /home/azureuser/bigbluebutton/scalelite_batch_import.sh
chmod 777 /home/azureuser/scalelite_batch_import.sh
####MONTAR NFS
apt-get install nfs-common -y

mkdir -p /mnt/scalelite-recordings
echo "10.9.2.27:/mnt/scalelite-recordings     /mnt/scalelite-recordings        nfs     auto,nofail,noatime,nolock,intr,tcp,actimeo=1800        0       0" >> /etc/fstab
mount -a

mkdir -p /var/lib/tomcat9/logs
####EN CASO DE MIGRAR DATADRIVE
#MONTAR EL DISCO EN /datadrive/bigbluebutton
cp -r /var/bigbluebutton /var/bigbluebutton2
mv /var/bigbluebutton /datadrive/
_crontab
sudo ln -s /datadrive/bigbluebutton/ /var/
chown -h bigbluebutton:bigbluebutton /var/bigbluebutton
chown  -R -h bigbluebutton:bigbluebutton  /datadrive/bigbluebutton
#AGREGAR MANUAL AL CROtab -e
mkdir -p /ansible/logs/

# Crontab -e
#!/bin/bash

echo "@reboot bbb-conf --restart >> /var/log/bbbrestart.log" > /home/azureuser/temp_crontab
echo "@reboot mkdir -p /mnt/scalelite-recordings" >> /home/azureuser/temp_crontab
echo "@reboot mount -a" >> /home/azureuser/temp_crontab
echo "0 7 * * * /bin/bash /home/azureuser/scalelite_batch_import.sh" >> /home/azureuser/temp_crontab
echo "0 9 * * * /bin/bash /ansible/recoveryRecordingsJobV2.sh >> /ansible/logs/recoveryRercordingsJobV2.log" >> /home/azureuser/temp_crontab

crontab /home/azureuser/temp_crontab



#addgroup scalelite-spool
#sudo gem install conection_pool
#apt install ruby2.7-dev libsystemd-dev -y 
#gem install redis builder nokogiri loofah open4 absolute_time journald-logger 
#gem update --default 
#gem update fileutils --default 

#apt-get purge bbb-demo -y
#bbb-conf --restart

#mkdir -p /home/bigbluebutton
#chmod 777 /home/bigbluebutton/

#apt install ruby2.7-dev libsystemd-dev
#gem install redis builder nokogiri loofah open4 absolute_time journald-logger

#gem update redis-namespace
#gem update redis

# +-+-+-+-+-+-+-+-+-+
# |#|M|e|t|r|i|c|a|s|
# +-+-+-+-+-+-+-+-+-+
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
#Variblaes de  secret
hostname="`hostname`.eastus.cloudapp.azure.com"
mkdir /root/bbb-exporter
secret=$(bbb-conf --secret | awk '/Secret/ {print $2}')
###################################################
echo "version: '3'
services:
  bbb-exporter:
    container_name: 'bbb-exporter'
    image: greenstatic/bigbluebutton-exporter:v0.6.1
    ports:
      - '127.0.0.1:9688:9688'
    volumes:
      - '/var/bigbluebutton:/var/bigbluebutton:ro'
    environment:
      RECORDINGS_METRICS_READ_FROM_DISK: 'true'
    env_file:
      - secrets.env
    restart: unless-stopped" >> /root/bbb-exporter/docker-compose.yaml
###################################
echo "API_BASE_URL=https://$hostname/bigbluebutton/api/" >> /root/bbb-exporter/secrets.env
echo "API_SECRET=$secret" >> /root/bbb-exporter/secrets.env
cd /root/bbb-exporter
sudo docker-compose up -d
echo "Entra2020" | sudo htpasswd -c /etc/nginx/.htpasswd metrics


###################3
mkdir -p /etc/bigbluebutton/nginx/
sudo sh -c 'echo "# BigBlueButton Exporter (metrics)
location /metrics/ {
    auth_basic \"BigBlueButton Exporter\";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9688/;
    include proxy_params;
}" >> /etc/bigbluebutton/nginx/monitoring.nginx'


sudo nginx -t
sudo systemctl reload nginx

####
# +-+-+-+-+-+ +-+-+-+-+-+-+-+-+
# |#|N|o|d|e| |E|x|p|o|r|t|e|r|
# +-+-+-+-+-+ +-+-+-+-+-+-+-+-+
#!/bin/bash

cd /root
git clone https://github.com/greenstatic/bigbluebutton-exporter.git
cp -r /root/bigbluebutton-exporter/extras/node_exporter /root/
cd /root/node_exporter
sudo docker-compose up -d

sed -i '28i\location /node_exporter/ {\n    auth_basic "node_exporter";\n    auth_basic_user_file /etc/nginx/.htpasswd;\n    proxy_pass http://127.0.0.1:9100/;\n    include proxy_params;\n}' /etc/nginx/sites-available/bigbluebutton


sudo nginx -t
sudo systemctl reload nginx

echo "Finalizo"
reboot