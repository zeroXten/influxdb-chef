#
# Cookbook Name:: influxdb
# Recipe:: default
#
# Copyright (C) 2014 Fraser Scott
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'uri'

package_file = File.join(Chef::Config[:file_cache_path], node.influxdb.package.name)

remote_file package_file do
  source URI.join(node.influxdb.package.base_url, node.influxdb.package.name).to_s
  action :create_if_missing
end

platform_provider = case node.platform_family
when 'debian'
  Chef::Provider::Package::Dpkg
when 'rhel'
  Chef::Provider::Package::Rpm
end

package 'influxdb' do
  source package_file
  provider platform_provider
end

group node.influxdb.group

user node.influxdb.user do
  supports  :manage_home => true
  gid       node.influxdb.group
  system    true
end

# TOML gem doesn't actually work properly, so for now we're going to have to use a
# basic config file
#chef_gem 'toml'
#require 'toml'
template node.influxdb.config_file do
  user node.influxdb.user
  group node.influxdb.group
  mode 0644
  cookbook node.influxdb.config_cookbook
  variables({
    :config => node.influxdb.config
  })
  #content TOML::Generator.new(node.influxdb.config.to_hash).body
end

limits_config 'influxdb' do
  limits node.influxdb.limits.inject([]) { |a,(k,v)| a << v; a }
end

ruby_block 'enable pam limits' do
  block do
    file = Chef::Util::FileEdit.new("/etc/pam.d/common-session")
    file.insert_line_if_no_match(/session\s+required\s+pam_limits\.so/, 'session    required   pam_limits.so')
    file.write_file
  end
  only_if { node.influxdb.enable_pam_limits }
end

service 'influxdb' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  subscribes :restart, "template[#{node.influxdb.config_file}]"
end
