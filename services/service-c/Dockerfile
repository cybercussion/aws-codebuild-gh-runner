# Use official Node.js image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy the application files
COPY src/package.json src/package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app
COPY src ./src

# Expose API port
EXPOSE 3000

# Start the Express app
CMD ["npm", "start"]