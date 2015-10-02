# -*- mode: ruby -*-
# vi: set ft=ruby :

server_timezone  = "UTC"

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  
  # Create a forwarded port mapping which allows access to a specific port
  config.vm.network "forwarded_port", guest: 80, host: 8080 
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  # Share an additional folder to the guest VM.
  config.vm.synced_folder ".", "/home/vagrant"
  
  # Virtual box customization
  config.vm.provider "virtualbox" do |vb|
	vb.memory = "512"
	vb.cpus = "1"
  end
 
  config.vm.provision :shell, :path => "bootstrap.sh", :args => [server_timezone]
end
