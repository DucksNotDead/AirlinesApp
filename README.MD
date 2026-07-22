# AirlinesApp

iOS-клиент для учёта авиабилетов и работы авиакасс: компании, кассиры, клиенты, продажа билетов и отчёты.

Парный бэкенд: [`airlines_api`](https://github.com/DucksNotDead/airlines_api).

## Возможности

- Авторизация и профиль пользователя
- Реестры: компании, кассы, кассиры, клиенты, пользователи
- Продажа и учёт билетов
- Отчёты (в т.ч. с выгрузкой в PDF): билеты по компаниям и месяцам, клиенты компаний за период, суммы по компаниям

## Стек

- Swift / SwiftUI
- MVVM
- Взаимодействие с REST API

## Запуск

1. Откройте `AirlinesApp.xcodeproj` в Xcode.
2. Укажите хост API в `AirlinesApp/Services/ApiService.swift`:

```swift
enum Hosts: String {
    case local = "localhost" // симулятор
    case home = "192.168.0.101"
}

let HOST: Hosts = .local
```

3. Убедитесь, что [`airlines_api`](https://github.com/DucksNotDead/airlines_api) запущен и доступен.
4. Соберите и запустите приложение на симуляторе или устройстве.
