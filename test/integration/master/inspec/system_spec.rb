

describe file('/etc/apt/sources.list') do
  its('content') { should match('apt.tcpcloud.eu') }
end
