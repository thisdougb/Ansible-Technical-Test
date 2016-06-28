# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "hashicorp/precise64"
  #config.vm.box = "QuickUbuntu"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "app1" do |app1|
   app1.vm.network "private_network", ip: "192.168.33.20"
  end
  config.vm.define "app2" do |app2|
   app2.vm.network "private_network", ip: "192.168.33.21"
  end

# NOTE: we can add more application servers here, but you must also
#       add the new host to the ansible.groups group below
#  config.vm.define "app3" do |app3|
#   app3.vm.network "private_network", ip: "192.168.33.22"
#  end

# NOTE: by creating the web1 node last we ensure we have all hostnames/IPs
#       available to Ansible for provisioning hosts files and nginx.conf
#       load balancing.  Vagrant builds the hostlist cumulatively.
  config.vm.define "web1" do |web1|
   web1.vm.network "private_network", ip: "192.168.33.10"
  end

# NOTE: using ansible groups here so there is only a single file to edit
#       if you want to increase the number of nodes deployed.
  config.vm.provision :ansible do |ansible|
    ansible.limit = "all"
    ansible.playbook = "provisioning/site.yml"
    ansible.groups = {
      "appservers" => ["app1", "app2"],
      "webservers" => ["web1"],
    }
  end
end
