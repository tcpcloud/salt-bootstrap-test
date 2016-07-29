

# TODO: do not run those tests on docker yet
return if ENV['DOCKER']
return unless os.linux?


control 'salt-master service' do
  impact 0.5
  title 'Verify salt-master service'
  #describe service('salt-master') do
    #it { should be_enabled }
    #it { should be_installed }
    #it { should be_running }
  #end
end

