import { access } from 'node:fs/promises';
import { homedir } from 'node:os';
import { pathToFileURL } from 'node:url';

let playwright;
try {
  playwright = await import('playwright');
} catch {
  const bundledPlaywrightPath = `${homedir()}/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs`;
  try {
    await access(bundledPlaywrightPath);
    playwright = await import(pathToFileURL(bundledPlaywrightPath).href);
  } catch {
    throw new Error('Install playwright in this project, or run inside the Codex desktop runtime with bundled dependencies.');
  }
}

const { chromium } = playwright;

const googleChromePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const resourcesUrl = process.env.RESOURCE_BASE_URL ?? new URL('../Resources/', import.meta.url).href;

const jobs = [
  {
    url: new URL('ttgsnackbar-poster.html', resourcesUrl).href,
    selector: '.poster',
    path: 'Resources/ttgsnackbar-poster.jpg',
    viewport: { width: 1800, height: 1200 },
    scale: 2,
    type: 'jpeg',
    quality: 94
  },
  ...[
    ['quick-start-simple.html', 'Resources/snackbar_1.png'],
    ['quick-start-action.html', 'Resources/snackbar_2.png'],
    ['quick-start-loading.html', 'Resources/snackbar_3.png'],
    ['quick-start-semantic.html', 'Resources/snackbar_4.png'],
    ['quick-start-icon.html', 'Resources/snackbar_5.png'],
    ['quick-start-custom.html', 'Resources/snackbar_6.png']
  ].map(([html, path]) => ({
    url: new URL(html, resourcesUrl).href,
    selector: '.demo',
    path,
    viewport: { width: 1440, height: 900 },
    scale: 2,
    type: 'png'
  }))
];

const executablePath = process.env.CHROME_PATH ?? googleChromePath;
const launchOptions = { headless: true };
try {
  await access(executablePath);
  launchOptions.executablePath = executablePath;
} catch {
  // Fall back to Playwright's configured browser when system Chrome is unavailable.
}

const browser = await chromium.launch(launchOptions);

try {
  for (const job of jobs) {
    const page = await browser.newPage({
      viewport: job.viewport,
      deviceScaleFactor: job.scale
    });
    await page.goto(job.url, { waitUntil: 'load' });
    await page.evaluate(async () => {
      await Promise.all(
        Array.from(document.images)
          .filter((image) => !image.complete || image.naturalWidth === 0)
          .map((image) => image.decode().catch(() => undefined))
      );
      await document.fonts?.ready;
    });
    await page.locator(job.selector).screenshot({
      path: job.path,
      type: job.type,
      quality: job.type === 'jpeg' ? job.quality : undefined
    });
    await page.close();
    console.log(`${job.path}`);
  }
} finally {
  await browser.close();
}
