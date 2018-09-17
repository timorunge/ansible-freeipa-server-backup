#!/bin/sh
set -e

printf "[defaults]\nroles_path=/etc/ansible/roles\n" > /ansible/ansible.cfg

if [ ! -f /etc/ansible/lint.zip ]; then
  wget https://github.com/ansible/galaxy-lint-rules/archive/master.zip -O \
  /etc/ansible/lint.zip
  unzip /etc/ansible/lint.zip -d /etc/ansible/lint
fi

ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /etc/ansible/roles/${ansible_role}
ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /ansible/test.yml

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
