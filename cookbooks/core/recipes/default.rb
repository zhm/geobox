%w[wget curl ack python-software-properties autoconf bison flex libyaml-dev libtool make vim].each do |pkg|
  package pkg do
    action :install
  end
end

install_prefix = "/usr/local"

["add-apt-repository ppa:ubuntugis/ubuntugis-unstable -y", "apt-get update"].each do |cmd|
  execute cmd do
    user "root"
  end
end

["sudo add-apt-repository ppa:mapnik/nightly-2.0 -y", "apt-get update"].each do |cmd|
  execute cmd do
    user "root"
  end
end

# Geo packages
%w[
  libsqlite3-dev
  libproj-dev
  libgeos-dev
  libspatialite-dev
  libgeotiff-dev
  libgdal-dev
  gdal-bin
  libmapnik-dev
  mapnik-utils
  python-dev
  python-setuptools
  python-pip
  python-gdal
  python-mapnik
  postgresql-9.1
  postgresql-server-dev-9.1
  postgresql-plpython-9.1
  libjson0-dev
  redis-server
  libxslt-dev
  unzip
  unp
  osm2pgsql
  osmosis
  protobuf-compiler
  libprotobuf-dev
  libtokyocabinet-dev
  python-psycopg2
  imagemagick
  libmagickcore-dev
  libmagickwand-dev
].each do |pkg|
  package pkg do
    action :install
  end
end

install_prefix = "/usr/local"


execute "apt-get update" do
  user "root"
end

