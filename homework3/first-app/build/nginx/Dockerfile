ARG FROM_NGINX_TAG
ARG SERVERNAME_APP

#----------------
FROM nginx:${FROM_NGINX_TAG} AS web
LABEL homework="3"
ARG SERVERNAME_APP
COPY ./build/nginx/default.conf /etc/nginx/conf.d/default.conf
RUN sed -e s/localhost/${SERVERNAME_APP}/g -i /etc/nginx/conf.d/default.conf
EXPOSE 8080
STOPSIGNAL SIGQUIT
CMD ["nginx-debug", "-g", "daemon off;"]
