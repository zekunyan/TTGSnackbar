# Visual Asset Workflow

This project keeps documentation visuals reproducible from HTML and real Simulator screenshots.

## Simulator Screenshots

- Use the Swift example scheme: `TTGSnackbarExample`.
- Preferred simulator used for current assets: `iPhone 17 Pro`, iOS 26.5.
- Use launch arguments for deterministic scenes:
  - `--quick-start-demo simple`
  - `--quick-start-demo action`
  - `--quick-start-demo loading`
  - `--quick-start-demo semantic`
  - `--quick-start-demo icon`
  - `--quick-start-demo custom`
  - `--poster-demo multi`
- Capture native screenshots with `xcrun simctl io <SIMULATOR_ID> screenshot`.
- MCP preview screenshots are useful for review, but they are optimized JPEGs and should not be used as final README assets.

## HTML Rendering

Run:

```sh
node scripts/render-html-assets.mjs
```

The script loads HTML with `file://` URLs by default, so it does not require a local HTTP server and avoids localhost / IPv6 port issues. It renders:

- `Resources/ttgsnackbar-poster.jpg`
- `Resources/snackbar_1.png` through `Resources/snackbar_6.png`

Expected current output sizes:

- Poster: `3360x2100`
- Quick-start cards: `2400x1440`
- Quick-start simulator source screenshots: `1206x2622`

Optional environment variables:

- `RESOURCE_BASE_URL`: Override the HTML base URL, for example `http://127.0.0.1:8088/`.
- `CHROME_PATH`: Override the Chrome executable path used by Playwright.

The script first uses a project-installed `playwright` package. In Codex Desktop it can also fall back to the bundled runtime under `$HOME/.cache/codex-runtimes/...`.

## Checks

After rendering, verify dimensions:

```sh
sips -g pixelWidth -g pixelHeight Resources/ttgsnackbar-poster.jpg Resources/snackbar_*.png Resources/quick-start-simulator/*.jpg
```

Visually inspect the poster and at least one quick-start card before updating README references or committing generated images.
