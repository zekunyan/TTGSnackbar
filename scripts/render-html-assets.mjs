let playwright;
try {
  playwright = await import('playwright');
} catch {
  playwright = await import('/Users/tutuge/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright/index.mjs');
}

const { chromium } = playwright;

const chromePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const resourcesUrl = process.env.RESOURCE_BASE_URL ?? 'http://127.0.0.1:8088/';

const jobs = [
  {
    url: `${resourcesUrl}ttgsnackbar-poster.html`,
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
    url: `${resourcesUrl}${html}`,
    selector: '.demo',
    path,
    viewport: { width: 1440, height: 900 },
    scale: 2,
    type: 'png'
  }))
];

const browser = await chromium.launch({
  headless: true,
  executablePath: chromePath
});

try {
  for (const job of jobs) {
    const page = await browser.newPage({
      viewport: job.viewport,
      deviceScaleFactor: job.scale
    });
    await page.goto(job.url, { waitUntil: 'load' });
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
