# Install dependencies only when needed
FROM node:lts-alpine AS deps

WORKDIR /usr/app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:lts-alpine AS builder

WORKDIR /usr/app
COPY ./ ./
COPY --from=deps /usr/app/node_modules ./node_modules
RUN yarn build

# Production image, copy all the files and run next
FROM keymetrics/pm2:12-alpine AS runner
WORKDIR /usr/app

ENV NODE_ENV production

# You only need to copy next.config.js if you are NOT using the default configuration
# COPY --from=builder /app/next.config.js ./
# COPY --from=builder /usr/app/public ./public
COPY --from=builder /usr/app/.next ./.next
COPY --from=builder /usr/app/node_modules ./node_modules
COPY --from=builder /usr/app/package.json ./package.json
COPY --from=builder /usr/app/src ./src
COPY --from=builder /usr/app/pm2.json ./pm2.json

EXPOSE 8081

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry.
ENV NEXT_TELEMETRY_DISABLED 1

CMD ["yarn", "pm2"]


