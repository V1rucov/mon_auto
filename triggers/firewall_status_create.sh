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
  echo "[ERROR] Авторизация в Zabbix API не удалась"
  exit 1
fi
echo "[OK] Авторизация выполнена"

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
  echo "[ERROR] Шаблон '$TEMPLATE_HOST' не найден"
  exit 1
fi

# Item: Windows Firewall Status
FW_ITEM=$(curl -s -X POST -H 'Content-Type: application/json' \
-d '{
  "jsonrpc": "2.0",
  "method": "item.create",
  "params": {
    "name": "Windows Firewall Status",
    "key_": "windows.firewall.status",
    "hostid": "'$TEMPLATE_ID'",
    "type": 0,
    "value_type": 3,
    "interfaceid": "0",
    "delay": "1h"
  },
  "auth": "'$AUTH_TOKEN'",
  "id": 5
}' $ZBX_URL)

FW_ITEM_ID=$(echo "$FW_ITEM" | jq -r '.result.itemids[0]')
echo "[OK] Item Firewall добавлен: $FW_ITEM_ID"

# Trigger: Firewall partially disabled
FW_TRIGGER=$(curl -s -X POST -H 'Content-Type: application/json' \
-d '{
  "jsonrpc": "2.0",
  "method": "trigger.create",
  "params": {
    "description": "Windows Firewall is PARTIALLY DISABLED on {HOST.NAME}",
    "expression": "{'$TEMPLATE_HOST':windows.firewall.status.last()}=1",
    "priority": 3
  },
  "auth": "'$AUTH_TOKEN'",
  "id": 6
}' $ZBX_URL)

FW_TRIGGER_ID=$(echo "$FW_TRIGGER" | jq -r '.result.triggerids[0]')
echo "[OK] Триггер Firewall добавлен: $FW_TRIGGER_ID"
