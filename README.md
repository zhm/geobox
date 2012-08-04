# GeoBox - A hackbox for geo stuff

This is a vagrant box that includes some GIS related tools for hacking. You can use it to get
started with some standard tools without worrying about messing up your local machine.

# Included in VM

* Ubuntu 12.04 Precise Pangolin
* GEOS 3.3.3
* Proj 4.7
* SpatiaLite 3.1
* GDAL 1.9.1
* Mapnik 2.0.1
* PostgreSQL 9.1
* PostGIS 2.0.1
* Redis 2.2.x
* MongoDB 2.x
* NodeJS stable (currently 0.8.x)
* Ruby 1.9.3 + Bundler
* CartoDB (master)
* osm2pgsql
* osmosis
* Imposm 2.4
* nginx
* zsh

# Requirements for host machine

* Ruby
* VirtualBox [Download](https://www.virtualbox.org/wiki/Downloads)
* Vagrant `gem install vagrant`

# Installation

    git clone https://github.com/zhm/geobox
    cd geobox
    git submodule init
    git submodule update
    vagrant box add precise http://files.vagrantup.com/precise64.box

# Usage & Setup

to build the VM from the base image and ssh into it:

    vagrant up
    vagrant ssh

exiting ssh from the VM:

    exit

or to stop it from the host:

    vagrant suspend

to destroy the VM from the host (to either delete it completely or rebuild it):

    vagrant destroy

then to rebuild everything:

    vagrant up

Note: Starting the machine for the first time will take about 20-30 minutes since it builds ruby, node, and PostGIS from source.

# Accessing CartoDB

To access the CartoDB server, you need to add something to your host file.

    echo "22.22.22.22 cartodb.localhost.lan" | tee -a /etc/hosts

Once you have cartodb.localhost.lan resolving, you go to `http://cartodb.localhost.lan:3000` in your browser to get to CartoDB.

CartoDB is started using WEBrick in the background, but you can kill it manually and start it via ssh manually if you want:

    cd /usr/local/src/cartodb
    sudo kill `pids/cartodb.pid`
    bundle exec rails server

# Connecting to PostgreSQL

To access the postgres instance from outside the VM (e.g. psql or pgAdmin), use 22.22.22.22 and username `vagrant` and password `vagrant`.
This can be convenient for loading data that's on your local machine or being able to use pgAdmin to get to the database.

# Hacking

If you want to add your own stuff, you will want to take a look at [default.rb](https://github.com/zhm/geobox/blob/master/cookbooks/core/recipes/default.rb). It has most of the hackish code that installs and sets up the box. Improvements are welcome since I have no idea what I'm doing.

# TODO
* Proper init.d scripts and helpers to start/stop CartoDB stuff, or at least some shell aliases?
* nginx setup for CartoDB stuff (preferably an optional setting that "just works" for both WEBrick and nginx)
* TileMill
* Options to use the latest and greatest of all stuff (Mapnik HEAD, PostGIS HEAD, etc)
* Separate some of the stuff from the `core` recipe into different recipes
* Fix all the custom `execute` commands to be more resilient to the `vagrant reload` command so they don't rebuild every time (mostly done, albeit hacky)
* Oh yeah, security, don't use this for production.
* EC2 compatible deployment using chef-solo, see previos item.
