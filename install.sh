#!/bin/bash
echo "Realizando update"
sudo apt-get update -y
echo "Realizando Upgrade"
sudo apt-get upgrade -y

#Variable de Hostname Para instalacion de Bigbluebutton, el nombre de la maquina debe concordar con el dns aplicado a la instancia minisculas.

hostname="`hostname`.eastus.cloudapp.azure.com"

wget -qO- https://ubuntu.bigbluebutton.org/bbb-install-2.5.sh | bash -s -- -v focal-250 -s $hostname -e wilmar.aguilar@territorio.com  -a -w

#Modificando TLS en el VIRTUALHOST de Nginx


###################Opciones PRESENTACION E IDIOMA####
##Cambiar la presentation
#cp /home/azureuser/bigbluebutton/default.pdf /var/www/bigbluebutton-default/default.pdf

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
#####################################################################3
sed -i "s/meetingExpireIfNoUserJoinedInMinutes=5/meetingExpireIfNoUserJoinedInMinutes=30/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/defaultMaxUsers=0/defaultMaxUsers=200/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/userActivitySignResponseDelayInMinutes=250/userActivitySignResponseDelayInMinutes=15/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/muteOnStart=false/muteOnStart=true/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/allowModsToEjectCameras=false/allowModsToEjectCameras=true/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/defaultKeepEvents=false/defaultKeepEvents=true/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

allowModsToEjectCameras=false

############################################################################################
sed -i "s/userInactivityInspectTimerInMinutes=0/userInactivityInspectTimerInMinutes=120/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/breakoutRoomsRecord=false/breakoutRoomsRecord=true/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

sed -i "s/userActivitySignResponseDelayInMinutes=5/userActivitySignResponseDelayInMinutes=250/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i "s/userActivitySignResponseDelayInMinutes=5/userActivitySignResponseDelayInMinutes=250/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties


sed -i "s/meetingCameraCap=0/meetingCameraCap=8/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
##########CAMBIANDO WEBM TO MP4
sed -i "s/webm/mp4/g" /usr/local/bigbluebutton/core/scripts/presentation.yml






####CARPETA PARA SCRIPTS

sudo mkdir /ansible/
chmod 777 /ansible/
cp /home/azureuser/bigbluebutton/recoveryRecordingsJobV3.sh /ansible/
chmod 777 /ansible/recoveryRecordingsJobV3.sh

######Archivos Para scalelite

cp /home/azureuser/bigbluebutton/scalelite.yml  /usr/local/bigbluebutton/core/scripts/scalelite.yml

cp /home/azureuser/bigbluebutton/scalelite_post_publish.rb /usr/local/bigbluebutton/core/scripts/post_publish/

cp /home/azureuser/bigbluebutton/scalelite_batch_importv3.sh  /home/azureuser
chmod 777 /home/azureuser/bigbluebutton/scalelite_batch_importv3.sh
chmod 777 /home/azureuser/scalelite_batch_importv3.sh
####MONTAR NFS
apt-get install nfs-common -y

mkdir -p /mnt/scalelite-recordings
echo "10.9.2.4:/mnt/scalelite-recordings     /mnt/scalelite-recordings        nfs     auto,nofail,noatime,nolock,intr,tcp,actimeo=1800        0       0" >> /etc/fstab
mount -a

#mkdir -p /var/lib/tomcat9/logs
####EN CASO DE MIGRAR DATADRIVE
#MONTAR EL DISCO EN /datadrive/bigbluebutton
cp -r /var/bigbluebutton /var/bigbluebutton2
cp -r /var/freeswitch /var/freeswitch2
mv /var/bigbluebutton /datadrive/
mv /var/freeswitch /datadrive/

#_crontab
sudo ln -s /datadrive/bigbluebutton/ /var/
chown -h bigbluebutton:bigbluebutton /var/bigbluebutton
chown  -R -h bigbluebutton:bigbluebutton  /datadrive/bigbluebutton
####################################
sudo ln -s /datadrive/freeswitch/ /var/
chown -h freeswitch:freeswitch /var/freeswitch
chown  -R -h freeswitch:freeswitch  /datadrive/freeswitch
chown freeswitch:freeswitch /datadrive/freeswitch/meetings/

mkdir -p /scripts/
cp /home/azureuser/bigbluebutton/cleanPublishedRecords.sh /scripts
chmod 777 /scripts/cleanPublishedRecords.sh
#AGREGAR MANUAL AL CROtab -e
mkdir -p /ansible/logs/

# Crontab -e
#!/bin/bash

