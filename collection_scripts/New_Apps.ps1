# Параметры
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$oldValues = @{}

# Функция для сравнения новых и старых значений
function Compare-RegistryValues {
    param(
        [string]$path
    )

    # Получение новых значений
    $newValues = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        $value = $_.GetValue("DisplayName")
        [PSCustomObject]@{ Name = $name; Value = $value }
    }

    # Сравнение новых и старых значений
    foreach ($newValue in $newValues) {
        if ($oldValues.ContainsKey($newValue.Name)) {
            if ($oldValues[$newValue.Name] -ne $newValue.Value) {
                Write-Output "Изменено: $($newValue.Name) - $($newValue.Value)"
            }
            $oldValues[$newValue.Name] = $newValue.Value
        } else {
            Write-Output "Новое: $($newValue.Name) - $($newValue.Value)"
            $oldValues[$newValue.Name] = $newValue.Value
        }
    }

    # Удаление старых значений, которые больше не существуют
    foreach ($oldKey in $oldValues.Keys) {
        if (-not ($newValues | Where-Object { $_.Name -eq $oldKey })) {
            Write-Output "Удалено: $oldKey - $($oldValues[$oldKey])"
            $oldValues.Remove($oldKey)
        }
    }
}

# Мониторинг значения реестра
while ($true) {
    Compare-RegistryValues -path $registryPath
    Start-Sleep -Seconds 5
}