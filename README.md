freeipa_server_backup
=====================

This role is taking care of the backups for your FreeIPA servers.

Requirements
------------

This role requires
[Ansible 2.6.0](https://docs.ansible.com/ansible/devel/roadmap/ROADMAP_2_6.html)
or higher.

You can simply use pip to install (and define) a stable version:

```sh
pip install ansible==2.6.4
```

All platform requirements are listed in the metadata file.

In order to use this role take a look at the [dependencies](#dependencies).

Also take a look at the
[official documentation](https://www.freeipa.org/page/Backup_and_Restore).

Install
-------

```sh
ansible-galaxy install timorunge.freeipa_server_backup
```

Role Variables
--------------

The variables that can be passed to this role and a brief description about
them are as follows. (For all variables, take a look at [defaults/main.yml](defaults/main.yml))

At this given point in time it's - unfortunately - not possible to set the
backup directory. This is a limitation from the `ipa-backup` command itself (the
default location is `/var/lib/ipa/backup`).

```yaml
# Defines the maximum age of backups (in days)
# Type: Int
freeipa_server_backup_max_age: 14

# Define the time when a full backup should run
# (this will stop and start the ipa services!)
# Type: Dict
freeipa_server_backup_cron_full:
  minute: "{{ 59 | random(seed=inventory_hostname) }}"
  month: "*"
  weekday: "*"
  hour: 4
  day: "*"
  state: present

# Define the time when a online backup should run
# Type: Dict
freeipa_server_backup_cron_online:
  minute: "{{ 59 | random(seed=inventory_hostname) }}"
  month: "*"
  weekday: "*"
  hour: "*"
  day: "*"
  state: present
```

Examples
--------

## 1) Install the FreeIPA server backup with default settings

```yaml
- hosts: freeipa-server-backup
  roles:
    - timorunge.freeipa_server_backup
```

## 2) Install the FreeIPA server backup with some custom settings:

```yaml
- hosts: freeipa-server-backup
  vars:
    freeipa_server_backup_max_age: 7
    freeipa_server_backup_cron_full:
      day: "*"
      hour: 3
      minute: "11"
      month: "*"
      state: present
      weekday: "*"
    freeipa_server_backup_cron_online:
      day: "*"
      hour: "*"
      minute: 33
      month: "*"
      state: present
      weekday: "*"
    freeipa_server_backup_cron_delete:
      day: "*"
      hour: 3
      minute: 55
      month: "*"
      state: present
      weekday: "*"
  roles:
    - timorunge.freeipa_server_backup
```

## 3) Install the FreeIPA server backup and move the data to another location (via rsync)

```yaml
- hosts: freeipa-server-backup
  vars:
    freeipa_server_backup_mv_location: rsync
    freeipa_server_backup_rsync_opts:
      - "-avq"
      - "--ignore-existing"
      - '-e "ssh -i /home/ipa-backups/.ssh/id_rsa"'
    freeipa_server_backup_rsync_dest: ipa-backups@172.20.1.20:/var/backups/ipa-backup
  roles:
    - timorunge.freeipa_server_backup
```

Testing
-------

[![Build Status](https://travis-ci.org/timorunge/ansible-freeipa-server-backup.svg?branch=master)](https://travis-ci.org/timorunge/ansible-freeipa-server-backup)

Tests are done with [Docker](https://www.docker.com) and
[docker_test_runner](https://github.com/timorunge/docker-test-runner) which
brings up the following containers:

* CentOS 7
* Ubuntu 16.04 (Xenial Xerus)
* Ubuntu 17.10 (Artful Aardvark)
* Ubuntu 18.04 (Bionic Beaver)
* Ubuntu 18.10 (Cosmic Cuttlefish)

Ansible 2.6.4 is installed on all containers and is applying a
[test playbook](tests/test.yml) locally.

For further details and additional checks take a look at the
[docker_test_runner configuration](tests/docker_test_runner.yml) and the
[Docker entrypoint](tests/docker/docker-entrypoint.sh).

```sh
# Testing locally:
curl https://raw.githubusercontent.com/timorunge/docker-test-runner/master/install.sh | sh
./docker_test_runner.py -f tests/docker_test_runner.yml
```

Dependencies
------------

This role requires an up and running
[FreeIPA Server](https://galaxy.ansible.com/timorunge/freeipa_server/)
([Github Repo](https://github.com/timorunge/ansible-freeipa-server)).

If you're using an operating system which is not providing FreeIPA packages
directly out of repositories you can use the Ansible role mentioned above.

In this case ensure that you have `freeipa_server_backup_install_pkgs` set
to `False` (which will disable the complete package installation of this role).

Todo
----

* Add possibility to encrypt backups (`--gpg` and `--gpg-keyring=GPG_KEYRING`)
* Moving the files to an off-site location (s3, ~~rsync & ssh~~)

License
-------
BSD

Author Information
------------------

- Timo Runge
