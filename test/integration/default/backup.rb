describe file('/usr/local/rvm/gems/ruby-2.1.9@backup/bin/backup') do
  it { should_not be_directory }
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe gem('backup', '/usr/local/rvm/gems/ruby-2.1.9@backup/wrappers/gem') do
  it { should be_installed }
  its('version') { should eq '3.11.0' }
end

describe file('/mnt/backups/models/daily.rb') do
  its('content') { should match(/^\s*split_into_chunks_of\s*5120\s*$/) }
  its('content') { should match(/^\s*store_with\s*S3\s*$/) }
  its('content') { should match(/^\s*compression\.command\s*=\s*"pigz --fast --stdout"\s*$/) }
end

describe package('pigz') do
  it { should be_installed }
end
