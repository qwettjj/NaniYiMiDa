# NaniYiMiDa

## Backend (Spring Boot)

- Java 17
- Spring Boot 3
- Maven

### 快速开始

1) 安装依赖与构建

```bash
mvn -v
mvn clean package
```

2) 启动应用

```bash
mvn spring-boot:run
```

3) 健康检查

- 接口：`GET /api/health`
- 示例（本地默认 8080）：

```bash
curl http://localhost:8080/api/health
```

4) Actuator

- `GET /actuator/health`
- `GET /actuator/info`

### 目录结构（关键部分）

```
.
├─ pom.xml
└─ src
   └─ main
      ├─ java
      │  └─ com/example/naniyimida
      │     ├─ Application.java
      │     └─ controller
      │        └─ HealthController.java
      └─ resources
         └─ application.yml
```

### 常用命令

- 启动：`mvn spring-boot:run`
- 打包：`mvn clean package`
- 测试：`mvn test`
