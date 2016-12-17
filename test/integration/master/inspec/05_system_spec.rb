

control '05' do
  title "System setup"

  describe file('/etc/apt/sources.list.d/bootstrap.list') do
    #it { should_not exist }
    its('content') { should match('apt.tcpcloud.eu') }
  end

end
