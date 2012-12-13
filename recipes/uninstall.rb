node['backup']['models'].each do |backup_model|
  cron "scheduled backup: #{backup_model}" do
    action :delete
  end
end
