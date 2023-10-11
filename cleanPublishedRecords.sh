## TerritoriumLIFE LATAM: Jcuervo 2020

backupFolder="/var/bigbluebutton/published/presentation"
scaleliteRecordingsFolder="/mnt/scalelite-recordings/var/bigbluebutton/published/presentation"


#SAS_token="sp=racwl&st=2021-06-08T18:16:08Z&se=2030-06-09T02:16:08Z&sv=2020-02-10&sr=c&sig=lARabYN81Wi6hDxUc4w%2B1fgmvatmBTA0v%2FP%2Bx5wBER$

curdate="$(date +%s)"
daysAgo=$(($curdate-10000080))
daysAfterToDelete="15"


maxdate=$(date --date="$date -30 days" +%Y-%m-%d)
echo "Fecha máxima para borrado: "$maxdate

# Se ejecuta sincronización con Azure

#azcopy login --identity

#azcopy --exclude-pattern="syncWithAzBlobSena.sh;copy-backups.sh;log_transfer.log;sincro.log;cron.log;full-backup.sh" sync $backupFolder  ht$

#Si es satisfactoria se eliminan los backups con fecha superior a la fecha maxima seleccionada


  #echo "Sincronizacion con AZURE completada se procede a remover los archivos superiores a $daysAfterToDelete dias"

  parent_folders=$(find $backupFolder -maxdepth 1 -type d -newermt "2019-01-01" ! -newermt $maxdate)

  for pfol in $parent_folders
  do

       echo "Verificando la existencia del Folder $pfol en el scalelite"

	# fecha superior a $maxdate"
	SCALELITE_RECORDING="$scaleliteRecordingsFolder/${pfol##*/}"
	echo "Evalua $SCALELITE_RECORDING \n"
	if [ -d "$SCALELITE_RECORDING" ]; then

    		msg="Grabacion: $SCALELITE_RECORDING , Existe se puede borrar."

		 echo $msg;
                
		echo $msg >> /scripts/logs/recordingsCleanedExistsOnScalelite.log;

		folderToDelete="$backupFolder/${pfol##*/}";
		echo "Intenta Elminar folder $folderToDelete"
	        #sudo rm -rf $folderToDelete;
		
		result="success";

	        ($(rm -rf $folderToDelete) || result="error" )

		if [ $result == "error" ]; then

          	msg="Error eliminando el folder: $folderToDelete Error:  $? ";

		echo $msg;

                echo $msg >> /scripts/logs/recordingsCannotBeDeleted.log;

     		elif [ $result == "success" ]; then

		 msg="Grabacion: $SCALELITE_RECORDING , Existe en Scalelite, eliminada con exito del disco local."

                 echo $msg;

                 echo $msg >> /scripts/logs/recordingsCleanedExistsOnScalelite.log;


		fi
         else
		msg="La grabacion $SCALELITE_RECORDING no existe en el Scalelite ";
		echo $msg;
		echo $msg >> /scripts/logs/recordingsMissingOnScalelite.log ;
	fi
 done
