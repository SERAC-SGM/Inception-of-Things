Vagrant.configure("2") do |config|
  common_script = <<-SHELL
  sudo yum -y install vim tree net-tools telnet git python3
  echo "autocmd filetype yaml setlocal ai ts=2 sw=2 et" > /home/vagrant/.vimrc
  echo "alias python=/usr/bin/python3" >> /home/vagrant/.bashrc
  sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd
  SHELL

  server_script = <<-SHELL
  curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -
  sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token
  SHELL

  worker_script = <<-SHELL
  TOKEN=$(cat /vagrant/token)
  curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" K3S_TOKEN=$TOKEN K3S_URL=https://192.168.56.110:6443 sh -
  SHELL

  config.vm.box = "rockylinux/9"

  config.vm.define "lletournS" do |server|
    server.vm.hostname = "lletournS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--memory", "2048"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--name", "lletournS"]
    end
    server.vm.provision :shell, inline: common_script
    server.vm.provision :shell, inline: server_script
  end

  config.vm.define "lletournSW" do |worker|
    worker.vm.hostname = "lletournSW"
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--memory", "1024"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--name", "lletournSW"]
    end
    worker.vm.provision :shell, inline: common_script
    worker.vm.provision :shell, inline: worker_script
  end
end
