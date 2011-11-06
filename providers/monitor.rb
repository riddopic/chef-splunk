#
# Cookbook Name:: splunk
# Provider:: monitor
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
  if ::File.exists?(new_resource.name)
    unless node[:splunk][:server].has_monitor?(new_resource.name)
      Chef::Log.info "Adding monitor for log #{new_resource.name}"
      node[:splunk][:server].add_monitor(new_resource.log, new_resource.source_type)
    end
  else
    Chef::Log.warn "No such file #{new_resource.name}"
  end
end

action :remove do
  if node[:splunk][:server].has_monitor?(new_resource.name)
    Chef::Log.info "Removing monitor for log #{new_resource.log}"
    node[:splunk][:server].remove_monitor(new_resource.log)
  end
end
