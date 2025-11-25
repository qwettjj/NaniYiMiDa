# NaniYiMiDa AI Coding Agent Guide

A Spring Boot 3 recipe/cooking application backend with JWT authentication and recipe management features.

## Project Structure

```
src/main/java/com/java/NaniYiMiDa/
├── controller/        # REST endpoints (User, Recipe, Favorite, History, Tools)
├── service/           # Business logic interfaces
├── service/impl/      # Service implementations (UserServiceImpl, RecipeServiceImpl, etc.)
├── po/                # JPA entities (User, Recipe, Favorite, Follow, History)
├── repository/        # Spring Data JPA repositories
├── configure/         # Spring configuration & interceptors
├── exception/         # Custom exceptions (BusinessException, GlobalExceptionHandler)
├── enumx/             # Enums (ErrorCode, Role, RecipeStatus, IngredientEnum)
├── tool/              # Utilities (TokenUtil for JWT)
├── vo/                # Value Objects for API responses
└── config/            # Additional configuration
```

## Build & Run

- **Build**: `mvn clean package` (Java 21, Maven)
- **Run**: `mvn spring-boot:run` (starts on port 8080)
- **Test**: `mvn test`
- **Health check**: `GET /api/health` or `GET /actuator/health`

Database: MySQL at `jdbc:mysql://localhost:3306/naniyimida` (configured in `application.properties`)

## Response Pattern

All API responses use `ResultVO<T>` wrapper:
- **Success**: `ResultVO.buildSuccess(data)` → code 000, data field populated
- **Failure**: `ResultVO.buildFailure(ErrorCode.XXX, "message")` → code from enum, no data

Error codes defined in `enumx.ErrorCode`: SUCCESS(000), BAD_REQUEST(400), UNAUTHORIZED(401), FORBIDDEN(403), NOT_FOUND(404), CONFLICT(409), SERVER_ERROR(500)

Global exception handler (`exception.GlobalExceptionHandler`) catches `BusinessException` and converts to ResultVO. All errors return HTTP 200 with business code in response body.

## Authentication & Authorization

- **Token**: JWT created in `UserController.login()` by `TokenUtil.getToken(user)`
- **Verification**: `LoginInterceptor` checks token validity on all endpoints except `/api/users/login`, `/api/users/register`, `/actuator/health`
- **Token format**: Authorization header as `Bearer <token>` OR legacy `token` header
- **Session**: Verified user stored in `request.getSession().setAttribute("currentUser", user)`

## Key Patterns

**Service layer design**: All services are interfaces in `/service` with implementations in `/service/impl`. Use constructor/field autowiring for dependencies.

**Recipe workflow**: Draft → Publish → Hide states. Recipes contain multiple Recipe Steps (ordered by index). Use `RecipeVO` for API contracts.

**Transaction safety**: Service methods like `publishRecipeDraft()`, `deleteRecipe()` modify state—ensure idempotency or add checks.

**Code style**: Lombok `@Data`, `@Autowired` field injection, camelCase naming, package path `com.java.NaniYiMiDa.*`

**Date parameter handling**: All `@RequestParam Date` fields use `@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")`. Frontend should send dates as `yyyy-MM-dd HH:mm:ss` strings (e.g., `2025-11-25 14:30:00`) in query parameters, NOT as timestamps or JSON dates.

## External Dependencies

- **JWT**: `com.auth0:java-jwt:4.4.0` (see `TokenUtil`)
- **OSS Storage**: Aliyun SDK `com.aliyun.oss:aliyun-sdk-oss:3.17.4` (used in `ImageService`)
- **Spring Data JPA**: MySQL Connector 8.0.31

## Testing

Tests located in `src/test/java/com/java/NaniYiMiDa/`. Run via `mvn test`. Test reports in `target/surefire-reports/`.
