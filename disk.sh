#!/bin/bash

# Detectar el dispositivo del disco de 256 GB
device=$(lsblk -o NAME,SIZE | awk '$2=="256G"{print "/dev/"$1}')

if [ -z "$device" ]; then
  echo "No se encontró ningún disco de 256 GB."
  exit 1
fi

echo "Disco detectado: $device"

# Dar formato ext4 al disco
mkfs.ext4 $device

# Crear un punto de montaje
mkdir -p /datadrive

# Montar el disco en /datadrive
mount $device /datadrive

# Obtener el UUID del disco
uuid=$(blkid -s UUID -o value $device)

# Agregar una entrada en fstab para que el disco se monte automáticamente en el arranque
echo "UUID=$uuid   /datadrive   ext4   defaults,nofail   1   2" >> /etc/fstab

echo "El disco ha sido formateado con ext4, montado en /datadrive y configurado para el montaje automático en el arranque a través de fstab."

#comando 
#az vm run-command invoke -g BIGBLUEBUTTON-SENA -n sena-bbbtest-00 --command-id RunShellScript --scripts "sudo touch /home/azureuser/testo.txt"
az vm run-command invoke -g BIGBLUEBUTTON-SENA -n sena-bbbtest-00 --command-id RunShellScript --scripts "sudo chmod 777 /home/azureuser/testo.txt"
az vm run-command invoke -g BIGBLUEBUTTON-SENA -n sena-bbbtest-00 --command-id RunShellScript --scripts "sudo sh /home/azureuser/texto.txt"


