#
# Cookbook Name:: site_config
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'apt-get update -y'

package 'apache2'

template '/var/www/html/index.html' do
  source 'index.html.erb'
  owner 'www-data'
  group 'www-data'
  sensitive true
end

tarball = "#{Chef::Config[:file_cache_path]}/webfiles.tar.gz"

remote_file tarball do
  owner 'root'
  group 'root'
  mode '0644'
  source 'https://s3.amazonaws.com/binamov-delivery/webfiles.tar.gz'
end

execute 'extract web files' do
  command "tar -xvf #{tarball} -C /var/www/html/"
  not_if do
    ::File.exist?('/var/www/favicon.ico')
  end
end

service 'apache2' do
  supports status: true
  action [:enable, :start]
end
