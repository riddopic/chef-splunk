#
# Cookbook Name:: splunk
# Provider:: listener
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
  if (new_resource.protocal == 'tcp' && !node[:splunk][:server].has_tcp_listener?(new_resource.port)) ||
     (new_resource.protocal == 'udp' && !node[:splunk][:server].has_udp_listener?(new_resource.port))
    Chef::Log.info "Adding listener #{new_resource.protocal}:#{new_resource.port}"
    eval "node[:splunk][:server].add_#{new_resource.protocal}_listener(new_resource.port)"
  end
end

action :remove do
  if (new_resource.protocal == 'tcp' && node[:splunk][:server].tcp_listener.include?(new_resource.port)) ||
     (new_resource.protocal == 'udp' && node[:splunk][:server].udp_listener.include?(new_resource.port))
    Chef::Log.info "Removing listener #{new_resource.protocal}:#{new_resource.port}"
    eval "node[:splunk][:server].remove_#{new_resource.protocal}_listener(new_resource.port)"
  end
end
