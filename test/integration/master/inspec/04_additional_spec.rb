

describe command('source /tmp/kitchen/test/bootstrap.sh') do
  its('exit_status') { should eq 0 }
  its('stdout') { should eq '' }
end

