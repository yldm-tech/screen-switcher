"""Run with Python Playwright, Chrome and the local website on port 4321."""
from playwright.sync_api import sync_playwright, expect

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    context = browser.new_context(locale="en-US", permissions=["clipboard-read", "clipboard-write"])
    page = context.new_page()
    page.goto("http://127.0.0.1:4321/", wait_until="networkidle")
    commands = page.locator("#commands")
    colors = page.locator("#commands span").evaluate_all("els => [...new Set(els.map(e => getComputedStyle(e).color))]")
    assert len(colors) == 3
    expected = "git clone https://github.com/yldm-tech/screen-switcher.git\ncd screen-switcher\nsh build-app.sh\nopen apps/macos/dist/ScreenSwitcher.app"
    assert commands.text_content() == expected
    page.locator("#copy").click()
    expect(page.locator("#copy-status")).to_have_text("Commands copied.")
    assert page.evaluate("navigator.clipboard.readText()") == expected
    page.locator(".terminal").screenshot(path="/tmp/screen-switcher-code-highlight.png")
    browser.close()
    print("PASS: three highlight colors and exact plain-text clipboard contents")
