# Onboarding
## Instruções
- Faça um fork desse repositório.
- Crie um branch a partir do master para cada desafio.
- Ao finalizar o desafio, crie um PR do branch do desafio para o master no seu repositório.
- Quando o PR é aprovado pelos tutores, faça merge do branch do desafio para o master no seu repositório.
## Instalação
```bash
docker-compose build
```

## Ambientes

- [Rails](rails)
- [Phoenix](phoenix)

## Serviços

### Mongo

Iniciar o mongo
```bash
docker-compose up -d mongo
```
### Redis

Iniciar o redis
```bash
docker-compose up -d redis
```
### ElasticSearch, Logstash e Kibana

Iniciar o ELK
```bash
docker-compose up -d elk
```
### RabbitMQ

Iniciar o RabbitMQ
```bash
docker-compose up -d rabbitmq
```
### Sentry
https://develop.sentry.dev/self-hosted/
