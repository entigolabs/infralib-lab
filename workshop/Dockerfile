FROM martivo/lab-presenter:html AS builder
COPY . /app/source
RUN node . --folder source && cp *.css /app/source/html/ && cp *.js /app/source/html/ && cp img/* /app/source/html


# Same base as quickstart/Dockerfile; only the html is extracted from this
# image by prepare_html.sh, it is never run as a server.
FROM nginx/nginx-unprivileged:1.31.8-alpine-slim
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/source/html  /usr/share/nginx/html
EXPOSE 8081
