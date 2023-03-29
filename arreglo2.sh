
/usr/local/bigbluebutton/core/
rm a esrte archivo Gemfile.lock.old
bbb-record --clean
sudo gem install conection_pool
Instalar las gemas que faltan
apt install ruby2.7-dev libsystemd-dev
gem install redis builder nokogiri loofah open4 absolute_time journald-logger
gem update --default
gem update fileutils --default
# En caso de tener problemas con algunos WARNING de bbbb-rebuld o al ver bbb-record
#Puede ser que algunas gemas esten duplicadas por esto se desistala fileutils
#tambien se quita la gema reline con version mas vieja
cd /usr/lib/ruby/gems/2.7.0/specifications/default 
mv reline-0.1.2.gemspec  relineviejo
gem uninstall reline -v 0.1.2