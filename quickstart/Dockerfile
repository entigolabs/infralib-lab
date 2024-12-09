FROM martivo/lab-presenter:html AS builder
COPY . /app/source
RUN node . --folder source --no-user-prompt && cp *.css /app/source/html/ && cp highlight.pack.js /app/source/html/ && cp img/* /app/source/html && cp -r /app/source/images/* /app/source/html


FROM nginx
COPY --from=builder /app/source/html  /usr/share/nginx/html
