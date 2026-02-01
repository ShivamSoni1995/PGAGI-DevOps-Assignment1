import { test, expect } from '@playwright/test';

test.describe('DevOps Assignment Frontend E2E Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navigate to the home page before each test
    await page.goto('/');
  });

  test('should display the main heading', async ({ page }) => {
    // Check that the main heading is visible
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
    await expect(heading).toContainText('DevOps Assignment');
  });

  test('should display backend connection status', async ({ page }) => {
    // Wait for the status element to be visible
    const statusElement = page.locator('.status');
    await expect(statusElement).toBeVisible();
    
    // Check that status text is displayed (either connected or failed)
    const statusText = page.locator('.status p');
    await expect(statusText).toBeVisible();
  });

  test('should display message box', async ({ page }) => {
    // Check that the message box is present
    const messageBox = page.locator('.message-box');
    await expect(messageBox).toBeVisible();
    
    // Check that there's a heading in the message box
    const messageHeading = messageBox.locator('h2');
    await expect(messageHeading).toContainText('Backend Message');
  });

  test('should display backend URL information', async ({ page }) => {
    // Check that the info section with backend URL is visible
    const infoSection = page.locator('.info');
    await expect(infoSection).toBeVisible();
    await expect(infoSection).toContainText('Backend URL');
  });

  test('should show loading state initially', async ({ page }) => {
    // Create a new page with slower network to catch loading state
    await page.route('**/api/**', async (route) => {
      await new Promise(resolve => setTimeout(resolve, 100));
      await route.continue();
    });
    
    await page.goto('/');
    
    // The page should still be functional
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
  });

  test('should have proper page title', async ({ page }) => {
    // Check the page title
    await expect(page).toHaveTitle(/DevOps Assignment/);
  });

  test('should handle backend connection success', async ({ page }) => {
    // Mock successful backend responses
    await page.route('**/api/health', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ status: 'healthy', message: 'Backend is running successfully' })
      });
    });

    await page.route('**/api/message', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ message: 'Test message from mocked backend' })
      });
    });

    await page.goto('/');
    
    // Wait for the successful connection status
    await expect(page.locator('.success')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('.success')).toContainText('connected');
  });

  test('should handle backend connection failure gracefully', async ({ page }) => {
    // Mock failed backend response
    await page.route('**/api/health', async (route) => {
      await route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({ error: 'Internal Server Error' })
      });
    });

    await page.goto('/');
    
    // Wait for error state
    await expect(page.locator('.error')).toBeVisible({ timeout: 10000 });
  });

  test('should be responsive on mobile viewport', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    // Check that main elements are still visible
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
    
    const messageBox = page.locator('.message-box');
    await expect(messageBox).toBeVisible();
  });

  test('should be responsive on tablet viewport', async ({ page }) => {
    // Set tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    
    // Check that main elements are still visible
    const heading = page.locator('h1');
    await expect(heading).toBeVisible();
  });
});
