
control '01' do
  impact 0.5
  title 'Verify bootstrap minion passes'
  desc 'Check the bootstrap script and execute to bootstrap salt-master node'

  describe file('/tmp/kitchen/bootstrap.sh') do
    it { should exist }
  end

  describe command('bash -c "source /tmp/kitchen/env/salt.env; SALT_MASTER=10.200.50.11 MINION_ID=kvm01.company.local /tmp/kitchen/bootstrap.sh minion"') do
    its('exit_status') { should eq 0 }
  end

  describe file('/etc/salt/minion.d/minion.conf') do
    its('content') { should match('master: 10.200.50.11') }
    its('content') { should match('id: kvm01.company.local') }
  end

end


control 'Check consequent run' do
  impact 0.5

  # consequent run should pass as well
  describe command('bash -c "source /tmp/kitchen/env/salt.env; SALT_MASTER=10.200.50.12 MINION_ID=kvm02.company.local /tmp/kitchen/bootstrap.sh minion"') do
    its('exit_status') { should eq 0 }
  end

  describe file('/etc/salt/minion.d/minion.conf') do
    its('content') { should match('master: 10.200.50.12') }
    its('content') { should match('id: kvm01.company.local') }
  end

end
