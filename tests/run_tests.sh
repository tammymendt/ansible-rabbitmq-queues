#!/bin/sh
set -e
echo "Executing playbook with first set of variables"
export EXCHANGE_NAME=some_exchange
export QUEUE_NAME=some_queue
ansible-playbook -i localhost, play.yml -e @vars_1.yml

echo "\nTest for rabbit state"
docker exec rabbit-mgmt rabbitmqctl list_exchanges | egrep -v "^amq\." | wc -l | egrep "^\s*3$"
docker exec rabbit-mgmt rabbitmqctl list_exchanges | egrep "$EXCHANGE_NAME\s+direct"
echo "Exchanges created successfully\n"

docker exec rabbit-mgmt rabbitmqctl list_queues | egrep "$QUEUE_NAME\s+"
docker exec rabbit-mgmt rabbitmqctl list_queues |  wc -l | egrep "^\s*2$"
echo "Queues created successfully\n"

docker exec rabbit-mgmt rabbitmqctl list_bindings | egrep "$EXCHANGE_NAME\s+exchange\s+$QUEUE_NAME\s+queue\s+\*\.labels"
docker exec rabbit-mgmt rabbitmqctl list_bindings | egrep "$EXCHANGE_NAME\s+exchange\s+$QUEUE_NAME\s+queue\s+us\.\*"
docker exec rabbit-mgmt rabbitmqctl list_bindings |  wc -l | egrep "^\s*4$"
echo "Bindings created successfully\n"

echo "\nExecuting playbook with second set of variables. Remove bindings"
ansible-playbook -i localhost, play.yml -e @vars_2.yml
docker exec rabbit-mgmt rabbitmqctl list_bindings |  wc -l | egrep "^\s*2$"
echo "\nBindings removed successfully"

echo "\nExecuting playbook with third set of variables. Remove exchanges"
ansible-playbook -i localhost, play.yml -e @vars_3.yml
docker exec rabbit-mgmt rabbitmqctl list_exchanges | egrep -v "^amq\." | wc -l | egrep "^\s*2$"
echo "\nExchanges removed successfully"
