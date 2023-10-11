## TerritoriumLIFE LATAM: Jcuervo 2020
##bbb-conf --restart
archiveRecordingsFolder="/var/bigbluebutton/recording/status/archived"

curdate="$(date +%s)"
#daysAgo=$(($curdate-10000080))

#declare -a authFolders=("Davivienda" "SENA" "Proctoring")
#maxdate=$(date --date="$date " +%Y-%m-%d)
#echo "Fecha maxima para inicio reproceso grabaciones: "$maxdate

archive_files=$(find $archiveRecordingsFolder -type f -name "*.norecord")

for pfile in $archive_files
do

    # Set dot as the delimiter
    IFS='.'

    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$pfile"

    echo "Reprocesando Archivo: ${strarr[0]}"

    fileName=$(basename ${pfile})

    # Bueno aqui buscamos si el archivo xml tiene el prefijo sena "sena-"
    senaRecording=$(grep '" name="sena-' /var/bigbluebutton/recording/raw/${fileName}/events.xml)

    # Si lo encuentra salta entonces el codigo, si no lo encuentra continua..
    if [[ -n $senaRecording ]]; then
        echo "Ignorando grabación con prefijo sena-: $fileName"
        continue
    fi

    echo "Verificando si la sesion ${fileName} tiene evento de Inicio de Grabacion."

    recordMark="$(grep 'StartRecordingEvent' /var/bigbluebutton/recording/raw/${fileName}/events.xml)"

    if [[ -n "$recordMark" ]]; then
        echo "Se encuentra marcador de grabación, Reprocesando Archivo: ${fileName}"
        # Se ejecuta el comando de regeneración la grabación
        echo "Evento Grabacion encontrado en ${fileName} : ${recordMark}"
        echo "Se ejecuta rebuild en sesion: ${fileName}"
        sudo bbb-record --rebuild "${fileName}"

        if [ $? -eq 0 ]; then
            echo "Regeneración Satisfactoria para la grabación:"
        else
            echo "Error regenerando la grabación: $pfile"
        fi
    else 
        echo "No se encontró evento de grabación en ${fileName}"
    fi

done

# Se ejecuta sincronización con Azure
# azcopy login --identity
# azcopy sync $backupFolder  https://territoriumbackups.blob.core.windows.net/mysqlbackups

# Si es satisfactoria se eliminan los backups con fecha superior a la fecha máxima seleccionada
if [ $? -eq 0 ]; then
    echo "Proceso de Regeneración Finalizada"
else
    echo "Error en el Proceso de Regeneración."
    exit 1
fi
