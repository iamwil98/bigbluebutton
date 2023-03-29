



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

sed -i "s/meetingCameraCap=0/meetingCameraCap=15/g" /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
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
#echo "10.2.35.5:/mnt/scalelite-recordings     /mnt/scalelite-recordings        nfs     auto,nofail,noatime,nolock,intr,tcp,actimeo=1800        0       0" >> /etc/fstab
mount -a


####EN CASO DE MIGRAR DATADRIVE
#MONTAR EL DISCO EN /datadrive/bigbluebutton
cp -r /var/bigbluebutton /var/bigbluebutton2
mv /var/bigbluebutton /datadrive/

sudo ln -s /datadrive/bigbluebutton/ /var/
chown -h bigbluebutton:bigbluebutton /var/bigbluebutton
chown  -R -h bigbluebutton:bigbluebutton  /datadrive/bigbluebutton
#AGREGAR MANUAL AL CROtab -e
mkdir -p /ansible/logs/

# Crontab -e
#!/bin/bash

# Add reboot commands to crontab
echo "@reboot bbb-conf --restart >> /var/log/bbbrestart.log" | sudo tee -a /etc/crontab > /dev/null
echo "@reboot mkdir -p /mnt/scalelite-recordings" | sudo tee -a /etc/crontab > /dev/null
echo "@reboot mount -a" | sudo tee -a /etc/crontab > /dev/null

# Add scheduled jobs to crontab
echo "0 7 * * * /bin/bash /home/azureuser/scalelite_batch_import.sh" | sudo tee -a /etc/crontab > /dev/null
echo "0 9 * * * /bin/bash /ansible/recoveryRecordingsJobV2.sh >> /ansible/logs/recoveryRercordingsJobV2.log" | sudo tee -a /etc/crontab > /dev/null


#/usr/local/bigbluebutton/core/

mv /usr/local/bigbluebutton/core/Gemfile.lock  /usr/local/bigbluebutton/core/Gemfile.lock.old
#rm a esrte archivo Gemfile.lock.old
bbb-conf --clean
sudo gem install conection_pool
#Instalar las gemas que faltan
apt install ruby2.7-dev libsystemd-dev -y 
gem install redis builder nokogiri loofah open4 absolute_time journald-logger -y 
gem update --default -y
gem update fileutils --default 

apt-get purge bbb-demo -y
