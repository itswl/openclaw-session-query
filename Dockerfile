FROM python:3.10-slim

WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY openclaw_api.py .

# 创建 .openclaw 目录（用于挂载）
RUN mkdir -p /root/.openclaw/agents/default/sessions

# 暴露端口
EXPOSE 8080

# 启动命令 - 支持环境变量 HOOK_TOKEN
CMD sh -c 'if [ -n "$HOOK_TOKEN" ]; then python openclaw_api.py --host 0.0.0.0 --port 8080 --hook_token "$HOOK_TOKEN"; else python openclaw_api.py --host 0.0.0.0 --port 8080; fi'
