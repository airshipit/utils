# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu1604"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #config.vm.provider "virtualbox" do |vb|
  #  # Display the VirtualBox GUI when booting the machine
  #  # vb.gui = true
  #end
  [:virtualbox, :parallels, :libvirt, :hyperv].each do |provider|
    config.vm.provider provider do |vplh, override|
      vplh.cpus = 1
      vplh.memory = 2048
    end
  end
  [:vmware_fusion, :vmware_workstation, :vmware_desktop].each do |provider|
    config.vm.provider provider do |vmw, override|
      vmw.vmx["memsize"] = "2048"
      vmw.vmx["numvcpus"] = "1"
    end
  end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.define "aptly" do |node|
    node.vm.hostname = "aptly"

    node.vm.provision "file", source: ".", destination: "$HOME/docker-aptly"

    node.vm.provision :shell, inline: <<-SHELL
       echo htop > /home/vagrant/docker-aptly/assets/packages/list
       echo telnetd >> /home/vagrant/docker-aptly/assets/packages/list
       echo openbsd-inetd >> /home/vagrant/docker-aptly/assets/packages/list
       echo inet-superserver >> /home/vagrant/docker-aptly/assets/packages/list
       echo 'mysql-client (>= 3.6)' >> /home/vagrant/docker-aptly/assets/packages/list
    SHELL

    node.vm.provision "docker" do |d|
      d.build_image "/home/vagrant/docker-aptly -t aptly:test --build-arg PACKAGE_FILE=list"
      d.run "aptly",
            args: "-p '8080:80' -v '/home/vagrant/docker-aptly/assets/nginx:/opt/nginx'",
            image: "aptly:test",
            cmd: "/opt/run_nginx.sh"
    end

    node.vm.provision :shell, inline: <<-SHELL
      sleep 5
      curl -s localhost:8080/aptly_repo_signing.key | apt-key add -
      mv /etc/apt/sources.list /etc/apt/sources.list.backup
      touch /etc/apt/sources.list
      add-apt-repository 'deb http://localhost:8080 xenial main'
      apt-get update
      apt-cache policy htop
      apt-get install -y htop mysql-client
      apt-get install -y telnetd || echo "telnetd was not installed due to blacklist"
    SHELL
  end
end
