#
# Cookbook Name:: splunk
# Recipe:: default
#
# Copyright 2011, Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

package 'splunk'

bash 'enable_boot' do
  user 'root'
  code <<-EOH
    #{node[:splunk][:root]}/bin/splunk start --accept-license
    #{node[:splunk][:root]}/bin/splunk enable boot-start
    #{node[:splunk][:root]}/bin/splunk enable listen 9997 -auth admin:changeme
  EOH
  not_if ::File.exists?('/etc/init.d/splunk').to_s
end

service 'splunk' do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

ruby_block "splunk data load" do
  block do
    node.set[:splunk][:server] = Chef::Splunk.new(node)
  end
  action :create
end

splunk_user 'admin' do
  password data_bag_item('apps', 'splunk')['password'] || 'changeme'
  full_name 'Administrator'
  role 'admin'
  action :edit
end

search(:users, '*:*') do |user|
  splunk_user user[:id] do
    password user[:password]
    full_name user[:comment]
  end  
end

splunk_listener 514 do
  protocal 'tcp'
end

splunk_listener 514 do
  protocal 'udp'
end

web_app 'splunk_proxy' do
  template 'splunk_proxy.erb'
end

apache_site 'splunk_proxy'

apache_site '000-default' do
  enable false
end
