# -*- mode: ruby -*-
# vi: set ft=ruby :

####
## Vagrant configuration file.
##
## @author    Bogdan Constantinescu <bog_con@yahoo.com>
## @copyright (c) 2015 Bogdan Constantinescu
## @license   New BSD License (http://opensource.org/licenses/BSD-3-Clause)
## @link      Github https://github.com/bogcon/vagrant-magento-shell
####

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


# Change the following variables according to your needs
ARCH=64 # can be 32 | 64 (install ubuntu 32bit | 64bit)
HOST_PORT=8181
VIRTUAL_HOSTNAME="localhost"
STORE_URL="http://localhost:#{HOST_PORT}/"
MYSQL_ROOT_PASSWORD="123"
MAGENTO_VERSION="1.9.1.0" # can be 1.7.0.2 | 1.8.1.0 | 1.9.1.0
ADMIN_FIRSTNAME="John"
ADMIN_LASTNAME="Doe"
ADMIN_EMAIL="admin@example.com"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="demopassword123" # must have at least 7 chars
DATABASE_NAME="magento_#{MAGENTO_VERSION}"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty#{ARCH}"
  config.vm.hostname = "magento-dev"
  config.vm.network :forwarded_port, guest: 80, host: HOST_PORT
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--memory", "1024", "--name", "MagentoDev_#{HOST_PORT}"]
  end
  config.vm.provision "shell", path: "bootstrap.sh", args: "-p #{MYSQL_ROOT_PASSWORD} -w #{MAGENTO_VERSION} -s #{STORE_URL} -f #{ADMIN_FIRSTNAME} -l #{ADMIN_LASTNAME} -e #{ADMIN_EMAIL} -a #{ADMIN_USERNAME} -b #{ADMIN_PASSWORD} -v #{VIRTUAL_HOSTNAME} -d #{DATABASE_NAME}"
end
