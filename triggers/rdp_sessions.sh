#!/bin/bash
ZBX_URL="http://127.0.0.1/zabbix/api_jsonrpc.php"
ZBX_USER="Admin"
ZBX_PASS="zabbix"
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

if [[ -z "$AUTH_TOKEN" || "$AUTH_TOKEN" == "null" ]]; then
  echo "[ERROR] Авторизация не удалась"
  exit 1
fi
echo "[OK] Авторизация Zabbix API"

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

if [[ -z "$TEMPLATE_ID" || "$TEMPLATE_ID" == "null" ]]; then
  echo "[ERROR] Шаблон не найден"
  exit 1
fi
echo "[OK] Шаблон найден: ID=$TEMPLATE_ID"

ITEM_RESP=$(curl -s -X POST -H 'Content-Type: application/json' \
-d '{
  "jsonrpc": "2.0",
  "method": "item.create",
  "params": {
    "name": "Interactive logon or RDP detected (last 1 min)",
    "key_": "windows.interactive.logon.detected",
    "hostid": "'$TEMPLATE_ID'",
    "type": 0,
    "value_type": 4,
    "interfaceid": "0",
    "delay": "1m"
  },
  "auth": "'$AUTH_TOKEN'",
  "id": 3
}' $ZBX_URL)

ITEM_ID=$(echo "$ITEM_RESP" | jq -r '.result.itemids[0]')

if [[ -z "$ITEM_ID" || "$ITEM_ID" == "null" ]]; then
  echo "[ERROR] Item не создан:"
  echo "$ITEM_RESP"
  exit
