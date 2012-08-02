# GeoBox - A hackbox for geo stuff

This is a vagrant box that includes some GIS related tools for hacking. You can use it to get
started with some standard tools without worrying about messing up your local machine.

# Included in VM

* GDAL 1.9.x
* Mapnik 2.0
* PostgreSQL 9.1
* PostGIS 2.0
* NodeJS stable (currently 0.8.x)
* Ruby 1.9.3 + Bundler
* MongoDB 2.x
* nginx
* zsh

# Requirements for host machine

* Ruby
* VirtualBox [Download](https://www.virtualbox.org/wiki/Downloads)
* Vagrant `gem install vagrant`

# Installation

    git clone https://github.com/zhm/geobox
    cd geobox
    vagrant box add debian http://dl.dropbox.com/u/937870/VMs/squeeze64.box

# Usage

to build the VM from the base image and ssh into it:

    vagrant up
    vagrant ssh

exiting ssh from the VM:

    exit

or to stop it from the host:

    vagrant suspend

to destroy the VM from the host to delete it completely or rebuild it:

    vagrant destroy

then to rebuild everything:

    vagrant up


Note: Starting the machine for the first time will take about 20-25 minutes since it builds ruby and node from source.

# TODO

* CartoDB
* TileMill
* EC2 compatible deployment using chef-solo
