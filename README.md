vagrant-magento-shell v1.0.0
================================================
####Magento development environment made easily with shell provisioning.

Features
--------------------
 - Supports different Magento CE versions: 1.7.0.2 | 1.8.1.0 | 1.9.1.0
 - Magento sample data
 - Supports configuring the hostname and store url under which Magento will be available, the backend admin username/password.
 - Ubuntu Server 14.04 LTS (Trusty) 32 bit | 64 bit
 - Apache + PHP-FPM
 - MySQL + phpMyAdmin
 - Git, vim, curl
 - Different usefull php extensions
 - Nice (colored) shell rendering

Prerequisites
--------------------
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/)

Installation
-------------
1. Using GIT  
```sh
git clone https://github.com/bogcon/vagrant-magento-shell.git
cd vagrant-magento-shell/
# change Vagrantfile configuration params if needed (see Configuration chapter), then run:
vagrant up
```
2. Download the ZIP archive from [here](https://github.com/bogcon/vagrant-magento-shell/archive/master.zip)
```sh
wget https://github.com/bogcon/vagrant-magento-shell/archive/master.zip
unzip master.zip
cd vagrant-magento-shell-master/
# change Vagrantfile configuration params if needed (see Configuration chapter), then run:
vagrant up
```

Configuration
-------------
Open `Vagrantfile` and see that there are a couple of things that can be configured:  

| PARAM               | DESCRIPTION                                                          | DEFAULT                  |
|---------------------|----------------------------------------------------------------------|:------------------------:|
| ARCH                | The architecure of the ubuntu machine to be installed (32 / 64) bits | 64                       |
| HOST_PORT           | The host port that forwards to virtual machine 's Apache 80 port     | 8181                     |
| VIRTUAL_HOSTNAME    | Apache 's virtual hostname                                           | localhost                |
| STORE_URL           | Magento base store url                                               | http://localhost:8181/   |
| MYSQL_ROOT_PASSWORD | MySQL 's root user password                                          | 123                      |
| MAGENTO_VERSION     | Possible values: 1.7.0.2, 1.8.1.0, 1.9.1.0                           | 1.9.1.0                  |
| ADMIN_FIRSTNAME     | Mage backend admin 's firstname                                      | John                     |
| ADMIN_LASTNAME      | Mage backend admin 's lastname                                       | Doe                      |
| ADMIN_EMAIL         | Mage backend admin 's email                                          | admin@example.com        |
| ADMIN_USERNAME      | Mage backend admin 's username                                       | admin                    |
| ADMIN_PASSWORD      | Mage backend admin 's password                                       | demopassword123          |
| DATABASE_NAME       | MySQL database name                                                  | magento_1.9.1.0          |  

**Example** of installing a Magento 1.7.0.2 on Ubuntu 32 bit that will be available under http://magento.dev url:

    ARCH=32 # can be 32 | 64 (install ubuntu 32bit | 64bit)
    HOST_PORT=8181
    VIRTUAL_HOSTNAME="magento.dev"
    STORE_URL="http://magento.dev/"
    MYSQL_ROOT_PASSWORD="mypass"
    MAGENTO_VERSION="1.7.0.2" # can be 1.7.0.2 | 1.8.1.0 | 1.9.1.0
    ADMIN_FIRSTNAME="Bogdan"
    ADMIN_LASTNAME="Constantinescu"
    ADMIN_EMAIL="bc@example.com"
    ADMIN_USERNAME="admin"
    ADMIN_PASSWORD="123pass123" # must have at least 7 chars
    DATABASE_NAME="custom_project_db"

Also make sure that you add the following line to your `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts` file so that `magento.dev` is mapped to machine 's address `192.168.33.10`.

    192.168.33.10   magento.dev  

License
--------------------
`vagrant-magento-shell` is released under the `New BSD License` which is the 3-clause BSD license.  
You can find a copy of this license in [LICENSE-VMS.txt](LICENSE-VMS.txt).