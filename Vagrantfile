# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  precise64_box = 'precise64'
  precise64_url = 'http://files.vagrantup.com/precise64.box'

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box = precise64_box
  config.vm.box_url = precise64_url

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.77.10"

  config.vm.hostname = "sonarqube"

  config.vm.provider :virtualbox do | vbox |
    # Boot in headless mode
    vbox.gui = false
    vbox.name = config.vm.hostname

    # Use VBoxManage to customize the VM. For example to change memory:
    vbox.customize [
      "modifyvm", :id, 
      "--name", config.vm.hostname, 
      "--cpus", "1", 
      "--memory", 
      "1024" 
    ]
  end

  config.vm.provision :shell do | shell |
    shell.path = "scripts/setup.sh"
  end
end