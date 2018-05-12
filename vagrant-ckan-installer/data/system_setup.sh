#!/bin/bash
set -x

echo "SETTING UP THE SYSTEM"


echo "** Updating the package manager "
sudo apt-get update

sudo apt-get install -y apache2 libapache2-mod-wsgi libpq5 redis-server git-core postgresql solr-jetty

release=$(lsb_release -c | awk '{print $2}')


echo $release

case $release in

    precise) echo "Prepeare setup for PRECISE"
            sudo service apache2 stop
            sudo apt-get -y install nginx openjdk-7-jre
            jety=jetty
    ;;
    trusty) echo "Prepeare setup for TRUSTY"
            sudo service apache2 stop
            sudo apt-get -y install nginx openjdk-7-jre
            jety=jetty
    ;;
    xenial) echo "Prepeare setup for XENIAL"
            sudo service apache2 stop
            sudo apt-get -y install nginx openjdk-8-jre
            jety=jetty8
    ;;
esac

echo "** Restart apache"
sudo service apache2 start

echo "** Install CKAN"
cd /vagrant/data/

echo $release
package=`printf "python-ckan_%s-%s_amd64.deb" "$1" "$release"`

if [! -f $package]; then
   echo " *** CKAN package is missing!!!"
else
   sudo chmod a+x $package
   sudo dpkg -i $package
fi

cd /vagrant

echo "** Set up the database"
if psql -lqt | cut -d \| -f 1 | grep -qw ckan_default; then
    echo "*** Database is created! "
else
    sudo -u postgres createuser -S -D -R ckan_default
    sudo -u postgres psql -c "ALTER USER ckan_default with password 'pass'"
    sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
fi

echo "** Edit solr jetty coinfiguration"

if [ -f /etc/default/$jety ]; then
    sudo sed -i "s/NO_START=1/NO_START=0/g" /etc/default/$jety
    sudo sed -i "s/#JETTY_HOST=\$(uname -n)/JETTY_HOST=127\.0\.0\.1/g" /etc/default/$jety
    sudo sed -i "s/#JETTY_PORT=8080/JETTY_PORT=8983/g" /etc/default/$jety
else
   echo "Please reinstall SOLR!!!"
fi

sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml

sudo service $jety restart
sudo service $jety status

echo "** Set up production.ini"
host=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

sudo sed -i "s/ckan.site_url =/ckan.site_url = http:\/\/$host/g" /etc/ckan/default/production.ini
sudo sed -i "s/#solr_url = http:\/\/127\.0\.0\.1:8983\/solr/solr_url = http:\/\/127\.0\.0\.1:8983\/solr/g" /etc/ckan/default/production.ini
sudo sed -i "s/#ckan.storage_path = \/var\/lib\/ckan/ckan.storage_path = \/var\/lib\/ckan\/default/g" /etc/ckan/default/production.ini

echo "** Enable filestore"
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default

echo "** Initialize database"
sudo ckan db init

echo "** Create sysadmin"
echo ".... but first activate virtualenv"
source /usr/lib/ckan/default/bin/activate

echo ".... and then continue with the user creation"
cd /usr/lib/ckan/default/src/ckan
paster --plugin=ckan user add ckan_admin email=admin@ckan.org password=password -c /etc/ckan/default/production.ini
paster --plugin=ckan sysadmin add ckan_admin -c /etc/ckan/default/production.ini
deactivate

echo "** Restart Services **"
sudo service apache2 restart
sudo service nginx restart

echo "** Enjoy the coffie with your freshly installe CKAN istance"

