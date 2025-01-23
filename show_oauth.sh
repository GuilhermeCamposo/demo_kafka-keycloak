#!/bin/bash
set -x
SSO_HOST=$(oc get route -l app=keycloak -o jsonpath='{.items[0].spec.host}' -n kafka-keycloak)
SSO_HOST_PORT=$SSO_HOST:443
USERNAME=alice
PASSWORD=alice-password
STOREPASS=storepass

#https://my-kc.apps.shrocp4upi416ovn.lab.upshift.rdu2.redhat.com/realms/master/protocol/openid-connect/token
GRANT_RESPONSE=$(curl -k -X POST "https://$SSO_HOST/realms/master/protocol/openid-connect/token" -H 'Content-Type: application/x-www-form-urlencoded' -d "grant_type=password&username=$USERNAME&password=$PASSWORD&client_id=kafka-cli&scope=offline_access" -s -k)

REFRESH_TOKEN=$(echo $GRANT_RESPONSE | awk -F "refresh_token\":\"" '{printf $2}' | awk -F "\"" '{printf $1}')

cat <<EOF
security.protocol=SASL_SSL
ssl.truststore.location=/tmp/truststore.p12
ssl.truststore.password=$STOREPASS
ssl.truststore.type=PKCS12
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required
  oauth.refresh.token="$REFRESH_TOKEN"
  oauth.client.id="kafka-cli"
  oauth.ssl.truststore.location="/tmp/truststore.p12"
  oauth.ssl.truststore.password="$STOREPASS"
  oauth.ssl.truststore.type="PKCS12"
  oauth.token.endpoint.uri="https://$SSO_HOST/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF