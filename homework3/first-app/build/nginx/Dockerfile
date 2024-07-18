FROM nginx:stable-alpine AS web

#----------------
FROM web
LABEL homework="3"
COPY ./build/nginx/default.conf /etc/nginx/conf.d/default.conf
RUN sed 's/localhost/profsoft/g' -i /etc/nginx/conf.d/default.conf
#RUN sed -i 's/$realpath_root$fastcgi_script_name/\/var\/www\/app\/public/g' build/nginx/default.conf
EXPOSE 8080
STOPSIGNAL SIGQUIT
CMD ["nginx-debug", "-g", "daemon off;"]
