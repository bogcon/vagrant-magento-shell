# -*- mode: ruby -*-
# vi: set ft=ruby :

####
## Vagrant configuration file.
##
## @author    Bogdan Constantinescu <bog_con@yahoo.com>
## @copyright (c) 2015-2016 Bogdan Constantinescu
## @license   New BSD License (http://opensource.org/licenses/BSD-3-Clause)
## @link      Github https://github.com/bogcon/vagrant-magento-shell
####

require 'yaml'
require 'uri'

#check/install needed plugins
requiredPlugins = { 'vagrant-hostsupdater' => '>=1.0.1', 'vagrant-vbguest' => ">=0.11.0" }
installedPlugins = false
requiredPlugins.each do |plugin, version|
  unless Vagrant.has_plugin?(plugin, version)
    system "vagrant plugin install #{plugin}"
    installedPlugins = true
  end
end
if installedPlugins == true
  puts 'Please run `vagrant up` again.'
  exit 1
end

# read Vagrant configuration
if not File.exist?(File.join(File.dirname(__FILE__), 'Vagrant.config.yml'))
    puts "Please provide a 'Vagrant.config.yml' file. Please read documentation for more information."
    exit 1
end
vagrantConfig = YAML.load_file File.join(File.dirname(__FILE__), 'Vagrant.config.yml')
storeUrl = URI.parse(vagrantConfig['magento_installation']['store_url'])

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/wily#{vagrantConfig['vm']['ubuntu_arch']}"
  config.vm.hostname = storeUrl.host
  config.vm.network :private_network, ip: vagrantConfig['ip']
  config.hostsupdater.aliases = [ storeUrl.host ]
  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--memory", "#{vagrantConfig['vm']['memory']}", "--name", "#{storeUrl.host}"]
  end
  config.vm.synced_folder "#{vagrantConfig['synced_folder']['host_path']}", "#{vagrantConfig['synced_folder']['guest_path']}", owner:"vagrant", group: "www-data"
  config.vm.provision "shell", path: "bootstrap.sh", args: "-p #{vagrantConfig['mysql']['pass']} -w #{vagrantConfig['magento_installation']['version']} -s #{vagrantConfig['magento_installation']['store_url']} -f #{vagrantConfig['magento_installation']['admin_firstname']} -l #{vagrantConfig['magento_installation']['admin_lastname']} -e #{vagrantConfig['magento_installation']['admin_email']} -a #{vagrantConfig['magento_installation']['admin_username']} -b #{vagrantConfig['magento_installation']['admin_pass']} -v #{storeUrl.host} -d #{vagrantConfig['mysql']['db']} -u #{vagrantConfig['mysql']['user']} -m #{vagrantConfig['magento_account']['mageid']} -t #{vagrantConfig['magento_account']['token']} -g #{vagrantConfig['synced_folder']['guest_path']}"
  if File.exist?(File.join(Dir.home, '.gitconfig'))
     config.vm.provision "file", source: File.join(Dir.home, '.gitconfig'), destination: ".gitconfig"
  end
end

