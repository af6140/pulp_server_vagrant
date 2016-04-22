# -*- mode: ruby -*-
Vagrant.configure("2") do |config|

  config.vm.box     = "puppetlabs/centos-6.6-64-nocm"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, :inline => <<-EOH
    rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    yum install -y puppet
    gem install inifile --no-ri --no-rdoc
    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
  EOH

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "init.pp"
    puppet.module_path    = "modules"
    puppet.options = "--debug"
  end

end
