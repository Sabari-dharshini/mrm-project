# ── Stage 1: Build ──────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

ARG VITE_MEMBER_BASE_URL
ARG VITE_MEMBER_IMAGE_BASE_URL
ARG VITE_MEMBER_APP_TITLE

ENV VITE_MEMBER_BASE_URL=$VITE_MEMBER_BASE_URL
ENV VITE_MEMBER_IMAGE_BASE_URL=$VITE_MEMBER_IMAGE_BASE_URL
ENV VITE_MEMBER_APP_TITLE=$VITE_MEMBER_APP_TITLE

RUN npm run build

# ── Stage 2: Serve with Nginx ────────────────────────────────
FROM nginx:alpine AS production

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 5175

CMD ["nginx", "-g", "daemon off;"]
