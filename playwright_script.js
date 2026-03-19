const { chromium } = require('playwright');
(async () => {
  try {
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto('http://localhost:8080/');
    await page.waitForTimeout(2000);
    // Use an absolute path that is accessible or relative to the project root
    const path = require('path');
    const screenshotPath = path.join(process.cwd(), 'manager_screenshot.png');
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`Screenshot saved to ${screenshotPath}`);
    await browser.close();
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
})();
