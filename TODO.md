

# fix your kitchen-salt first

  saltmaster-bootstrap-test git:(master) ✗ cat -n /home/pmichalec/.chefdk/gem/ruby/2.1.0/gems/kitchen-salt-0.0.21/lib/kitchen/provisioner/salt_solo.rb |egrep 200
  200	        if config[:salt_version] > RETCODE_VERSION || config[:salt_version] == 'latest'

# tasks

- first `kitchen converge` mast correctly pass
- merge minion/master bootstrap script in one
- update script usage - option to be sourced. alternative to direct execution
- use external *.env setting file, in bootstrap script keep only variables used (RECLASS_ADDRESS etc, not components for
  later composition). OpenStack related ENV should not be part of the script but sth like tcpcloud-openstack.env override.
- option parser, at least to deceide whether minion/master is being deployed.
- check it works multiplatform
- it should have an optoin to use http://bootstrap.saltstack.com to install salt
