# ── Stage 1: Build React App ────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Build with production env vars passed at build time
ARG VITE_APP_API_URL
ARG VITE_APP_ADMIN_URL
ARG VITE_APP_BASE_URL

ENV VITE_APP_API_URL=$VITE_APP_API_URL
ENV VITE_APP_ADMIN_URL=$VITE_APP_ADMIN_URL
ENV VITE_APP_BASE_URL=$VITE_APP_BASE_URL

RUN npm run build

# ── Stage 2: Serve with Nginx ────────────────────────────────
FROM nginx:alpine AS production

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built React files
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5174

CMD ["nginx", "-g", "daemon off;"]
