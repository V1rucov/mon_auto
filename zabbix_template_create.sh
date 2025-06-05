#!/bin/bash
ZBX_URL="http://127.0.0.1/zabbix/api_jsonrpc.php"
ZBX_USER="Admin"
ZBX_PASS="zabbix"
TEMPLATE_NAME="Template Custom"
TEMPLATE_HOST="template.custom"

AUTH_TOKEN=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
      "user": "'$ZBX_USER'",
      "password": "'$ZBX_PASS'"
    },
    "id": 1
  }' $ZBX_URL | jq -r '.result')

if [[ "$AUTH_TOKEN" == "null" || -z "$AUTH_TOKEN" ]]; then
  echo "Ошибка авторизации в Zabbix API"
  exit 1
fi

echo "[OK] Авторизация выполнена, токен: $AUTH_TOKEN"

TEMPLATE_ID=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
      "output": "extend",
      "filter": {
        "host": ["'$TEMPLATE_HOST'"]
      }
    },
    "auth": "'$AUTH_TOKEN'",
    "id": 2
  }' $ZBX_URL | jq -r '.result[0].templateid')

if [[ -n "$TEMPLATE_ID" && "$TEMPLATE_ID" != "null" ]]; then
  echo "[INFO] Шаблон уже существует с ID: $TEMPLATE_ID"
  exit 0
fi

CREATE_RESPONSE=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "method": "template.create",
    "params": {
      "host": "'$TEMPLATE_HOST'",
      "name": "'$TEMPLATE_NAME'"
    },
    "auth": "'$AUTH_TOKEN'",
    "id": 3
  }' $ZBX_URL)

NEW_TEMPLATE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.result.templateids[0]')

if [[ "$NEW_TEMPLATE_ID" == "null" || -z "$NEW_TEMPLATE_ID" ]]; then
  echo "[ERROR] Ошибка создания шаблона:"
  echo "$CREATE_RESPONSE"
  exit 1
fi

echo "[SUCCESS] Шаблон создан с ID: $NEW_TEMPLATE_ID"
