FROM ubuntu
LABEL author="mta1711"
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx 
RUN rm -Rf /var/www/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /var/www/html/
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && sudo nginx -g 'daemon off;'
