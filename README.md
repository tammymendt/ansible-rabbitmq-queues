Role Name
=========

This is a simple role created to perform exchange and queue management on RabbitMQ. It uses
the ansible rabbitmq modules, which in turn make requests to the RabbitMQ API. We separate
this role from a general purpose RabbitMQ automation role, because we wish for exchange and
queue management to take place on a service level.

Requirements
------------

The RabbitMQ API must be accessible from the machine running the automation code.
New versions of RabbitMQ will require using Ansible version 2.3, since the RabbitMQ API interface
has suffered changes over time.

Role Variables
--------------

* rabbitmq_login_credentials: a dictionary containing the login credentials to RabbitMQ.
The keys expected in this dictionary are the following. If no login credentials are provided,
the default credentials for RabbitMQ will be used.
    - host     # default localhost
    - port     # default 15672
    - user     # default guest
    - password # default None

* rabbitmq_exchanges_definitions: a list containing exchange configurations.
By default it is an empty list. The `exchange_name` key is required and indicates the name of the exchange. All other
configuration variables match the key of the [rabbitmq_exchange ansible module](http://docs.ansible.com/ansible/latest/rabbitmq_exchange_module.html).
Defaults values and whether configurations are required or not also match the rabbitmq_exchange module.

Example:
```
rabbitmq_exchanges_definitions
  - exchange_name   : "some_exchange"
    vhost           : "/"
    state           : absent
```

* rabbitmq_queues_definitions: a list containing queue configurations.
By default it is an empty list. The `queue_name` key is required and indicates the name of the queue. All other
configuration variables match the key of the [rabbitmq_queue ansible module](http://docs.ansible.com/ansible/latest/rabbitmq_queue_module.html).
Defaults values and whether configurations are required or not also match the rabbitmq_queue module.
Inside of the queue configuration, we include all bindings to that queue.
If an exchange is set for the queue configuration, this will be the exchange for
all bindings to that queue. Otherwise, exchanges can be set individually as sources per binding
inside of the bindings configuration.

Example:
```
  - queue_name    : "label.deleted"
    exchange      : "shipping-label"
    vhost         : "/"
    state         : present
    bindings:
      - routing_key   : "*.labels.deleted"
        state         : present
      - routing_key   : "us.*"

  - queue_name    : "label.generated"
    state         : present
    bindings:
      - routing_key   : "*.labels.generated"
        exchange      : "some-exchange-1"
        state         : absent
      - routing_key   : "*.*.generated"
        exchange      : "some-exchange-1"
        state         : present
```

Dependencies
------------


Example Playbook
----------------
```
    - hosts: servers
      roles:
         - { role: ansible-rabbitmq-queues }
```

License
-------

MIT

Author Information
------------------

Tamara Mendt
