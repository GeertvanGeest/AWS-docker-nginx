FROM nginx:1.21.6-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY /config/nginx.http.conf /etc/nginx/conf.d
