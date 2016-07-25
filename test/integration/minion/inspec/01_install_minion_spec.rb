
describe file('/tmp/kitchen/test/bootstrap.sh') do
  it { should exist }
end

describe command('/tmp/kitchen/test/bootstrap.sh minion') do
  its('exit_status') { should eq 0 }
end

# consequent run should pass as well
describe command('/tmp/kitchen/test/bootstrap.sh minion') do
  its('exit_status') { should eq 0 }
end
