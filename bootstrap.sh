#!/usr/bin/env bash

####
## Shell provisioner script for initializing Magento development environment.
##
## @author    Bogdan Constantinescu <bog_con@yahoo.com>
## @copyright (c) 2015-2016 Bogdan Constantinescu
## @license   New BSD License (http://opensource.org/licenses/BSD-3-Clause)
## @link      Github https://github.com/bogcon/vagrant-magento-shell
####



# read params
while getopts ":p:s:v:w:f:l:a:e:b:d:h:u:m:t:g:" opt; do
  case $opt in
    p) MYSQL_PWD="$OPTARG"
    ;;
    s)
        STORE_URL="$OPTARG"
        # add final slash (magento requires so)
        if [ "${STORE_URL: -1}" != "/" ]; then
            STORE_URL="$STORE_URL/"
        fi
    ;;
    v) VIRTUAL_HOSTNAME="$OPTARG"
    ;;
    w) MAGENTO_VERSION="$OPTARG"
    ;;
    f) ADMIN_FIRSTNAME="$OPTARG"
    ;;
    l) ADMIN_LASTNAME="$OPTARG"
    ;;
    a) ADMIN_USERNAME="$OPTARG"
    ;;
    e) ADMIN_EMAIL="$OPTARG"
    ;;
    b) ADMIN_PWD="$OPTARG"
    ;;
    d) MYSQL_DB="$OPTARG"
    ;;
    u) MYSQL_USER="$OPTARG"
    ;;
    m) MAGEID="$OPTARG"
    ;;
    t) MAGETOKEN="$OPTARG";
    ;;
    g) HOST_PATH="$OPTARG";
    ;;
    h)
        bold=`tput bold`
        normal=`tput sgr0`
        cat <<HELP
${bold}DESCRIPTION${normal}
    Shell provisioner script for initializing Magento development environment.
    Features:
        Apache + PHP-FPM
        MySQL + phpMyAdmin
        Magento CE 1.9.x + sample data
        git, vim, curl, different usefull php extensions
        nice shell renderer

${bold}SYNOPSYS${normal}
    /path/to/bootstrap.sh [-v <hostname>] [-s <mage_store_url>]
                          [-w <mage_version>] [-f <mage_admin_firstname>]
                          [-l <mage_admin_lastname>] [-e <mage_admin_email>]
                          [-a <mage_admin_username>] [-b <mage_admin_password>]
                          [-d <database_name>] [-u <db_user>] [-p <db_pass>]
                          [-g <guest_path>] -m <mageid> -t <token>
                          [-h]

${bold}OPTIONS${normal}
    -p    MySQL 's user password; default is "123".
    -u    MySQL 's user; default is "root".
    -v    Apache virtual server name; default is "magento.dev".
    -s    Magento 's url; default is "http://magento.dev/".
    -w    Magento CE version to install. Default is "1.9.2.3".
    -f    Magento admin 's firstname; default is "John".
    -l    Magento admin 's lastname; default is "Doe".
    -e    Magento admin 's email; default is "admin@example.com".
    -a    Magento admin 's username; default is "admin".
    -b    Magento admin 's password; default is "demopassword123".
    -d    MySQL database name. Default is "magento_{version}"
    -g    Host path. Path to symlink to html dir (example: your magento project)
    -m    Magento ID. Required. See http://magento.stackexchange.com/a/58031
    -t    Magento token. Required. See http://magento.stackexchange.com/a/58031
    -h    Prints this help.

${bold}AUTHOR${normal}
    Written by Bogdan Constantinescu

${bold}LICENSE${normal}
    Copyright (c) 2015-2016, Bogdan Constantinescu <bog_con@yahoo.com>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
HELP
       exit 0
    ;;
    \?) echo "Invalid option -$OPTARG. Run this script with -h flag for help." >&2
    ;;
  esac
done

# default params values if no proper arguments passed
if [ "$MYSQL_PWD" = "" ]; then
    MYSQL_PWD="123"
fi
if [ "$STORE_URL" = "" ]; then
    STORE_URL="http://magento.dev/"
fi
if [ "$VIRTUAL_HOSTNAME" = "" ]; then
    VIRTUAL_HOSTNAME="magento.dev"
fi
if [ "$MAGENTO_VERSION" = "" ]; then
    MAGENTO_VERSION="1.9.2.3"
fi
if [ "$ADMIN_FIRSTNAME" = "" ]; then
    ADMIN_FIRSTNAME="John"
fi
if [ "$ADMIN_LASTNAME" = "" ]; then
    ADMIN_LASTNAME="Doe"
fi
if [ "$ADMIN_USERNAME" = "" ]; then
    ADMIN_USERNAME="admin"
fi
if [ "$ADMIN_EMAIL" = "" ]; then
    ADMIN_EMAIL="admin@example.com"
fi
if [ "$ADMIN_PWD" = "" ]; then
    ADMIN_PWD="demopassword123"
