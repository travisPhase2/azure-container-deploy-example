FROM node:20-slim

WORKDIR /usr/src/app

# Copy package files
COPY package.json ./

# Install dependencies
RUN npm install

# Copy application source
COPY src/ ./src/

# Expose the port your app runs on
EXPOSE 8000

# Command to run the application
CMD ["node", "src/index.js"]
