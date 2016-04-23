# -*- mode: ruby -*-
Vagrant.configure("2") do |config|

  config.vm.box     = "puppetlabs/centos-6.6-64-nocm"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  #ruby 1.8 on cent6 cworks with 1.1.0
  config.vm.provision :shell, :inline => <<-EOH
    rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    yum install -y puppet
    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install inifile --version 1.1.0 --no-ri --no-rdoc
  EOH

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "init.pp"
    puppet.module_path    = "modules"
    puppet.options = ""
  end

  config.vm.provision :shell, :inline => <<-EOH
    echo $(facter ipaddress)  $(facter fqdn) >> /etc/hosts
  EOH

end
