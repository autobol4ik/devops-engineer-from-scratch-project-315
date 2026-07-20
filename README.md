# Доска объявлений

[![CI](https://github.com/autobol4ik/devops-engineer-from-scratch-project-315/actions/workflows/ci.yml/badge.svg)](https://github.com/autobol4ik/devops-engineer-from-scratch-project-315/actions/workflows/ci.yml)

Spring Boot и React-приложение для публикации объявлений, упакованное в Docker-образ.

Приложение: [https://hexlet-3.duckdns.org](https://hexlet-3.duckdns.org)

## Запуск контейнера

```bash
docker run --rm --name hexlet-3-app \
  -p 8080:8080 \
  -p 127.0.0.1:9090:9090 \
  -e SPRING_PROFILES_ACTIVE=dev \
  -v hexlet-3-local-data:/tmp/bulletin-images \
  autobol4ik/devops-engineer-from-scratch-project-315:latest
```

Приложение будет доступно на `http://localhost:8080`.

## Требования для развёртывания

Управляющая машина:

- Make, Ansible, Python 3 и SSH-клиент;
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

## Object Storage

[Инструкция по ручной настройке S3](docs/object-storage.md)
