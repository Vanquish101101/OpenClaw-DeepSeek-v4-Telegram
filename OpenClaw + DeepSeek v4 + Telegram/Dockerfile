FROM node:24-alpine

RUN npm install -g openclaw@2026.6.1

RUN mkdir -p /root/.openclaw/secrets \
             /root/.openclaw/memory \
             /root/.openclaw/agents \
             /root/.openclaw/workspace

COPY openclaw-docker.json /root/.openclaw/openclaw.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 18789

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