echo "@reboot bbb-conf --restart >> /var/log/bbbrestart.log" > /home/azureuser/temp_crontab
echo "@reboot mkdir -p /mnt/scalelite-recordings" >> /home/azureuser/temp_crontab
echo "@reboot mount -a" >> /home/azureuser/temp_crontab
echo "0 7 * * * /bin/bash /home/azureuser/scalelite_batch_importv3.sh" >> /home/azureuser/temp_crontab
echo "0 9 * * * /bin/bash /ansible/recoveryRecordingsJobV3.sh >> /ansible/logs/recoveryRercordingsJobV3.log" >> /home/azureuser/temp_crontab
echo "0 7 * * * /bin/bash /scripts/cleanPublishedRecords.sh >> /scripts/logs/clenPublishedRecords.log 2>&1" >> /home/azureuser/temp_crontab
crontab /home/azureuser/temp_crontab
###################################LIMITES
sudo sh -c 'echo "
vm.overcommit_memory = 1
fs.file-max = 2097152
kernel.shmmni=32000
net.ipv4.ip_local_port_range = 4000 65500
net.netfilter.nf_conntrack_max=1048576
net.core.somaxconn = 65535
net.core.message_cost = 10
net.core.message_burst = 20
net.ipv4.tcp_syncookies = 0
net.core.rmem_default = 31457280
net.core.rmem_max = 12582912
net.core.wmem_default = 31457280
net.core.wmem_max = 12582912
net.core.optmem_max = 25165824
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.udp_rmem_min = 16384
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_max_syn_backlog = 4096
#net.core.somaxconn = 4096
#calculo 200g  
kernel.shmmni=32000
#kernel.msgmni=204800
kernel.msgmax=65536
kernel.msgmnb=65536" >> /etc/sysctl.conf'


####################################SYSTEMCTL
sudo sh -c 'echo "
root soft nproc 130000
root hard nproc 130000
root soft nofile 130000
root hard nofile 130000
* soft nofile 1048576
* hard nofile 1048576
* * nofile 130000" >> /etc/security/limits.conf'

###########################################PERFORMANCE
sed -i "s/limit_conn ws_zone 3/limit_conn ws_zone 6/g" /usr/share/bigbluebutton/nginx/bbb-html5.nginx
sed -i "s/NUMBER_OF_BACKEND_NODEJS_PROCESSES=2/NUMBER_OF_BACKEND_NODEJS_PROCESSES=4/g" /usr/share/meteor/bundle/bbb-html5-with-roles.conf
sed -i "s/NUMBER_OF_FRONTEND_NODEJS_PROCESSES=2/NUMBER_OF_FRONTEND_NODEJS_PROCESSES=8/g" /usr/share/meteor/bundle/bbb-html5-with-roles.conf
sed -i "s/--max_semi_space_size=128/--max_semi_space_size=2048/g" /usr/share/meteor/bundle/systemd_start.sh
sed -i "s/worker_rlimit_nofile 10000/worker_rlimit_nofile 65000/g" /etc/nginx/nginx.conf
sed -i "s/worker_connections 4000/worker_connections 8000/g" /etc/nginx/nginx.conf

sed -i "s/size=512m/size=2048m/g" /usr/share/meteor/bundle/mongod_start_pre.sh
##########################MEMORIA
sudo fallocate -l 8G /datadrive/swapfile
sudo chmod 600 /datadrive/swapfile
sudo mkswap /datadrive/swapfile
sudo swapon /datadrive/swapfile
echo "/datadrive/swapfile none swap sw 0 0" >> /etc/fstab


################################

#################################################
#/usr/local/bigbluebutton/core/

#mv /usr/local/bigbluebutton/core/Gemfile.lock  /usr/local/bigbluebutton/core/Gemfile.lock.old
addgroup scalelite-spool
#adduser bigbluebutton
#rm a esrte archivo Gemfile.lock.old
#bbb-conf --clean
sudo gem install conection_pool
#Instalar las gemas que faltan
apt install ruby2.7-dev libsystemd-dev -y 
gem install redis builder nokogiri loofah open4 absolute_time journald-logger 
gem update --default 
gem update fileutils --default 


apt-get purge bbb-demo -y
bbb-conf --restart

mkdir -p /home/bigbluebutton
chmod 777 /home/bigbluebutton/

apt install ruby2.7-dev libsystemd-dev
gem install redis builder nokogiri loofah open4 absolute_time journald-logger

gem update redis-namespace
gem update redis

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
apt install apache2-utils -y
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