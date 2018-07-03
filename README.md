freeipa_server_backup
=====================

This role is taking care of the backups for your FreeIPA servers.

Requirements
------------

This role requires Ansible 2.4.0 or higher. It's fully tested with the latest
stable release (2.6.0).

You can simply use pip to install (and define) the latest stable version:

```sh
pip install ansible==2.6.0
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
freeipa_server_backup_max_age: 14

# Define the time when a full backup should run
# (this will stop and start the ipa services!)
freeipa_server_backup_cron_full:
  minute: "{{ 59 | random(seed=inventory_hostname) }}"
  month: *
  weekday: *
  hour: 4
  day: *
  state: present

# Define the time when a online backup should run
freeipa_server_backup_cron_online:
  minute: "{{ 59 | random(seed=inventory_hostname) }}"
  month: *
  weekday: *
  hour: *
  day: *
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

Testing
-------

[![Build Status](https://travis-ci.org/timorunge/ansible-freeipa-server-backup.svg?branch=master)](https://travis-ci.org/timorunge/ansible-freeipa-server-backup)

Testing is done with [Docker Compose](https://docs.docker.com/compose/) which is
bringing up the following containers:

* CentOS 7
* Debian 8.10
* Debian 9.4
* Ubuntu 16.04
* Ubuntu 17.10
* Ubuntu 18.04
* Ubuntu 18.10

Ansible 2.6.0 is installed on all containers and is applying a
[test playbook](tests/test.yml) locally.

For further details and additional checks take a look at the
[Docker entrypoint](docker/docker-entrypoint.sh).

```sh
# Testing locally with docker-compose:
docker-compose config
docker-compose pull
docker-compose build
docker-compose up --no-start
docker-compose up
docker-compose down
```

Dependencies
------------

This role requires an up and running
[FreeIPA Server](https://galaxy.ansible.com/timorunge/freeipa_server/)
([Github Repo](https://github.com/timorunge/ansible-freeipa-server)).

Todo
----

* Add possibility to encrypt backups (`--gpg` and `--gpg-keyring=GPG_KEYRING`)
* Moving the files to an off-site location (s3, rsync & ssh)

License
-------
BSD

Author Information
------------------

- Timo Runge
