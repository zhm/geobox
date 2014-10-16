# vi: set ft=ruby :
require 'json'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "precise"

    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    config.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2222
    config.vm.network :forwarded_port, id: 'nginx', guest: 80, host: 80
    config.vm.network :forwarded_port, guest: 3000, host: 3030
    config.vm.network :forwarded_port, guest: 3001, host: 3001
    config.vm.network :forwarded_port, guest: 4000, host: 4000
    config.vm.network :forwarded_port, guest: 5432, host: 5432
    config.vm.network :forwarded_port, guest: 8080, host: 8080

    config.vm.network "private_network", ip: "22.22.22.22"

    json = JSON.parse(File.open('solo.json').read)

    config.vm.provision :chef_solo do |chef|
        json['run_list'].each do |recipe|
            chef.add_recipe recipe
        end
        chef.json = { :user => 'vagrant' }
    end

end
