

control '06' do
  title "Init salt master env"

  describe command('bash -c "salt-call state.sls salt.master.env"') do
    its('exit_status') { should eq 0 }
  end

  describe command('bash -c "salt-call state.sls salt.master.pillar"') do
    its('exit_status') { should eq 0 }
  end

end
