
if node.recipes.include?('splunk::server')
  include_recipe 'splunk::server'
else
  node.set[:splunk][:root] = '/opt/splunkforwarder'
  node.set[:splunk][:server] = search(:node, 'recipes:splunk\:\:server').first[:fqdn]

  package 'splunkforwarder'

  bash 'enable_boot' do
    user 'root'
    code <<-EOH
    #{node[:splunk][:root]}/bin/splunk start --accept-license
    #{node[:splunk][:root]}/bin/splunk enable boot-start
    EOH
    not_if ::File.exists?('/etc/init.d/splunk').to_s
  end

  service 'splunk' do
    supports :status => true, :restart => true, :reload => false
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

  splunk_forwarder node[:splunk][:server]
end
