#
# Cookbook Name:: splunk
# Provider:: forwarder
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
  unless node[:splunk][:server].has_forwarder?("#{new_resource.name}:#{new_resource.port}")
    Chef::Log.info "Adding forwarding server #{new_resource.name}:#{new_resource.port}"
    node[:splunk][:server].add_forwarder("#{new_resource.name}:#{new_resource.port}")
  end
end

action :remove do
  if node[:splunk][:server].has_forwarder?("#{new_resource.name}:#{new_resource.port}")
    Chef::Log.info "Removing forwarding server #{new_resource.name}:#{new_resource.port}"
    node[:splunk][:server].remove_forwarder("#{new_resource.name}:#{new_resource.port}")
  end
end
