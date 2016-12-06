Vagrant.configure(2) do |config|
  config.vm.box = "centos66-minimal-en"
  config.vm.box_url = "https://github.com/tasukujp/vagrant-boxes-packer/releases/download/v1.0.1/CentOS-6.6-x86_64-minimal-en.box"

  config.vm.provider :virtualbox do |vb|
    vb.name = "hive.pseudo.distributed"
    vb.customize ["modifyvm", :id, "--memory", "2048", "--cpus", "2", "--ioapic", "on"]
  end
  config.vm.network :private_network, ip: "192.168.33.40"
  config.vm.hostname = "hive.pseudo.distributed"
  config.vm.provision :shell, path: "setup.sh"
end
