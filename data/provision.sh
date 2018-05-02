echo "Starting trusty ....."

uname -a

echo "** Updating the package manager "
sudo apt-get update

echo "** Install required packages"
sudo apt-get install -y nginx apache2 libapache2-mod-wsgi libpq5 redis-server git-core postgresql solr-jetty openjdk-7-jre 

echo "** Install CKAN"
cd /vagrant/data/
sudo dpkg -i python-ckan_2.8.0b-trusty1_amd64.deb
cd /vagrant

echo "** Set up the database"
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres psql -c "ALTER USER ckan_default with password 'pass'"
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

echo "** Eedit solr jetty coinfiguration"
sed -i "s/NO_START=1/NO_START=0/" /etc/default/jetty
sed -i "s/#JETTY_HOST=\$(uname -n)/JETTY_HOST=127\.0\.0\.1/" /etc/default/jetty
sed -i "s/#JETTY_PORT=8080/JETTY_PORT=8983/" /etc/default/jetty

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



