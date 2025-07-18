# 🎫 TicketLight

**TicketLight** — мобильное приложение на **Flutter** для получения и использования **льготных проездных билетов**.

Позволяет регистрироваться, выбирать категорию льгот, просматривать QR-код билета, пополнять кошелёк, отслеживать транзакции, обращаться в поддержку и настраивать внешний вид.  
Современный интерфейс с адаптивным дизайном, анимациями и JWT-авторизацией.

## ✨ Возможности

- 🔐 **Аутентификация**: регистрация (ФИО, email, пароль, ИИН, телефон), вход/выход.
- 🎫 **Льготные билеты**: выбор категории, просмотр билета, QR-код для валидации.
- 💸 **Кошелёк**: пополнение (карта, мобильный платёж), история транзакций.
- 📱 **QR-сканирование**: встроенная камера для оплаты и валидации.
- ⚙️ **Настройки**: выбор города, языка (русский / казахский / английский), тёмная тема, уведомления.
- 📰 **Новости**: обновления системы и интерфейса.
- 🛠️ **Поддержка**: форма обращения в техподдержку.
- 🎨 **Интерфейс**: адаптивный UI, нижняя навигация, анимации, анти-скрин QR.

## 📋 Требования

- Flutter 3.1.3+
- Dart SDK >=3.1.3 <4.0.0
- Android Studio или Xcode
- Устройство с камерой
- Доступ к **TicketLight API**

## 🧩 Зависимости

| Пакет                   | Назначение                         |
|------------------------|-----------------------------------|
| `flutter`              | UI фреймворк                      |
| `http`                 | HTTP-запросы                      |
| `flutter_secure_storage` | Хранение токенов                 |
| `qr_flutter`           | Генерация QR-кодов                |
| `barcode_widget`       | Генерация штрихкодов              |
| `intl`                 | Форматирование даты/времени       |
| `camera`               | Работа с камерой (сканер QR)      |

Полный список смотри в [`pubspec.yaml`](./pubspec.yaml)

## 🚀 Установка и запуск

### 1. Клонируй проект
```bash
git clone https://github.com/TemhaN/TicketLight.git
cd TicketLight
````

### 2. Установи зависимости

```bash
flutter pub get
```

### 3. Настрой API

В файле `lib/api_service.dart` укажи реальный URL:

```dart
static const String baseUrl = "https://your-api-host.com/api";
```

### 4. Запусти приложение

#### Android:

```bash
flutter run --flavor android
```

#### iOS:

```bash
flutter run --flavor ios
```

## 🖱️ Использование

### 🔐 Аутентификация

| Экран                     | Функция                |
| ------------------------- | ---------------------- |
| `CategorySelectionScreen` | Выбор категории льгот  |
| `RegistrationScreen`      | Регистрация            |
| `LoginScreen`             | Вход по email и паролю |

### 🎫 Работа с билетами

| Экран          | Функция                                               |
| -------------- | ----------------------------------------------------- |
| `HomeScreen`   | Просмотр карты, новостей, статуса льготы              |
| `QRScreen`     | Генерация QR-кода билета (автообновление, анти-скрин) |
| `CameraScreen` | Сканирование QR-кодов (оплата, валидация)             |

### 💸 Кошелёк и транзакции

| Экран               | Функция                     |
| ------------------- | --------------------------- |
| `ProfileScreen`     | Пополнение баланса          |
| `TransactionScreen` | История транзакций по датам |

### ⚙️ Настройки и поддержка

| Экран            | Функция                               |
| ---------------- | ------------------------------------- |
| `SettingsScreen` | Город, язык, уведомления, тёмная тема |
| `SupportScreen`  | Форма обратной связи                  |
| `AboutScreen`    | Информация о приложении               |

## 📦 Сборка приложения

### Android:

```bash
flutter build apk --release
```

> 📁 Сборка будет в `build/app/outputs/flutter-apk/`

### iOS:

```bash
flutter build ios --release
```

> 📁 Сборка будет в `build/ios/`

## 📸 Скриншоты

<div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">
  <img src="https://github.com/TemhaN/TicketLightApp/blob/main/Screenshots/1.jpg?raw=true" alt="TicketLight" width="30%">
  <img src="https://github.com/TemhaN/TicketLightApp/blob/main/Screenshots/2.jpg?raw=true" alt="TicketLight" width="30%">
  <img src="https://github.com/TemhaN/TicketLightApp/blob/main/Screenshots/3.jpg?raw=true" alt="TicketLight" width="30%">
  <img src="https://github.com/TemhaN/TicketLightApp/blob/main/Screenshots/4.jpg?raw=true" alt="TicketLight" width="30%">
</div>    

## 🧠 Автор

**TemhaN**  
[GitHub профиль](https://github.com/TemhaN)

## 🧾 Лицензия

Проект распространяется под лицензией [MIT License].

## 📬 Обратная связь

Нашли баг или хотите предложить улучшение?
Создайте **issue** или присылайте **pull request** в репозиторий!

## ⚙️ Технологии

* **Flutter** — кроссплатформенная разработка
* **http** — API-запросы
* **flutter\_secure\_storage** — безопасное хранение токенов
* **qr\_flutter** — генерация QR
* **barcode\_widget** — штрихкоды
* **intl** — локализация дат и времени
* **camera** — доступ к камере (сканер)
