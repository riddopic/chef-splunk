#
# Cookbook Name:: splunk
# Provider:: user
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

action :add do  
  unless node[:splunk][:server].has_user?(new_resource.name)
    Chef::Log.info "Adding user #{new_resource.name} to Splunk server"
    node[:splunk][:server].add_user(new_resource.name, new_resource.password, new_resource.role, new_resource.full_name)
  end
end

action :remove do  
  if node[:splunk][:server].has_user?(new_resource.name)
    Chef::Log.info "Removing user #{new_resource.name} from Splunk server"
    node[:splunk][:server].remove_user(new_resource.name)
  end
end

action :edit do
  if node[:splunk][:server].has_user?(new_resource.name)
    Chef::Log.info "Editing user #{new_resource.name} on Splunk server"
    node[:splunk][:server].edit_user(new_resource.name, new_resource.password, new_resource.role, new_resource.full_name)
  end
end
  