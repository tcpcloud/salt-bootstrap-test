
control '01' do
  impact 0.9
  title 'Verify bootstrap master passes'
  desc 'Check the bootstrap script and execute to bootstrap salt-master node'

  describe file('/tmp/kitchen/test/bootstrap.sh') do
    it { should exist }
  end

  describe command('/tmp/kitchen/test/bootstrap.sh master') do
    its('exit_status') { should eq 0 }
  end
end

control '02' do
  impact 0.1
  title 'Verify consequent execution of the bootstrap script'
  # consequent run should pass as well
  describe command('/tmp/kitchen/test/bootstrap.sh master') do
    its('exit_status') { should eq 0 }
  end
end

