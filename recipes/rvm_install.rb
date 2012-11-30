#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2012, Morgan Nelson
# Copyright 2012, AJ Christensen
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

base_dir = node['backup']['base_dir']

models_dir = File.join(base_dir, "models")
keys_dir = File.join(base_dir, "keys")
log_dir = File.join(base_dir, "log")

directory base_dir
directory models_dir
directory keys_dir
directory log_dir

rvm_environment node['backup']['rvm_ruby_string']

rvm_gem "backup" do
  package_name "backup"
  ruby_string node['backup']['rvm_ruby_string']
  version node['backup']['version']
end

node['backup']['gems'].each_pair do |gem_name, gem_version|
  rvm_gem gem_name do
    package_name gem_name
    version gem_version
    ruby_string node['backup']['rvm_ruby_string']
  end
end

template File.join(base_dir, "config.rb") do
  variables( :databases => node['backup']['databases'],
             # AWS
             :aws_access_key_id => node['backup']['aws']['access_key_id'],
             :aws_secret_access_key => node['backup']['aws']['secret_access_key'],
             # S3
             :s3_bucket => node['backup']['aws']['s3']['bucket'],
             :s3_path => node['backup']['aws']['s3']['path'],
             :s3_keep => node['backup']['aws']['s3']['keep'],
             # GPG
             :gpg_public_key => node['backup']['gpg']['public_key'],
             # MySQL
             :mysql_database => node['backup']['mysql']['database'],
             :mysql_username => node['backup']['mysql']['username'],
             :mysql_password => node['backup']['mysql']['password'],
             :mysql_host => node['backup']['mysql']['host'],
             :mysql_port => node['backup']['mysql']['port'],
             # MongoDB
             :mongodb_database => node['backup']['mongodb']['database'],
             :mongodb_username => node['backup']['mongodb']['username'],
             :mongodb_password => node['backup']['mongodb']['password'],
             :mongodb_host => node['backup']['mongodb']['host'],
             :mongodb_port => node['backup']['mongodb']['port'],
             :mongodb_lock => node['backup']['mongodb']['lock'],
             :mongodb_ipv6 => node['backup']['mongodb']['ipv6'],
             # Redis
             :redis_database => node['backup']['redis']['database'],
             :redis_path => node['backup']['redis']['path'],
             :redis_password => node['backup']['redis']['password'],
             :redis_host => node['backup']['redis']['host'],
             :redis_port => node['backup']['redis']['port'],
             :redis_invoke_save => node['backup']['redis']['invoke_save'],
             :redis_cli_utility => node['backup']['redis']['redis_cli_utility'],
             # Campfire
             :campfire_api_token  => node['backup']['campfire']['api_token'],
             :campfire_subdomain  => node['backup']['campfire']['subdomain'],
             :campfire_room_id    => node['backup']['campfire']['room_id'],
             :campfire_on_failure => node['backup']['campfire']['on_failure'],
             :campfire_on_warning => node['backup']['campfire']['on_warning'],
             :campfire_on_success => node['backup']['campfire']['on_success'],
             )
end

file File.join(keys_dir, "backups.public.gpg") do
  content node['backup']['gpg']['public_key']
end

rvm_wrapper "backup" do
  binary "backup"
  prefix node['backup']['rvm_wrapper_prefix']
  ruby_string node['backup']['rvm_ruby_string']
end

node['backup']['models'].each do |backup_model|

  template File.join(models_dir, "#{backup_model}.rb") do
    variables( :backup_model => backup_model.to_sym,
               :databases => node['backup']['databases'],
               :archives  => node['backup']['archives'],
               :split_into_chunks_of => node['backup']['split_into_chunks_of']
               )
  end

  rvm_command = node['backup']['rvm_wrapper_prefix'] ? "#{node['backup']['rvm_wrapper_prefix']}_backup" : "backup"

  # TODO: determine schedule from model
  cron "scheduled backup: #{backup_model}" do
    hour "1"
    minute "1"
    command "#{node['backup']['cron']['prefix']}/usr/local/rvm/bin/#{rvm_command} perform -t #{backup_model} -r #{base_dir}"
  end

end
