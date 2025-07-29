FROM nginx:alpine
COPY . /usr/share/nginx/html

RUN rm -f /etc/nginx/conf.d/default.conf \
    && rm -f /usr/share/nginx/html/index.html

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
