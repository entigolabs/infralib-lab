FROM martivo/lab-presenter:html AS builder
COPY . /app/source
RUN node . source && cp *.css /app/source/html/ && cp *.js /app/source/html/ && cp img/* /app/source/html


FROM nginx
COPY --from=builder /app/source/html  /usr/share/nginx/html
