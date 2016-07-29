

only_if do
  not file('/.dockerenv').exist?
end

# TODO: do not run those tests on docker yet
return if ENV['DOCKER']
return unless os.linux?

control 'salt-minion service' do
  impact 0.5
  title 'Verify minion service'
  #describe service('salt-minion') do
    #it { should be_enabled }
    #it { should be_installed }
    #it { should be_running }
  #end
end

