FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create media directory for mounting videos
RUN mkdir -p /media && \
    chown -R nginx:nginx /media

# Expose port 8080
EXPOSE 8080

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
