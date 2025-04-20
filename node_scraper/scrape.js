const puppeteer = require('puppeteer');
const fs = require('fs');
const { execSync } = require('child_process');

// Find Chromium executable dynamically
let chromiumPath;
try {
  chromiumPath = execSync('which chromium || which chromium-browser || which google-chrome').toString().trim();
} catch (error) {
  console.error('Chromium executable not found.');
  process.exit(1);
}

const SCRAPE_URL = process.env.SCRAPE_URL || 'https://example.com';

(async () => {
  try {
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      executablePath: chromiumPath
    });

    const page = await browser.newPage();
    await page.goto(SCRAPE_URL, { waitUntil: 'networkidle2' });

    const data = await page.evaluate(() => ({
      title: document.title,
      heading: document.querySelector('h1')?.innerText || 'No <h1> found'
    }));

    fs.writeFileSync('/app/scraped_data.json', JSON.stringify(data, null, 2));
    console.log('✅ Scraping completed successfully!');

    await browser.close();
  } catch (error) {
    console.error('❌ Scraping failed:', error);
    process.exit(1);
  }
})();
