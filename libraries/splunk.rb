#
# Cookbook Name:: splunk
# Library:: helper
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

require 'chef/data_bag'

class Chef
  class Splunk
    attr_reader :users, :forwarders, :monitors, :tcp_listeners, :udp_listeners

    def initialize node
      @user = Chef::DataBagItem.load('apps', 'splunk')['user'] || 'admin'
      @password = Chef::DataBagItem.load('apps', 'splunk')['password'] || 'changeme'
      @splunk = "#{node[:splunk][:root]}/bin/splunk"
      @users = get_users()
      @forwarders = [ 
        get_active_forwarders('list forward-server', 'Active forwards:'),
        get_inactive_forwarders('list forward-server', 'Configured but inactive forwards:')
      ].flatten
      @monitors = [
        get_monitored_directories('list monitor', 'Monitored Directories:'),
        get_monitored_files('list monitor', 'Monitored Files:')
      ].flatten
      @tcp_listeners = get_tcp_listeners('list tcp', 'Splunk is listening for data on ports:')
      @udp_listeners = get_udp_listeners('list udp', 'Splunk is listening for data on ports:')
    end

    def add_user user, password, role, full_name = ''
      password = 'changeme'
      `#{@splunk} add user #{user} -password #{password} -full-name '#{full_name}' -role #{role} -auth #{@user}:#{@password}`
      @users << user
    end
    
    def edit_user user, password, role, full_name = ''
      `#{@splunk} edit user #{user} -password #{password} -full-name '#{full_name}' -role #{role} -auth #{@user}:#{@password}`
    end
    
    def add_monitor log, source_type = ''
      unless source_type.empty?
        source_type = "-sourcetype '#{source_type}'"
      end
      `#{@splunk} add monitor #{log} #{source_type} -auth #{@user}:#{@password}`
      @monitors << log
    end
        
    [:tcp, :udp].each do |object|
      define_method('add_' + object.to_s + '_listener') do |opt|
        `#{@splunk} add #{object} #{opt} -auth #{@user}:#{@password}`
        eval "#{object}_listeners << opt"
      end
      
      define_method('remove_' + object.to_s + '_listener') do |opt|
        `#{@splunk} remove #{object} #{opt} -auth #{@user}:#{@password}`
        eval "#{object}_listeners.delete(opt)"
      end
    end
    
    [:forwarder].each do |object|
      define_method('add_' + object.to_s) do |opt|
        `#{@splunk} add #{object} #{opt} -auth #{@user}:#{@password}`
        eval "#{object}s << opt"
      end
    end
    
    [:user, :monitor, :forwarder].each do |object|
      define_method('remove_' + object.to_s) do |opt|
        `#{@splunk} remove #{object} #{opt} -auth #{@user}:#{@password}`
        eval "#{object}s.delete(opt)"
      end
    end
    
    [:user, :monitor, :forwarder, :tcp_listener, :udp_listener].each do |object|
        define_method("has_#{object}?") do |opt|
        return true if "@#{object}s".include?(opt)
      end
    end

    private
    def from_cli cmd, filter
      result = []
      match = false
      `#{@splunk} #{cmd} -auth #{@user}:#{@password}`.split("\n").each do |line|
        if line =~ /none/i
          match = false
          next
        elsif line.include?(filter)
          match = true
        elsif line =~ /^\t/ && match
          result << line.gsub("\t", '')
        else
          match = false
        end
      end
      result
    end
    
    def get_users
      users = []
      `#{@splunk} list user -auth #{@user}:#{@password} | grep username: | awk '{ print $2 }'`.each do |u|
        users << u.chomp!
      end
      users
    end
    
    [
      :active_forwarders,
      :inactive_forwarders,
      :monitored_directories,
      :monitored_files,
      :tcp_listeners,
      :udp_listeners
    ].each do |obj|
      define_method('get_' + obj.to_s) do |cmd, filter|
        from_cli(cmd, filter)
      end
    end
  end
end
