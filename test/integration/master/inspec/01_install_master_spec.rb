
describe file('/tmp/kitchen/test/bootstrap.sh') do
  it { should exist }
end

describe command('/tmp/kitchen/test/bootstrap.sh master') do
  its('exit_status') { should eq 0 }
end

