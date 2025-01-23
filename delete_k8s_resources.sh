#!/bin/bash

rm -rf /tmp/certificates/
oc -n kafka-keycloak delete kafka,kafkanodepool,keycloak --all
oc -n kafka-keycloak delete secret/keycloak-db-secret secret/keycloak-tls secret/keycloak-server-admin secret/oauth-server-cert statefulset/postgresql-db deployment/openldap service/openldap deployment/my-bridge-bridge

oc delete -f apps/producer/target/kubernetes/openshift.yml
oc delete -f apps/processor/target/kubernetes/openshift.yml

oc -n kafka-keycloak delete csv/rhbk-operator.v26.0.8-opr.1 csv/amqstreams.v2.8.0-0
oc delete ns/kafka-keycloak
