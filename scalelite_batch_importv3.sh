status_dir=/var/bigbluebutton/recording/status/published
scripts_dir=/usr/local/bigbluebutton/core/scripts
scaleliteRecordingsFolder="/mnt/scalelite-recordings/var/bigbluebutton/published/presentation"
scaleliteRecordingsSpoolFolder="/mnt/scalelite-recordings/var/bigbluebutton/spool"


if ! sudo -n -u bigbluebutton true; then
    echo "Unable to run commands as the bigbluebutton user, try running this script as root"
    exit 1
fi

find "$status_dir" -name "*.done" -mtime -5 -print0 | while read -d $'\0' record_id
do
        record_id="${record_id##*/}"
        record_id="${record_id%-*.done}"

      SCALELITE_RECORDING="$scaleliteRecordingsFolder/${record_id}/"
        echo "Evalua $SCALELITE_RECORDING "
        if [ -d "$SCALELITE_RECORDING" ]; then

                msg="Grabacion: $SCALELITE_RECORDING existe en el scalelite. OK"

		echo $msg;
                #echo $msg >> /scripts/logs/recordingsCleanedExistsOnScalelite.log;


         else

                SCALELITE_SPOOL_RECORDING="$scaleliteRecordingsSpoolFolder/${record_id}.tar"

		msg="verifica si hay pendiente grabación por ser procesada en SPOOL del scalelite: ${SCALELITE_SPOOL_RECORDING}"
                if [ -f "$SCALELITE_SPOOL_RECORDING" ]; then


                        msg="La grabacion $SCALELITE_SPOOL_RECORDING esta pendiente por procesar en el scalelite SPOOL.  ";
			echo $msg

                else

                        msg="La grabacion $SCALELITE_RECORDING no existe en el Scalelite ni tampoco esta pendiente en SPOOL $SCALELITE_SPOOL_RECORDING se procede a sincronizar: ${record_id}";
                        echo $msg;
                        echo $msg >> /scripts/logs/recordingsPendingToBeSyncScalelite.log ;
			( cd "$scripts_dir" && sudo -n -u bigbluebutton -g scalelite-spool ruby ./post_publish/scalelite_post_publish.rb -m "$record_id" )

		fi
	fi




done

