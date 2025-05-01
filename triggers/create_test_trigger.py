import requests
import json

# Настройки
url = 'http://your-zabbix-server.com/zabbix/api_jsonrpc.php'
headers = {'Content-Type': 'application/json-rpc'}

# Логин
auth_data = {
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "Admin",
        "password": "zabbix"
    },
    "id": 1,
    "auth": None
}
auth_response = requests.post(url, headers=headers, data=json.dumps(auth_data)).json()
auth_token = auth_response['result']

# Создание триггера
trigger_data = {
    "jsonrpc": "2.0",
    "method": "trigger.create",
    "params": {
        "description": "CPU Load too high",
        "expression": "{MyHost:system.cpu.load[percpu,avg1].last()} > 5",
        "priority": 4
    },
    "auth": auth_token,
    "id": 2
}
create_response = requests.post(url, headers=headers, data=json.dumps(trigger_data)).json()

print(json.dumps(create_response, indent=4))
