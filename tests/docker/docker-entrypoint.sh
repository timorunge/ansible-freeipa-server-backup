#!/bin/sh
set -e

printf "[defaults]\nroles_path=/etc/ansible/roles\n" > ansible.cfg

ansible-lint /ansible/test.yml
ansible-lint /etc/ansible/roles/${ansible_role}/tasks/main.yml

ansible-playbook /ansible/test.yml \
  -i inventory \
  --syntax-check

ansible-playbook /ansible/test.yml \
  -i inventory \
  --connection=local \
  --become \
  $(test -z ${travis} && echo "-vvvv")

ansible-playbook /ansible/test.yml \
  -i inventory \
  --connection=local \
  --become | \
  grep -q "changed=0.*failed=0" && \
  (echo "Idempotence test: pass" && exit 0) || \
  (echo "Idempotence test: fail" && exit 1)

expected_crontab_entries=$(crontab -l | grep -e "FreeIPA online backup (data only)" -e "FreeIPA full backup" -e "FreeIPA remove old backups" | wc -l)
test "3" = "${expected_crontab_entries}" && \
  (echo "Crontab test: pass" && exit 0) || \
  (echo "Crontab test: fail" && exit 1)
