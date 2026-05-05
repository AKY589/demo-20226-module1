# Инструкция по загрузке проекта в GitHub

## Шаг 1: Создай репозиторий на GitHub

1. Перейди на https://github.com/AKY589
2. Нажми **"+"** в правом верхнем углу → **New repository**
3. Заполни:
   - **Repository name**: `demo-2026-module1`
   - **Description**: `Автоматизация ДЕМО-2026 Модуль 1 - Сетевой и системный администратор`
   - **Public** ✅
   - **НЕ ставь галочку** на "Add a README file"
4. Нажми **Create repository**

## Шаг 2: Установи Git (если не установлен)

Скачай и установи Git для Windows:
https://git-scm.com/download/win

## Шаг 3: Настрой Git (первый раз)

Открой PowerShell и выполни:

```powershell
git config --global user.name "AKY589"
git config --global user.email "твой-email@example.com"
```

## Шаг 4: Загрузи проект в GitHub

Открой PowerShell и выполни команды по очереди:

```powershell
# Перейди в папку проекта
cd "D:\module 1 problem solving"

# Инициализируй Git репозиторий
git init

# Добавь все файлы
git add .

# Создай первый коммит
git commit -m "Initial commit: ДЕМО-2026 Модуль 1 автоматизация"

# Переименуй ветку в main
git branch -M main

# Добавь удалённый репозиторий
git remote add origin https://github.com/AKY589/demo-2026-module1.git

# Загрузи файлы на GitHub
git push -u origin main
```

## Шаг 5: Проверка

После выполнения команд:
1. Перейди на https://github.com/AKY589/demo-2026-module1
2. Должны появиться все файлы и папки

## Шаг 6: Использование на виртуальных машинах

На каждой виртуальной машине с РЕД ОС 8:

```bash
# Клонируй репозиторий
git clone https://github.com/AKY589/demo-2026-module1.git

# Перейди в папку нужной машины
cd demo-2026-module1/ISP  # или HQ-RTR, HQ-SRV и т.д.

# Запусти скрипт
sudo bash setup.sh

# Перезагрузи
sudo reboot
```

## Возможные проблемы

### Если Git просит авторизацию при push:
GitHub больше не поддерживает пароли. Нужно использовать Personal Access Token:

1. Перейди на https://github.com/settings/tokens
2. Нажми **Generate new token (classic)**
3. Выбери срок действия и права: `repo` (полный доступ к репозиториям)
4. Скопируй токен
5. При запросе пароля вставь токен вместо пароля

### Если нужно сохранить токен:
```powershell
git config --global credential.helper wincred
```

---

**После выполнения всех команд репозиторий будет доступен по адресу:**
https://github.com/AKY589/demo-2026-module1