fi
if [ "$MYSQL_DB" = "" ]; then
    MYSQL_DB="magento_$MAGENTO_VERSION"
fi
if [ "$MYSQL_USER" = "" ]; then
    MYSQL_USER="root"
fi

# check params
if [ "$MAGEID" = "" ]; then
    echo "Please provide a MAGEID."
    exit 1
fi
if [ "$MAGETOKEN" = "" ]; then
    echo "Please provide a MAGETOKEN."
    exit 1
fi
if [ "$HOST_PATH" = "" ]; then
   echo "Please provide the host path to your magento project."
fi
ADMIN_PWD_LEN=$(echo ${#ADMIN_PWD})
if [ $ADMIN_PWD_LEN -lt 7 ]; then
    echo "[ERR] Admin password must be at least 7 characters (magento requires so)"
    exit 1
fi

# init other variables used in this script
MYSQL_HOST="localhost"

echo "[INFO] MAGEID: $MAGEID"
echo "[INFO] MAGETOKEN: $MAGETOKEN"
echo "[INFO] MySQL pwd: $MYSQL_PWD"
echo "[INFO] Magento version: $MAGENTO_VERSION"
echo "[INFO] Magento sample data version: $SAMPLE_DATA_VERSION"
echo "[INFO] Magento db: $MYSQL_DB"
echo "[INFO] Magento db user: $MYSQL_USER"
echo "[INFO] Magento store url: $STORE_URL"
echo "[INFO] Magento backend admin firstname: $ADMIN_FIRSTNAME"
echo "[INFO] Magento backend admin lastname: $ADMIN_LASTNAME"
echo "[INFO] Magento backend admin email: $ADMIN_EMAIL"
echo "[INFO] Magento backend admin username: $ADMIN_USERNAME"
echo "[INFO] Magento backend admin pwd: $ADMIN_PWD"

# add repo for libapache2-mod-fastcgi
echo -e "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -cs) restricted multiverse\ndeb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs) restricted multiverse" | sudo tee -a /etc/apt/sources.list > /dev/null
apt-get update

# install Apache and php-fpm
apt-get install -y apache2-mpm-worker libapache2-mod-fastcgi php5-fpm
a2enmod "actions" "fastcgi" "alias" "expires" "headers" "rewrite"

# configure apache to use php-fpm
touch /usr/lib/cgi-bin/php5.fcgi
chown -R www-data:www-data /usr/lib/cgi-bin
cat > /etc/apache2/conf-available/php5-fpm.conf <<- EOM
<IfModule mod_fastcgi.c> 
    AddHandler php5.fcgi .php 
    Action php5.fcgi /php5.fcgi 
    Alias /php5.fcgi /usr/lib/cgi-bin/php5.fcgi 
    FastCgiExternalServer /usr/lib/cgi-bin/php5.fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization -idle-timeout 3600 
    <Directory /usr/lib/cgi-bin>
        Require all granted
    </Directory> 
</IfModule>
EOM
a2enconf php5-fpm

# install other usefull php extensions
apt-get install -y php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap mcrypt php5-mcrypt php5-geoip php5-xdebug
php5enmod mcrypt

# install MySQL
apt-get install -y debconf-utils # utils for passing default values to packages when installing
echo mysql-server-5.6 mysql-server/root_password password $MYSQL_PWD | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $MYSQL_PWD | debconf-set-selections
apt-get install -y mysql-common mysql-server mysql-client 

# install phpMyAdmin, it will be available at http://host[:port]/phpmyadmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_PWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_PWD" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $MYSQL_PWD" | debconf-set-selections
apt-get install -y phpmyadmin
if [ ! -f /etc/apache2/sites-enabled/phpmyadmin.conf ]; then 
    ln -s /etc/phpmyadmin/apache.conf /etc/apache2/sites-enabled/phpmyadmin.conf
fi

# configure virtual host for magento
WWW_DIR="/var/www/html"
if [ ! -f /etc/apache2/sites-enabled/magento-dev.conf ]; then
    cat > /etc/apache2/sites-enabled/magento-dev.conf <<EOM
    <VirtualHost *:80>
        ServerName $VIRTUAL_HOSTNAME
        SetEnv MAGE_IS_DEVELOPER_MODE on
        DocumentRoot $WWW_DIR
        <Directory "$WWW_DIR">
             DirectoryIndex index.php
             Options Indexes FollowSymLinks MultiViews
             AllowOverride All
             Order allow,deny
             allow from all
        </Directory>      
        ErrorLog /var/log/apache2/error.log
        LogLevel warn
        CustomLog /var/log/apache2/access.log combined
    </VirtualHost>
EOM
fi

# restart services
/etc/init.d/apache2 restart
/etc/init.d/php5-fpm restart

# other usefull development packages
apt-get install -y vim git curl
# nice shell renderer
if ! grep -Fxq "function parse_git_branch {" /home/vagrant/.bashrc
then
    cat <<'EOT' >> /home/vagrant/.bashrc

    function parse_git_branch {
        git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    function proml {
        local        BLUE="\[\033[0;34m\]"
        local         RED="\[\033[0;31m\]"
        local   LIGHT_RED="\[\033[1;31m\]"
        local       GREEN="\[\033[0;32m\]"
        local LIGHT_GREEN="\[\033[1;32m\]"
        local       WHITE="\[\033[1;37m\]"
        local  LIGHT_GRAY="\[\033[0;37m\]"
        case $TERM in
            xterm*) TITLEBAR='\[\033]0;\u@\h:\w\007\]'
            ;;
            *) TITLEBAR=""
            ;;
        esac

        PS1="$WHITE${TITLEBAR}\$BLUE[$WHITE\$(date +%H:%M)$WHITE]\$WHITE[$RED\u$WHITE@$BLUE\h$WHITE:$BLUE\w$GREEN\$(parse_git_branch)$WHITE]\$WHITE\$ "
        PS2='> '
        PS4='+ '
    }
    proml
    cd /var/www/html

EOT
fi

# symlink web root directory with vagrant shared folder.
if ! [ -L "$WWW_DIR" ]; then
    if [ -d "$WWW_DIR" ]; then
    	rm -rf "$WWW_DIR"
    fi
    ln -fs $HOST_PATH $WWW_DIR
fi

# download magento and extract files
cd $WWW_DIR
if [ ! -f app/Mage.php ]; then
    echo "[INFO] Downloading magento data..."
    if [ ! -f magento-$MAGENTO_VERSION.tar.gz ]; then 
        curl -O "https://$MAGEID:$MAGETOKEN@www.magentocommerce.com/products/downloads/file/magento-$MAGENTO_VERSION.tar.gz"
    fi
    tar -zxf magento-$MAGENTO_VERSION.tar.gz
    if [ $MAGENTO_VERSION = "1.9.2.3" ]; then
    	TAR_ROOT_PATH="./magento"
    else
 	TAR_ROOT_PATH="./"
    fi
    if [ ! -f compressed-magento-sample-data-1.9.1.0.tgz ]; then 
        curl -O "https://raw.githubusercontent.com/Vinai/compressed-magento-sample-data/1.9.1.0/compressed-magento-sample-data-1.9.1.0.tgz"
    fi
    tar -zxf compressed-magento-sample-data-1.9.1.0.tgz
    cp -R magento-sample-data-1.9.1.0/media/* $TAR_ROOT_PATH/media/
    cp -R magento-sample-data-1.9.1.0/skin/* $TAR_ROOT_PATH/skin/
    mv magento-sample-data-1.9.1.0/magento_sample_data_for_1.9.1.0.sql ./data.sql
    if [ $MAGENTO_VERSION = "1.9.2.3" ]; then
        cp -R magento/* magento/.htaccess* .    
    fi

    # create magento db and import sample data into it
    echo "[INFO] Creating magento db..."
    mysql -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PWD -Bse "DROP DATABASE IF EXISTS \`$MYSQL_DB\`; CREATE DATABASE \`$MYSQL_DB\` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    echo "[INFO] Importing magento sample data..."
    mysql -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PWD $MYSQL_DB < data.sql

    # remove unnecessary files
    rm -rf magento-sample-data-1.9.1.0/  data.sql magento-$MAGENTO_VERSION.tar.gz compressed-magento-sample-data-1.9.1.0.tgz
    if [ $MAGENTO_VERSION = "1.9.2.3" ]; then
        rm -rf magento/ 
    fi
else
    echo "[INFO] Magento already downloaded."
fi

# install magento
if [ ! -f app/etc/local.xml ]; then
    echo "[INFO] Installing magento..."
    chmod -R o+w media var
    chmod o+w var var/.htaccess app/etc
    php -f install.php -- --license_agreement_accepted yes \
            --locale en_US --timezone America/Los_Angeles --default_currency "USD" \
            --db_host "$MYSQL_HOST" --db_name "$MYSQL_DB" --db_user "$MYSQL_USER" --db_pass "$MYSQL_PWD" --db_prefix "" \
            --url "$STORE_URL" --use_rewrites yes --skip_url_validation yes \
            --use_secure no --secure_base_url "" --use_secure_admin no \
            --admin_lastname "$ADMIN_LASTNAME" --admin_firstname "$ADMIN_FIRSTNAME" --admin_email "$ADMIN_EMAIL" \
            --admin_username "$ADMIN_USERNAME" --admin_password "$ADMIN_PWD" \
    echo
    php -f shell/indexer.php reindexall

    echo ">>>>>   Done."
    echo ">>>>>   Magento frontend: $STORE_URL"
    echo ">>>>>   Magento backend: ${STORE_URL}index.php/admin  user: $ADMIN_USERNAME, pass: $ADMIN_PWD"
else
    echo "[INFO] Magento already installed."
    echo ">>>>>   Done."
fi

