FROM martivo/lab-presenter:html AS builder
COPY . /app/source
RUN node . --folder source --no-user-prompt && cp *.css /app/source/html/ && cp highlight.pack.js /app/source/html/ && cp img/* /app/source/html && cp -r /app/source/images/* /app/source/html


# Unprivileged nginx runs as uid 101. The port and redirect behaviour are set in
# nginx-default.conf next to this file.
# Exact tag on purpose: Dependabot bumps it, see .github/dependabot.yml.
FROM nginx/nginx-unprivileged:1.31.8-alpine-slim
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/source/html  /usr/share/nginx/html
EXPOSE 8081
