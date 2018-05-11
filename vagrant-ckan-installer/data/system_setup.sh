#!/bin/bash

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
    ;;
    trusty) echo "Prepeare setup for TRUSTY"
            sudo service apache2 stop
            sudo apt-get -y install nginx openjdk-7-jre
    ;;
    xenial) echo "Prepeare setup for XENIAL"
            sudo service apache2 stop
            sudo apt-get -y install nginx openjdk-8-jre
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

if [ -f /etc/default/jetty ]; then
    echo "** Eedit solr jetty coinfiguration"
    sed -i "s/NO_START=1/NO_START=0/" /etc/default/jetty
    sed -i "s/#JETTY_HOST=\$(uname -n)/JETTY_HOST=127\.0\.0\.1/" /etc/default/jetty
    sed -i "s/#JETTY_PORT=8080/JETTY_PORT=8983/" /etc/default/jetty
else
   echo "Please reinstall SOLR!!!"

sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml

sudo service jetty restart
sudo service jetty status

echo "** Set up production.ini"
sed -i "s/ckan.site_url =/ckan.site_url = http:\/\/192\.168\.33\.10/g" /etc/ckan/default/production.ini
sed -i "s/#solr_url = http:\/\/127\.0\.0\.1:8983\/solr/solr_url = http:\/\/127\.0\.0\.1:8983\/solr/g" /etc/ckan/default/production.ini
sed -i "s/#ckan.storage_path = \/var\/lib\/ckan/ckan.storage_path = \/var\/lib\/ckan\/default/g" /etc/ckan/default/production.ini

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

