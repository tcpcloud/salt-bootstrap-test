# saltmaster-bootstrap-test

Install:

	curl -skL "https://raw.githubusercontent.com/tcpcloud/salt-bootstrap-test/master/bootstrap.sh" > bootstrap.sh
	chmod +x ./bootstrap.sh


Bootstrap master:


```
  #Configure/override env. variables, only if change against default values is required
  
  cat <<-EOF > salt.env 
    export FORMULA_SOURCE=pkg
    export RECLASS_ADDRESS=https://github.com/FIXME
    export SALT_MASTER=172.16.178.10
    export DOMAIN=mosqa.cloud
    export APT_REPOSITORY_TAGS="main extra tcp-salt"
  EOF
```

	source *.env
	SALT_MASTER=172.16.178.10 MINION_ID=cfg01.mosqa.cloud ./bootstrap.sh master

  
Bootstrap minion:


	SALT_MASTER=172.16.178.10 MINION_ID=cfg01.mosqa.cloud ./bootstrap.sh minion
  
  
  
Test:

```
 kitchen verify
```
