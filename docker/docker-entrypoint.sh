#!/bin/sh
set -e

printf '[defaults]\nroles_path=/etc/ansible/roles' > ansible.cfg
ansible-lint /etc/ansible/roles/${ENV_ROLE_NAME}/tasks/main.yml
ansible-playbook test.yml -i inventory --syntax-check
ansible-playbook test.yml -i inventory --connection=local --become -vvvv
ansible-playbook test.yml -i inventory --connection=local --become | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
EXPECTED_CRONTAB_ENTRIES=$(crontab -l | grep -e "FreeIPA online backup (data only)" -e "FreeIPA full backup" -e "FreeIPA remove old backups" | wc -l)
test "3 == ${EXPECTED_CRONTAB_ENTRIES}" && (echo 'Crontab test: pass' && exit 0) || (echo 'Crontab test: fail' && exit 1)
