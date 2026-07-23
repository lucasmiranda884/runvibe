# RunVibe API

Backend do RunVibe em Java 21, Spring Boot 3, PostgreSQL/PostGIS e autenticação JWT.

## Pré-requisitos

- Java 21+
- Maven 3.9+
- Docker com Docker Compose (recomendado para o banco)

## Executar localmente

```powershell
docker compose up -d postgres
mvn spring-boot:run
```

A API inicia em `http://localhost:8080`. A documentação interativa fica em
`http://localhost:8080/swagger-ui.html`.

As configurações aceitam as variáveis `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`,
`JWT_SECRET`, `JWT_EXPIRATION` e `SERVER_PORT`. Troque obrigatoriamente o segredo
JWT padrão antes de publicar o serviço.

## Testar e empacotar

```powershell
mvn test
mvn package
```

O Flyway cria a extensão PostGIS, tabelas, constraints e índices ao iniciar a API.
