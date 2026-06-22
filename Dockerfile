FROM nginx:alpine

# Copy static files
COPY index.html /usr/share/nginx/html/index.html

# Copy nginx config to listen on $PORT
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
