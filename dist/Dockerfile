FROM node:18-alpine

# Install the serve package globally
RUN npm install -g serve

WORKDIR /app

# Copy everything in /dist to the image
COPY . .

# Serve the current folder on port 3000
EXPOSE 3000
CMD ["serve", "-s", ".", "-l", "3000"]

