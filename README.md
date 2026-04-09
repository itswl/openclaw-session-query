# OpenClaw Session HTTP API

一个用于查询和管理 OpenClaw Agent 会话的轻量级 HTTP API 服务。该服务通过 RESTful API 提供对 OpenClaw 会话数据的访问，包括会话列表、消息查询和最终结果获取。

## 功能特性

- 🔍 列出所有 OpenClaw 会话
- 📋 根据 Run ID 或 Session pattern 查询单个会话
- 💬 获取会话的详细消息内容
- ✅ 获取会话的最终结果（最后一条助手消息）
- 🔒 支持 Bearer Token 认证
- 🐳 提供 Docker 和 Docker Compose 部署方式
- 🏥 内置健康检查端点

## API 端点

| 端点 | 方法 | 描述 |
|------|------|------|
| `/` | GET | API 信息和使用说明 |
| `/health` | GET | 健康检查 |
| `/sessions` 或 `/api/sessions` | GET | 列出所有会话 |
| `/sessions/<pattern>` 或 `/api/sessions/<pattern>` | GET | 查询单个会话信息 |
| `/sessions/<pattern>/messages?limit=50` 或 `/api/sessions/<pattern>/messages?limit=50` | GET | 获取会话消息 |
| `/sessions/<pattern>/final` 或 `/api/sessions/<pattern>/final` | GET | 获取会话最终结果 |

## 快速开始

### 本地运行

```bash
# 直接运行（需要 Python 3.6+）
python3 openclaw_query_api.py [--port 8080] [--host 0.0.0.0] [--token YOUR_TOKEN]

# 带认证的运行
python3 openclaw_query_api.py --port 8080 --token mysecrettoken
```

### Docker 运行

```bash
# 构建镜像
docker build -t openclaw-api .

# 运行容器
docker run -d \
  --name openclaw-api \
  -p 8080:8080 \
  -v ~/.openclaw/agents/default/sessions:/root/.openclaw/agents/default/sessions \
  -e TOKEN=your_token_here \
  openclaw-api
```

### Docker Compose 运行

```bash
# 使用默认配置运行
docker-compose up -d

# 或者设置环境变量后运行
OPENCLAW_TOKEN=your_token_here docker-compose up -d
```

## 使用示例

### 1. 列出所有会话

```bash
curl http://localhost:8080/sessions
```

### 2. 查询特定会话

```bash
# 通过 Run ID 查询
curl http://localhost:8080/sessions/5ab8e024-2740-422c-8503-89c01313f792

# 通过 Session pattern 查询
curl http://localhost:8080/sessions/hook:alert:prometheus:b5123b01-616a-4da0-ac48-d9c81e3be63c
```

### 3. 获取会话消息

```bash
# 获取前 50 条消息
curl http://localhost:8080/sessions/hook:alert:prometheus:b5123b01/messages

# 自定义消息数量
curl http://localhost:8080/sessions/hook:alert:prometheus:b5123b01/messages?limit=20
```

### 4. 获取会话最终结果

```bash
curl http://localhost:8080/sessions/hook:alert:prometheus:b5123b01/final
```

### 5. 带认证的请求

```bash
curl -H 'Authorization: Bearer your_token_here' http://localhost:8080/sessions
```

### 6. 健康检查

```bash
curl http://localhost:8080/health
```

## 响应格式

### 会话列表示例

```json
{
  "sessions": [
    {
      "key": "agent:default:hook:alert:prometheus:b5123b01-616a-4da0-ac48-d9c81e3be63c",
      "shortKey": "hook:alert:prometheus:b5123b01-616a-4da0-ac48-d9c81e3be63c",
      "sessionId": "b5123b01-616a-4da0-ac48-d9c81e3be63c",
      "status": "done",
      "updatedAt": "2024-01-15 10:30:45",
      "hasFile": true,
      "model": "gpt-4",
      "runtimeMs": 1234,
      "totalTokens": 5678
    }
  ],
  "total": 1
}
```

### 消息列表示例

```json
{
  "messages": [
    {
      "id": "msg_123",
      "role": "assistant",
      "timestamp": "2024-01-15T10:30:45Z",
      "content": [
        {
          "type": "text",
          "content": "Hello! How can I help you today?"
        }
      ]
    }
  ],
  "total": 1
}
```

### 最终结果示例

```json
{
  "status": "done",
  "isFinal": true,
  "isProcessing": false,
  "messageCount": 5,
  "id": "msg_123",
  "timestamp": "2024-01-15T10:30:45Z",
  "stopReason": "stop",
  "text": "Task completed successfully.",
  "thinking": "",
  "toolCalls": [],
  "usage": {
    "inputTokens": 100,
    "outputTokens": 50,
    "totalTokens": 150
  }
}
```

## 配置选项

### 命令行参数

| 参数 | 默认值 | 描述 |
|------|--------|------|
| `--host` | `0.0.0.0` | 绑定主机地址 |
| `--port` | `8080` | 监听端口 |
| `--token` | `None` | Bearer 认证令牌 |

### 环境变量（Docker）

| 环境变量 | 描述 |
|----------|------|
| `TOKEN` | 用于 API 认证的 Bearer Token |
| `OPENCLAW_TOKEN` | docker-compose.yml 中使用的 token 变量 |

## 数据源

该 API 从以下位置读取 OpenClaw 会话数据：

- `~/.openclaw/agents/default/sessions/sessions.json` - 会话索引文件
- `~/.openclaw/agents/default/sessions/*.jsonl` - 会话消息文件

确保这些文件存在且可访问，API 才能正常工作。

## 安全注意事项

- 建议在生产环境中始终启用 Bearer Token 认证
- 避免在公共网络暴露无认证的 API 服务
- 使用 HTTPS 反向代理（如 Nginx）加密传输
- 定期更新和轮换认证令牌

## 故障排除

### 常见问题

1. **会话文件未找到**
   - 确保 OpenClaw 已运行并生成了会话数据
   - 检查 `~/.openclaw/agents/default/sessions/` 目录权限

2. **认证失败 (401 Unauthorized)**
   - 确认请求中包含了正确的 Bearer Token
   - 检查启动时设置的 token 是否与请求中的一致

3. **端口冲突**
   - 修改 `--port` 参数使用其他端口
   - 检查是否有其他服务占用了 8080 端口

### 日志查看

```bash
# Docker 容器日志
docker logs openclaw-api

# Docker Compose 日志
docker-compose logs -f
```

## 开发

### 项目结构

```
.
├── openclaw_query_api.py    # 主应用程序
├── Dockerfile               # Docker 镜像构建文件
├── docker-compose.yml       # Docker Compose 配置
└── README.md               # 项目文档
```

### 本地开发

```bash
# 克隆项目
git clone <repository-url>
cd openclaw-api

# 安装依赖（如有）
pip install -r requirements.txt

# 运行服务
python3 openclaw_query_api.py --port 8080
```

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进本项目。

## 支持

如有问题或建议，请通过以下方式联系：

- 提交 GitHub Issue
- 查看现有文档和示例
- 参考代码注释

---

**注意**: 本服务是一个只读 API，不会对 OpenClaw 的会话数据进行任何修改。