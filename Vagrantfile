Vagrant::Config.run do |config|
  config.vm.box = "debian"

  config.vm.forward_port 80,   8080
  config.vm.forward_port 22,   2222
  config.vm.forward_port 3000, 3030

  config.vm.network :hostonly, "22.22.22.22"

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "git"
    chef.add_recipe "zsh"
    chef.add_recipe "apt"
    chef.add_recipe "core"
    chef.add_recipe "ohai"
    chef.add_recipe "nginx"
    chef.add_recipe "mongodb"
    chef.json = { :user => 'vagrant' }
  end
end
