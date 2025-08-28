FROM nginx:alpine

# Copy prebuilt React app into Nginx html directory
COPY build/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
