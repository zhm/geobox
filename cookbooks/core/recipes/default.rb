%w[wget curl ack python-software-properties autoconf bison flex libyaml-dev libtool].each do |pkg|
  package pkg do
    action :install
  end
end

# some packages still prompt even with -y, https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/935681
ENV['DEBIAN_FRONTEND'] = 'noninteractive'

install_prefix = "/usr/local"

# add the testing repo so we can get gdal 1.9 and newer mapnik
apt_repository "testing" do
  uri "http://ftp.debian.org/debian"
  distribution 'testing'
  components ["main", "non-free"]
end

execute "apt-get update" do
  user "root"
end

%w(gcc libgdal-dev gdal-bin libmapnik-dev postgresql-9.1 postgresql-server-dev-9.1).each do |cmd|
  execute "apt-get install #{cmd}/testing -y" do
    user "root"
  end
end


execute "install PostGIS 2.x" do
  command <<-EOS
    cd /usr/local/src &&
    wget http://postgis.org/download/postgis-2.0.1.tar.gz &&
    tar xfvz postgis-2.0.1.tar.gz &&
    cd postgis-2.0.1 &&
    ./configure &&
    make &&
    make install &&
    ldconfig &&
    make comments-install &&
    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql &&
    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp &&
    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql &&
    curl -s https://raw.github.com/gist/c83798ee55a08b7a5de5/ed240ae342d8cef1cb956a563b3b9f0bc220ca34/pg_hba.conf -o /etc/postgresql/9.1/main/pg_hba.conf &&
    /etc/init.d/postgresql restart &&
    echo "CREATE ROLE vagrant LOGIN;" | psql -U postgres &&
    echo "CREATE DATABASE vagrant;" | psql -U postgres &&
    echo "ALTER USER vagrant SUPERUSER;" | psql -U postgres &&
    echo "CREATE DATABASE template_postgis;" | psql -U postgres &&
    echo "CREATE EXTENSION postgis;" | psql -U postgres -d template_postgis &&
    echo "CREATE EXTENSION postgis_topology;" | psql -U postgres -d template_postgis
  EOS
  action :run
  user 'root'
end

ENV['PATH'] = "/home/#{node[:user]}/local:#{ENV['PATH']}"

execute "set shell to zsh" do
  command "usermod -s /bin/zsh #{node[:user]}"
  action :run
  user "root"
end

directory "/home/#{node[:user]}/local" do
  owner node[:user]
  group node[:user]
  mode "0755"
  action :create
end

directory "/home/#{node[:user]}/local/src" do
  owner node[:user]
  group node[:user]
  mode "0755"
  action :create
end

directory "#{install_prefix}/src" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

git "ry" do
  repository "git://github.com/zhm/ry.git"
  reference 'master'
  destination "#{install_prefix}/src/ry"
  action :checkout
  user "root"
end

ENV['RY_PREFIX'] = install_prefix

execute "install ry" do
  command "cd #{install_prefix}/src/ry && PREFIX=#{install_prefix} make install"
  action :run
  user "root"
end

execute "install ruby 1.9.3" do
  command "#{install_prefix}/bin/ry install https://github.com/ruby/ruby/tarball/v1_9_3_195 1.9.3 --enable-shared=yes"
  action :run
  user "root"
end

execute "setup ruby" do
  command <<-EOS
    export RY_PREFIX=#{install_prefix} &&
    export PATH=$RY_PREFIX/lib/ry/current/bin:$PATH &&
    #{install_prefix}/lib/ry/current/bin/gem update --system &&
    #{install_prefix}/lib/ry/current/bin/gem install bundler
  EOS

  action :run
  user "root"
end

git "oh-my-zsh" do
  repository "git://github.com/robbyrussell/oh-my-zsh.git"
  reference 'master'
  destination "/home/#{node[:user]}/.oh-my-zsh"
  action :checkout
  user node[:user]
end

execute "install .zshrc" do
  command "curl -L -o /home/#{node[:user]}/.zshrc https://raw.github.com/gist/789ba55f7ab0bf895a1c/5dc934f2737f75b306637c35258b984fc0127005/.zshrc"
  action :run
  user node[:user]
end

execute "install zsh theme" do
  command "curl -L -o /home/#{node[:user]}/.oh-my-zsh/themes/hackbox.zsh-theme https://raw.github.com/gist/1e701eb696d8804fa19c/c729347309a79f6820f4ad6feb7b517242755510/hackbox.zsh-theme"
  action :run
  user node[:user]
end

git "n" do
  repository "git://github.com/zhm/n.git"
  reference 'master'
  destination "#{install_prefix}/src/n"
  action :checkout
  user "root"
end

execute "install n" do
  command [
    "cd #{install_prefix}/src/n",
    "make install",
    "n stable"
  ].join(" && ")

  action :run
  user 'root'
end

execute "install standard node modules" do
  modules = %w(coffee-script underscore node-gyp)
  command modules.map {|m| "npm install -g #{m}" }.join(' && ')
  action :run
  user 'root'
end
