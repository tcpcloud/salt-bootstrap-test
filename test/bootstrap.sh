#!/bin/bash -e
#
# ENVIRONMENT
#

SALT_SOURCE=${SALT_SOURCE:-pkg}
SALT_VERSION=${SALT_VERSION:-latest}

if [ "$FORMULA_SOURCE" == "git" ]; then
  SALT_ENV="dev"
elif [ "$FORMULA_SOURCE" == "pkg" ]; then
  SALT_ENV="prd"
fi

RECLASS_ADDRESS=${RECLASS_ADDRESS:-https://github.com/tcpcloud/openstack-salt-model.git}
RECLASS_BRANCH=${RECLASS_BRANCH:-master}
RECLASS_SYSTEM=${RECLASS_SYSTEM:-$OS_SYSTEM}

CONFIG_HOST=${CONFIG_HOSTNAME}.${CONFIG_DOMAIN}

MINION_MASTER=${MINION_MASTER:-$CONFIG_ADDRESS}
MINION_HOSTNAME=${MINION_HOSTNAME:-minion}
MINION_ID=${MINION_HOSTNAME}.${CONFIG_DOMAIN}



install_salt_master_pkg()
{
    echo -e "\nPreparing base OS repository ...\n"
####################### uprava repozitare
    echo -e "$REPOSITORY main " > /etc/apt/sources.list
    wget -O - $REPOSITORY_GPG | apt-key add -

    apt-get clean
    apt-get update

    echo -e "\nInstalling salt master ...\n"

    apt-get install reclass git -y

    if [ "$SALT_VERSION" == "latest" ]; then
      apt-get install -y salt-common salt-master salt-minion
    else
      apt-get install -y --force-yes salt-common=$SALT_VERSION salt-master=$SALT_VERSION salt-minion=$SALT_VERSION
    fi

    configure_salt_master

    install_salt_minion_pkg "master"

    echo -e "\nRestarting services ...\n"
    service salt-master restart
    [ -f /etc/salt/pki/minion/minion_master.pub ] && rm -f /etc/salt/pki/minion/minion_master.pub
    service salt-minion restart
    salt-call pillar.data > /dev/null 2>&1
}

install_salt_master_pip()
{
    echo -e "\nPreparing base OS repository ...\n"

    echo -e "$REPOSITORY main" > /etc/apt/sources.list
    wget -O - $REPOSITORY_GPG | apt-key add -

    apt-get clean
    apt-get update

    echo -e "\nInstalling salt master ...\n"

    if [ -x "`which invoke-rc.d 2>/dev/null`" -a -x "/etc/init.d/salt-minion" ] ; then
      apt-get purge -y salt-minion salt-common && apt-get autoremove -y
    fi

    apt-get install -y python-pip python-dev zlib1g-dev reclass git

    if [ "$SALT_VERSION" == "latest" ]; then
      pip install salt
    else
      pip install salt==$SALT_VERSION
    fi

    wget -O /etc/init.d/salt-master https://anonscm.debian.org/cgit/pkg-salt/salt.git/plain/debian/salt-master.init && chmod 755 /etc/init.d/salt-master
    ln -s /usr/local/bin/salt-master /usr/bin/salt-master

    configure_salt_master

    install_salt_minion_pkg "master"

    echo -e "\nRestarting services ...\n"
    service salt-master restart
    [ -f /etc/salt/pki/minion/minion_master.pub ] && rm -f /etc/salt/pki/minion/minion_master.pub
    service salt-minion restart
    salt-call pillar.data > /dev/null 2>&1
}

configure_salt_master()
{

    [ ! -d /etc/salt/master.d ] && mkdir -p /etc/salt/master.d

    cat << 'EOF' > /etc/salt/master.d/master.conf
file_roots:
  base:
  - /usr/share/salt-formulas/env
pillar_opts: False
open_mode: True
reclass: &reclass
  storage_type: yaml_fs
  inventory_base_uri: /srv/salt/reclass
ext_pillar:
  - reclass: *reclass
master_tops:
  reclass: *reclass
EOF

    echo "Configuring reclass ..."

    [ ! -d /etc/reclass ] && mkdir /etc/reclass
    cat << 'EOF' > /etc/reclass/reclass-config.yml
storage_type: yaml_fs
pretty_print: True
output: yaml
inventory_base_uri: /srv/salt/reclass
EOF
    if [ ! -e /srv/salt/reclass/.git ]; then
      # pocet novejch radku v reclassu
      git clone ${RECLASS_ADDRESS} /srv/salt/reclass -b ${RECLASS_BRANCH}
    else
      git fetch ${RECLASS_ADDRESS} /srv/salt/reclass
    fi

    if [ ! -f "/srv/salt/reclass/nodes/${CONFIG_HOST}.yml" ]; then

    cat <<-EOF > /srv/salt/reclass/nodes/${CONFIG_HOST}.yml
classes:
- service.git.client
- system.linux.system.single
- system.openssh.client.workshop
- system.salt.master.single
- system.salt.master.formula.$FORMULA_SOURCE
- system.reclass.storage.salt
- system.reclass.storage.system.$RECLASS_SYSTEM
parameters:
  _param:
    reclass_data_repository: "$RECLASS_ADDRESS"
    reclass_data_revision: $RECLASS_BRANCH
    salt_formula_branch: $FORMULA_BRANCH
    reclass_config_master: $CONFIG_ADDRESS
    single_address: $CONFIG_ADDRESS
    salt_master_host: $SALT_MASTER_HOST
    salt_master_base_environment: $SALT_ENV
  linux:
    system:
      name: $CONFIG_HOSTNAME
      domain: $CONFIG_DOMAIN
EOF

    if [ "$SALT_VERSION" == "latest" ]; then

    cat << EOF >> /srv/salt/reclass/nodes/${CONFIG_HOST}.yml
  salt:
    master:
      accept_policy: open_mode
      source:
        engine: $SALT_SOURCE
    minion:
      source:
        engine: $SALT_SOURCE
EOF

    else

    cat << EOF >> /srv/salt/reclass/nodes/${CONFIG_HOST}.yml
  salt:
    master:
      accept_policy: open_mode
      source:
        engine: $SALT_SOURCE
        version: $SALT_VERSION
    minion:
      source:
        engine: $SALT_SOURCE
        version: $SALT_VERSION
EOF

    fi

    fi

    service salt-master restart
}

install_salt_minion_pkg()
{
    echo -e "\nInstalling salt minion ...\n"

    if [ "$SALT_VERSION" == "latest" ]; then
      apt-get install -y salt-common salt-minion
    else
      apt-get install -y --force-yes salt-common=$SALT_VERSION salt-minion=$SALT_VERSION
    fi

    [ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
    echo -e "master: $SALT_MASTER_HOST\nid: $CONFIG_HOST" > /etc/salt/minion.d/minion.conf

    service salt-minion restart
}

install_salt_minion_pip()
{
    echo -e "\nInstalling salt minion ...\n"

    [ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
    echo -e "master: $SALT_MASTER_HOST\nid: $CONFIG_HOST" > /etc/salt/minion.d/minion.conf

    wget -O /etc/init.d/salt-minion https://anonscm.debian.org/cgit/pkg-salt/salt.git/plain/debian/salt-minion.init && chmod 755 /etc/init.d/salt-minion
    ln -s /usr/local/bin/salt-minion /usr/bin/salt-minion

    service salt-minion restart
}

install_salt_formula_pkg()
{
    echo "Configuring necessary formulas ..."
    which wget > /dev/null || (apt-get update; apt-get install -y wget)

    echo "${REPOSITORY} tcp-salt" > /etc/apt/sources.list.d/salt-formulas.list
    wget -O - "${REPOSITORY_GPG}" | apt-key add -

    apt-get clean
    apt-get update

    [ ! -d /srv/salt/reclass/classes/service ] && mkdir -p /srv/salt/reclass/classes/service

    declare -a formula_services=("linux" "reclass" "salt" "openssh" "ntp" "git" "nginx" "collectd" "sensu" "heka" "sphinx")

    for formula_service in "${formula_services[@]}"; do
        echo -e "\nConfiguring salt formula ${formula_service} ...\n"
        [ ! -d "${FORMULA_PATH}/env/${formula_service}" ] && \
            apt-get install -y salt-formula-${formula_service}
        [ ! -L "/srv/salt/reclass/classes/service/${formula_service}" ] && \
            ln -s ${FORMULA_PATH}/reclass/service/${formula_service} /srv/salt/reclass/classes/service/${formula_service}
    done

    [ ! -d /srv/salt/env ] && mkdir -p /srv/salt/env
    [ ! -L /srv/salt/env/prd ] && ln -s ${FORMULA_PATH}/env /srv/salt/env/prd
}

install_salt_formula_git()
{
    echo "Configuring necessary formulas ..."

    [ ! -d /srv/salt/reclass/classes/service ] && mkdir -p /srv/salt/reclass/classes/service

    declare -a formula_services=("linux" "reclass" "salt" "openssh" "ntp" "git" "nginx" "collectd" "sensu" "heka" "sphinx")
    for formula_service in "${formula_services[@]}"; do
        echo -e "\nConfiguring salt formula ${formula_service} ...\n"
        [ ! -d "${FORMULA_PATH}/env/_formulas/${formula_service}" ] && \
            git clone https://github.com/tcpcloud/salt-formula-${formula_service}.git ${FORMULA_PATH}/env/_formulas/${formula_service} -b ${FORMULA_BRANCH}
        [ ! -L "/usr/share/salt-formulas/env/${formula_service}" ] && \
            ln -s ${FORMULA_PATH}/env/_formulas/${formula_service}/${formula_service} /usr/share/salt-formulas/env/${formula_service}
        [ ! -L "/srv/salt/reclass/classes/service/${formula_service}" ] && \
            ln -s ${FORMULA_PATH}/env/_formulas/${formula_service}/metadata/service /srv/salt/reclass/classes/service/${formula_service}
    done

    [ ! -d /srv/salt/env ] && mkdir -p /srv/salt/env
    [ ! -L /srv/salt/env/dev ] && ln -s /usr/share/salt-formulas/env /srv/salt/env/dev
}

function install_salt_master() {

	if [ "$SALT_SOURCE" == "pkg" ]; then
	    install_salt_master_pkg
	    install_salt_minion_pkg
	elif [ "$SALT_SOURCE" == "pip" ]; then
	    install_salt_master_pip
	    install_salt_minion_pip
	fi
	if [ "$FORMULA_SOURCE" == "pkg" ]; then
	    install_salt_formula_pkg
	elif [ "$FORMULA_SOURCE" == "git" ]; then
	     install_salt_formula_git
	fi
}

function install_salt_minion() {

	if [ "$SALT_SOURCE" == "pkg" ]; then
	    install_salt_minion_pkg
	elif [ "$SALT_SOURCE" == "pip" ]; then
	    install_salt_minion_pip
	fi
}

# detect if file is being sourced
# bash/korn shell compatible
#[[ "$0" != "$_" ]] && main "$@"
# bash way
[[ "$0" == "$BASH_SOURCE" ]] && {

	# cli
	while [ "$1" != "" ]; do
	    case $1 in
		-mas | master )
			echo "master"
			install_salt_master
			install_salt_minion
			;;
		-min | minion )
			echo "minion"
			install_salt_minion
			;;
	    esac
	    shift
	done

} || {
	# source
	echo "hovno"
}
