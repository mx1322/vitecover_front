FROM node:20-slim AS base

# Install dependencies only when needed
FROM base AS deps
# For Debian/Ubuntu based images, libc6-compat is usually not needed or handled differently.
# RUN apk add --no-cache libc6-compat # Remove or comment out this line

# --- REQUIRED: Install libvips and its dependencies for Next.js Image Optimization ---
# These are crucial for the 'sharp' library used by Next.js image optimizer.
# Using apt-get for Debian/Ubuntu based images.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvips-dev \
    build-essential \
    git \
    libjpeg-dev \
    libcairo2-dev \
    libgif-dev \
    libtiff-dev \
    libopenjp2-7-dev \
    libpoppler-glib-dev \
    libwebp-dev \
    libxml2-dev \
    libfftw3-dev \
    liblcms2-dev \
    liborc-0.4-dev \
    libglib2.0-dev \
    libpango1.0-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgdk-pixbuf2.0-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libgraphite2-dev \
    zlib1g-dev \
    libpng-dev \
    libexif-dev \
    librsvg2-dev \
    libheif-dev \
    libjxl-dev \
    libavif-dev \
    libvips-tools \
    && rm -rf /var/lib/apt/lists/*

# --- END REQUIRED ---

WORKDIR /app

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm i --frozen-lockfile --prefer-offline

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1

ENV NEXT_OUTPUT=standalone
# Ensure these ARGs and ENVs are correctly passed from docker-compose.yml
# Remove default value for SALEOR_API_URL ARG, so it MUST be passed from build-args
ARG SALEOR_API_URL
ENV SALEOR_API_URL=${SALEOR_API_URL}
ARG NEXT_PUBLIC_SALEOR_API_URL
ENV NEXT_PUBLIC_SALEOR_API_URL=${NEXT_PUBLIC_SALEOR_API_URL}
ARG NEXT_PUBLIC_STOREFRONT_URL
ENV NEXT_PUBLIC_STOREFRONT_URL=${NEXT_PUBLIC_STOREFRONT_URL}

# Set environment variable for GraphQL code generation to use local schema
ENV GITHUB_ACTION=generate-schema-from-file

# Disable Next.js telemetry and static generation during build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Get PNPM version from package.json
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN pnpm build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

# --- Install libvips runtime dependencies in the final runner image ---
# These are the minimal set of packages required for 'sharp' to run correctly.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvips42 \
    libjpeg62-turbo \
    libpng16-16 \
    libwebp7 \
    libtiff6 \
    libglib2.0-0 \
    libxml2 \
    liblcms2-2 \
    libimagequant0 \
    libheif1 \
    libjxl0.7 \
    libavif15 \
    libopenjp2-7 \
    liborc-0.4-0 \
    libgif7 \
    libvips-tools \
    && rm -rf /var/lib/apt/lists/*
# --- END NEW ---

# --- NEW: Verify vips installation in the runner image ---
RUN vips --version
# --- END NEW ---

# Ensure these ARGs and ENVs are correctly passed from docker-compose.yml
# This ENV will be set at runtime by docker-compose environment section

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs


CMD ["node", "server.js"]
