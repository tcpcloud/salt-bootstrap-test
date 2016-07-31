

control '05' do
  title "System setup"

  describe file('/etc/apt/sources.list') do
    its('content') { should match('apt.tcpcloud.eu') }
  end
end
