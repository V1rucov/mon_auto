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
echo "[OK] Шаблон найден: ID=$TEMPLATE_ID"

SECLOG_ITEM=$(curl -s -X POST -H 'Content-Type: application/json' \
-d '{
  "jsonrpc": "2.0",
  "method": "item.create",
  "params": {
    "name": "Security log cleared (last 1 min)",
    "key_": "windows.securitylog.cleared",
    "hostid": "'$TEMPLATE_ID'",
    "type": 0,
    "value_type": 3,
    "interfaceid": "0",
    "delay": "1m"
  },
  "auth": "'$AUTH_TOKEN'",
  "id": 3
}' $ZBX_URL)

SECLOG_ITEM_ID=$(echo "$SECLOG_ITEM" | jq -r '.result.itemids[0]')

if [[ -z "$SECLOG_ITEM_ID" || "$SECLOG_ITEM_ID" == "null" ]]; then
  echo "[ERROR] Item не был создан:"
  echo "$SECLOG_ITEM"
  exit 1
fi
echo "[OK] Item добавлен: ID=$SECLOG_ITEM_ID"

SECLOG_TRIGGER=$(curl -s -X POST -H 'Content-Type: application/json' \
-d '{
  "jsonrpc": "2.0",
  "method": "trigger.create",
  "params": {
    "description": "Security log was CLEARED on {HOST.NAME}",
    "expression": "{'$TEMPLATE_HOST':windows.securitylog.cleared.last()}=1",
    "priority": 5
  },
  "auth": "'$AUTH_TOKEN'",
  "id": 4
}' $ZBX_URL)

SECLOG_TRIGGER_ID=$(echo "$SECLOG_TRIGGER" | jq -r '.result.triggerids[0]')

if [[ -z "$SECLOG_TRIGGER_ID" || "$SECLOG_TRIGGER_ID" == "null" ]]; then
  echo "[ERROR] Триггер не был создан:"
  echo "$SECLOG_TRIGGER"
  exit 1
fi
echo "[SUCCESS] Trigger добавлен: ID=$SECLOG_TRIGGER_ID"
