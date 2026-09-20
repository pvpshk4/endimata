# Endimata

Flutter-приложение цифрового гардероба.

Позволяет загружать фото одежды, вести личный гардероб, просматривать каталог и управлять профилем. Использует Clean Architecture, BLoC, Firebase и Flask-бэкенд.

## Стек

| Слой | Технологии |
|------|------------|
| UI | Flutter, Material 3, go_router, flutter_hooks |
| State management | flutter_bloc |
| DI | get_it |
| Local storage | Hive, shared_preferences |
| Backend | Firebase Auth / Firestore / Storage + Flask (JWT) |
| Network | dio, http |
| Media | camera, image_picker, cached_network_image |

## Основные фичи

- Авторизация (Firebase + Google Sign-In)
- Цифровой гардероб (wardrobe)
- Загрузка фото (камера / галерея)
- Профиль пользователя
- Светлая / тёмная тема
- Offline-кэш через Hive

## Структура проекта

lib/
├── common/           # общие компоненты (тема, photo upload, AppData)
├── config/           # роутинг и конфигурация
├── core/             # базовые утилиты
├── features/
│   ├── auth/
│   ├── catalog/
│   ├── home/
│   ├── profile/
│   └── wardrobe/
├── firebase_options.dart
├── injection_container.dart
└── main.dart

## Быстрый старт

### Требования

- Flutter SDK ^3.7.0
- Dart SDK
- Android Studio / VS Code
- Firebase-проект (уже настроен в репозитории)

### Установка

git clone https://github.com/pvpshk4/endimata.git
cd endimata
flutter pub get

### Запуск

flutter run

## Архитектура

Проект следует **Clean Architecture**:

- `presentation` — BLoC, UI
- `domain` — репозитории, use-cases
- `data` — data sources (remote/local), модели

Зависимости инжектятся через **get_it** (`injection_container.dart`).

## Firebase

Конфигурация лежит в `lib/firebase_options.dart` и `android/app/google-services.json`.
