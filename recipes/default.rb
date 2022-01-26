#
# Cookbook:: site_config
# Recipe:: default
#
# Copyright:: (c) 2016 The Authors, All Rights Reserved.

execute 'apt-get update -y'

package 'apache2'

tarball = "#{Chef::Config[:file_cache_path]}/webfiles.tar.gz"

remote_file tarball do
  owner 'root'
  group 'root'
  mode '0644'
  source 'https://github.com/chef-training/site_config/raw/master/webfiles.tar.gz'
end

execute 'extract web files' do
  command "tar -xvf #{tarball} -C /var/www/html/"
  not_if do
    ::File.exist?('/var/www/favicon.ico')
  end
  notifies :run, 'execute[change permissions]', :immediately
end

execute 'change permissions' do
  command 'chown -R www-data .'
  cwd '/var/www/html'
  action :nothing
end

service 'apache2' do
  supports status: true
  action [:enable, :start]
end
