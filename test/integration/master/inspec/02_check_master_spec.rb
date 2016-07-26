

# TODO: do not run those tests on docker yet
return if ENV['DOCKER']
return unless os.linux?


control 'salt-master service' do
  impact 0.5
  title 'Verify salt-master service'
  describe service('salt-master') do
    it { should_not be_enabled }
    it { should_not be_installed }
    it { should_not be_running }
  end
end

