#!/bin/sh
set -e
echo "Executing playbook with first set of variables"
ansible-playbook -i localhost, play.yml -e @vars_1.yml

echo "Running rabbit commands on docker to test for rabbit state"
docker exec rabbit-mgmt rabbitmqctl list_queues | egrep -v "^amq\." | wc -l | egrep "^\s*2$"
docker exec rabbit-mgmt rabbitmqctl list_exchanges | egrep "some_exchange\s+direct"
docker exec rabbit-mgmt rabbitmqctl list_queues | egrep "label.deleted\s+"
docker exec rabbit-mgmt rabbitmqctl list_queues |  wc -l | egrep "^\s*2$"
docker exec rabbit-mgmt rabbitmqctl list_bindings | egrep "some_exchange\s+exchange\s+label\.deleted\s+queue\s+\*\.labels\.deleted"
docker exec rabbit-mgmt rabbitmqctl list_bindings | egrep "some_exchange\s+exchange\s+label\.deleted\s+queue\s+us\.\*"
docker exec rabbit-mgmt rabbitmqctl list_bindings
docker exec rabbit-mgmt rabbitmqctl list_bindings |  wc -l | egrep "^\s*3$"

echo "Executing playbook with second set of variables. Remove bindings"
ansible-playbook -i localhost, play.yml -e @vars_2.yml
docker exec rabbit-mgmt rabbitmqctl list_bindings |  wc -l | egrep "^\s*1$"

echo "Executing playbook with second set of variables. Remove exchanges"
ansible-playbook -i localhost, play.yml -e @vars_3.yml
docker exec rabbit-mgmt rabbitmqctl list_queues | egrep -v "^amq\." | wc -l | egrep "^\s*1$"