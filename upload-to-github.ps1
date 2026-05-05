# Автоматическая загрузка проекта в GitHub
# Репозиторий: https://github.com/AKY589/demo-2026-module1

Write-Host "=========================================="
Write-Host "Загрузка проекта в GitHub"
Write-Host "=========================================="

# Проверка наличия Git
Write-Host "`nПроверка установки Git..."
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "ОШИБКА: Git не установлен!" -ForegroundColor Red
    Write-Host "Скачайте и установите Git: https://git-scm.com/download/win"
    exit 1
}
Write-Host "Git установлен: $($gitInstalled.Version)" -ForegroundColor Green

# Переход в папку проекта
Write-Host "`nПереход в папку проекта..."
Set-Location "D:\module 1 problem solving"
Write-Host "Текущая папка: $(Get-Location)" -ForegroundColor Green

# Проверка настройки Git
Write-Host "`nПроверка настройки Git..."
$gitUser = git config --global user.name
$gitEmail = git config --global user.email

if (-not $gitUser) {
    Write-Host "Настройка Git username..."
    git config --global user.name "AKY589"
}

if (-not $gitEmail) {
    Write-Host "ВНИМАНИЕ: Email не настроен!" -ForegroundColor Yellow
    $email = Read-Host "Введите ваш email для Git"
    git config --global user.email $email
}

Write-Host "Git User: $(git config --global user.name)" -ForegroundColor Green
Write-Host "Git Email: $(git config --global user.email)" -ForegroundColor Green

# Инициализация репозитория
Write-Host "`nИнициализация Git репозитория..."
if (Test-Path ".git") {
    Write-Host "Репозиторий уже инициализирован" -ForegroundColor Yellow
} else {
    git init
    Write-Host "Репозиторий инициализирован" -ForegroundColor Green
}

# Добавление файлов
Write-Host "`nДобавление файлов в Git..."
git add .
Write-Host "Файлы добавлены" -ForegroundColor Green

# Создание коммита
Write-Host "`nСоздание коммита..."
git commit -m "Initial commit: ДЕМО-2026 Модуль 1 автоматизация"
Write-Host "Коммит создан" -ForegroundColor Green

# Переименование ветки
Write-Host "`nПереименование ветки в main..."
git branch -M main
Write-Host "Ветка переименована" -ForegroundColor Green

# Добавление удалённого репозитория
Write-Host "`nДобавление удалённого репозитория..."
$remoteExists = git remote | Select-String "origin"
if ($remoteExists) {
    Write-Host "Удалённый репозиторий уже добавлен" -ForegroundColor Yellow
    git remote set-url origin https://github.com/AKY589/demo-2026-module1.git
} else {
    git remote add origin https://github.com/AKY589/demo-2026-module1.git
}
Write-Host "Удалённый репозиторий: https://github.com/AKY589/demo-2026-module1.git" -ForegroundColor Green

# Загрузка на GitHub
Write-Host "`nЗагрузка файлов на GitHub..."
Write-Host "ВНИМАНИЕ: Если попросит пароль, используйте Personal Access Token!" -ForegroundColor Yellow
Write-Host "Инструкция: https://github.com/settings/tokens" -ForegroundColor Yellow

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=========================================="
    Write-Host "УСПЕШНО! Проект загружен на GitHub" -ForegroundColor Green
    Write-Host "=========================================="
    Write-Host "`nРепозиторий доступен по адресу:"
    Write-Host "https://github.com/AKY589/demo-2026-module1" -ForegroundColor Cyan
    Write-Host "`nДля клонирования на виртуальных машинах используй:"
    Write-Host "git clone https://github.com/AKY589/demo-2026-module1.git" -ForegroundColor Cyan
} else {
    Write-Host "`n=========================================="
    Write-Host "ОШИБКА при загрузке на GitHub!" -ForegroundColor Red
    Write-Host "=========================================="
    Write-Host "`nВозможные причины:"
    Write-Host "1. Репозиторий не создан на GitHub (создай на https://github.com/new)"
    Write-Host "2. Нужна авторизация (используй Personal Access Token вместо пароля)"
    Write-Host "3. Проблемы с интернетом"
}
