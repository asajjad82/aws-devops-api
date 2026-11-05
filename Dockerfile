# Node 24 is a current LTS release; "alpine" is a small Linux base (small image, smaller attack surface)
FROM node:24-alpine

WORKDIR /app

# Copy only the dependency files first, so Docker can cache the install step
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Now copy the application code
COPY server.js ./

ENV NODE_ENV=production
EXPOSE 3000

# Don't run as root inside the container
USER node

# Run node directly (not "npm start") so SIGTERM reaches our app
CMD ["node", "server.js"]