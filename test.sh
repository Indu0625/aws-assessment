#!/bin/bash

USERNAME="avulaindu096@gmail.com"
PASSWORD="Indu@1234"
CLIENT_ID="29sm2j6i1gk8ne2s5tl39lu4jn"

US_API="https://gpr80v4dm0.execute-api.us-east-1.amazonaws.com"
EU_API="https://ixqlnhllm0.execute-api.eu-west-1.amazonaws.com"

echo "Getting Cognito Token..."

TOKEN=$(aws cognito-idp initiate-auth \
--region us-east-1 \
--auth-flow USER_PASSWORD_AUTH \
--client-id $CLIENT_ID \
--auth-parameters USERNAME=$USERNAME,PASSWORD=$PASSWORD \
--query 'AuthenticationResult.IdToken' \
--output text)

echo "Token received"
echo ""

echo "===== US EAST REGION ====="

echo "Testing /greet"

curl -s -H "Authorization: Bearer $TOKEN" \
$US_API/greet

echo ""

echo "Testing /dispatch"

curl -s -X POST \
-H "Authorization: Bearer $TOKEN" \
$US_API/dispatch

echo ""
echo ""

echo "===== EU WEST REGION ====="

echo "Testing /greet"

curl -s -H "Authorization: Bearer $TOKEN" \
$EU_API/greet

echo ""

echo "Testing /dispatch"

curl -s -X POST \
-H "Authorization: Bearer $TOKEN" \
$EU_API/dispatch

echo ""
echo "Test completed"