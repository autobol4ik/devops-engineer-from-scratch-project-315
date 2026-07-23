# Инфраструктура доски объявлений

[![Infrastructure CI/CD](https://github.com/autobol4ik/devops-engineer-from-scratch-project-315/actions/workflows/ci.yml/badge.svg)](https://github.com/autobol4ik/devops-engineer-from-scratch-project-315/actions/workflows/ci.yml)

Приложение: [https://hexlet-3.duckdns.org](https://hexlet-3.duckdns.org)

Исходники приложения и `Dockerfile` находятся в ветке
[`project-3`](https://github.com/autobol4ik/project-devops-deploy/tree/project-3)
форка. Этот репозиторий содержит только Ansible-конфигурацию инфраструктуры и
закрепляет полный SHA приложения в `APP_SOURCE_REF` файла `Makefile`.

## Требования для развёртывания

Управляющая машина:

- Make, Ansible Core, Ansible Lint, Python 3 и SSH-клиент;
- SSH-ключ для доступа к серверу;
- локальные файлы `inventory.yml` и `.vault-password`.

Целевой сервер:

- Ubuntu 24.04 LTS или совместимая Debian-система с Python 3;
- SSH-пользователь с правами `sudo`;
- не менее 2 ГБ RAM и 20 ГБ диска;
- статический публичный IP-адрес;
- входящие TCP-порты 22, 80 и 443;
- домен с A-записью на публичный IP сервера;
- исходящий доступ к Docker Hub и S3-совместимому хранилищу.

## Развёртывание

```bash
make prepare
make check
make provision
make deploy
make tls
```

`make deploy` всегда использует закреплённый `APP_SOURCE_REF`. По умолчанию
`make rollback` использует прежний репозиторий образов, поэтому исходный
production-образ остаётся доступен для отката:

```bash
make rollback ROLLBACK_TAG=d607eb03bbf174c4224fea98850cb79ca1e39f73
```

Секреты редактируются командой `make vault-edit` и хранятся только в
зашифрованном `group_vars/all/vault.yml`.

## Ручная настройка Object Storage

1. Создайте приватный бакет `hexlet-3-autobol4ik` в Yandex Object Storage и
   запретите публичное чтение объектов и их списка.
2. Создайте отдельный сервисный аккаунт приложения и разрешите ему только
   `s3:GetObject` и `s3:PutObject` для объектов этого бакета.
3. Создайте статический ключ доступа сервисного аккаунта.
4. Выполните `make vault-edit` и заполните `vault_s3_bucket`,
   `vault_s3_region`, `vault_s3_endpoint`, `vault_s3_access_key` и
   `vault_s3_secret_key`. Для Yandex Object Storage используются регион
   `ru-central1` и endpoint `https://storage.yandexcloud.net`.
5. Выполните деплой, загрузите изображение через приложение и проверьте, что
   объект появился в бакете, скачивается по выданной ссылке и совпадает с
   исходным файлом.