execute "install PostGIS 2.x" do
  command <<-EOS
    if [ ! -d /usr/share/postgresql/9.1/contrib/postgis-2.0 ]
    then
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
      curl -s https://raw.github.com/gist/c83798ee55a08b7a5de5/813a2ba7543697789d2b5af6fae2cabf547cef54/pg_hba.conf -o /etc/postgresql/9.1/main/pg_hba.conf &&
      curl -s https://raw.github.com/gist/bdf5accb7b328f7f596a/0f3a969132150655c861e2ea22852fdd16eac02c/postgresql.conf -o /etc/postgresql/9.1/main/postgresql.conf &&
      /etc/init.d/postgresql restart &&
      echo "CREATE ROLE vagrant LOGIN;"                  | psql -U postgres &&
      echo "CREATE DATABASE vagrant;"                    | psql -U postgres &&
      echo "ALTER USER vagrant SUPERUSER;"               | psql -U postgres &&
      echo "ALTER USER vagrant WITH PASSWORD 'vagrant';" | psql -U postgres &&
      echo "CREATE DATABASE template_postgis;"           | psql -U postgres &&
      echo "CREATE EXTENSION postgis;"                   | psql -U postgres -d template_postgis &&
      echo "CREATE EXTENSION postgis_topology;"          | psql -U postgres -d template_postgis &&
      echo "GRANT ALL ON geometry_columns TO PUBLIC;"    | psql -U postgres -d template_postgis &&
      echo "GRANT ALL ON spatial_ref_sys TO PUBLIC;"     | psql -U postgres -d template_postgis
    fi
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
  cwd "#{install_prefix}/src/ry"
  command <<-EOS
    [ -x #{install_prefix}/bin/ry ] || PREFIX=#{install_prefix} make install
  EOS
  action :run
  user "root"
end

execute "install ruby 1.9.3" do
  command <<-EOS
    [ -x #{install_prefix}/lib/ry/current/bin/ruby ] ||
    #{install_prefix}/bin/ry install https://github.com/ruby/ruby/tarball/v1_9_3_195 1.9.3 --enable-shared=yes
  EOS
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
  cwd "#{install_prefix}/src/n"
  command <<-EOS
    make install && n 0.8.9
  EOS
  action :run
  user 'root'
end

execute "install standard node modules" do
  modules = %w(coffee-script underscore node-gyp)
  command modules.map {|m| "npm install -g #{m}" }.join(' && ')
  action :run
  user 'root'
end

# CARTODB

execute "install pip" do
  command "easy_install pip"
  action :run
  user 'root'
end

execute "install python dependencies for CartoDB" do
  command <<-EOS
    pip install 'chardet==1.0.1' &&
    pip install 'argparse==1.2.1' &&
    pip install 'brewery==0.6' &&
    pip install 'redis==2.4.9' &&
    pip install 'hiredis==0.1.0' &&
    pip install -e 'git+https://github.com/RealGeeks/python-varnish.git@0971d6024fbb2614350853a5e0f8736ba3fb1f0d#egg=python-varnish==0.1.2'
  EOS
  action :run
  user 'root'
end


git "CartoDB-SQL-API" do
  repository "git://github.com/Vizzuality/CartoDB-SQL-API.git"
  reference 'master'
  destination "#{install_prefix}/src/CartoDB-SQL-API"
  action :checkout
  user "root"
end

execute "setup CartoDB-SQL-API" do
  command "cd #{install_prefix}/src/CartoDB-SQL-API && npm install"
end

git "Windshaft-cartodb" do
  repository "git://github.com/Vizzuality/Windshaft-cartodb.git"
  reference 'master'
  destination "#{install_prefix}/src/Windshaft-cartodb"
  action :checkout
  user "root"
end

execute "setup Windshaft-cartodb" do
  cwd "#{install_prefix}/src/Windshaft-cartodb"
  command <<-EOS
    sudo npm install
  EOS
  user 'root'
end

execute "start Windshaft-cartodb" do
  cwd "#{install_prefix}/src/Windshaft-cartodb"
  command <<-EOS
    mkdir -p log pids
    chown -R vagrant:vagrant log pids
    [ -f pids/windshaft.pid ] && kill `cat pids/windshaft.pid`
    nohup node app.js development >> #{install_prefix}/src/Windshaft-cartodb/log/development.log 2>&1 &
    echo $! > #{install_prefix}/src/Windshaft-cartodb/pids/windshaft.pid
  EOS
  user 'root'
end


git "CartoDB" do
  repository "git://github.com/Vizzuality/cartodb.git"
  reference 'master'
  destination "#{install_prefix}/src/cartodb"
  action :checkout
  user "root"
end

execute "setup cartodb" do
  # strip out the ruby-debug gem from the Gemfile since it consistently causes problems and
  # doesn't seem to install properly in all ruby environments and OS's.
  # also, overwrite `script/create_dev_user` with a custom one that doesn't prompt
  cwd "#{install_prefix}/src/cartodb"
  command <<-EOS
    if [ ! -f config/database.yml ]
    then
      chown -R vagrant:vagrant #{install_prefix}/src/cartodb

      sed 's/.*gem "ruby-debug.*//g' Gemfile > Gemfile.tmp && mv Gemfile.tmp Gemfile
      sed 's/^echo -n "Enter.*//g' script/create_dev_user > script/create_dev_user.tmp && mv script/create_dev_user.tmp script/create_dev_user

      export RY_PREFIX=#{install_prefix} &&
      export PATH=$RY_PREFIX/lib/ry/current/bin:$PATH

      #{install_prefix}/lib/ry/current/bin/bundle install --binstubs &&
      curl -s https://raw.github.com/gist/21c52f1eb9862a1dfffa/58cc1436d23153be0ad2502c8ed5459847c85685/app_config.yml -o config/app_config.yml &&
      curl -s https://raw.github.com/gist/4c503e531fd54b3cbcec/0a435609a58e3f8401cfee5990e173b170e2cc82/database.yml -o config/database.yml &&
      echo "127.0.0.1 admin.localhost.lan"   | tee -a /etc/hosts &&
      echo "127.0.0.1 admin.testhost.lan"    | tee -a /etc/hosts &&
      echo "127.0.0.1 cartodb.localhost.lan" | tee -a /etc/hosts &&
      PASSWORD=cartodb ADMIN_PASSWORD=cartodb EMAIL=admin@cartodb sh script/create_dev_user cartodb
    fi
  EOS
  user "root"
end

execute "start cartodb" do
  cwd "#{install_prefix}/src/cartodb"
  command <<-EOS
    mkdir -p public log tmp pids
    chown -R vagrant:vagrant public log tmp pids
    [ -f pids/cartodb.pid ] && kill `cat pids/cartodb.pid`
    export RY_PREFIX=#{install_prefix}
    export PATH=$RY_PREFIX/lib/ry/current/bin:$PATH
    nohup bundle exec rails server >> #{install_prefix}/src/cartodb/log/development.log 2>&1 &
    echo $! > #{install_prefix}/src/cartodb/pids/cartodb.pid
  EOS
  user 'root'
end

execute "install imposm" do
  command <<-EOS
    pip install imposm.parser &&
    pip install Shapely &&
    pip install imposm
  EOS
  user 'root'
end
