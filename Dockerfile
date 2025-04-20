# Stage 1: Node.js Scraper
FROM node:23-slim AS scraper

# Install Chromium and required libraries
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app

# Copy Node app
COPY node_scraper/package.json .
RUN npm install
COPY node_scraper/scrape.js .

# Default scrape URL if none provided
ARG SCRAPE_URL=https://example.com
ENV SCRAPE_URL=${SCRAPE_URL}

# Run scraping
RUN node scrape.js

# Stage 2: Python Flask Server
FROM python:3.13-slim

WORKDIR /app

# Copy only necessary files from scraper stage
COPY --from=scraper /app/scraped_data.json ./scraped_data.json
COPY python_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY python_server/server.py .

# Expose Flask port
EXPOSE 5000

CMD ["python", "server.py"]
