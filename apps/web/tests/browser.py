"""Optional UI check: run with a local server on port 4321 and Python Playwright."""
from playwright.sync_api import sync_playwright, expect

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    page = browser.new_page(viewport={"width": 1440, "height": 1050})
    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))
    page.goto("http://127.0.0.1:4321/", wait_until="networkidle")
    toggle = page.get_by_role("switch")
    expect(toggle).to_have_attribute("aria-checked", "false")
    toggle.click()
    expect(toggle).to_have_attribute("aria-checked", "true")
    expect(page.locator("#screens")).to_have_class("screens mirrored")
    toggle.focus()
    page.keyboard.press("Space")
    expect(toggle).to_have_attribute("aria-checked", "false")
    page.get_by_role("button", name="Copy commands").click()
    expect(page.locator("#copy-status")).not_to_be_empty()
    page.screenshot(path="/tmp/screen-switcher-web-desktop.png", full_page=True)
    page.set_viewport_size({"width": 390, "height": 844})
    assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth")
    page.get_by_text("Can I download a ready-made app?").click()
    expect(page.get_by_text("Not yet.", exact=False)).to_be_visible()
    page.screenshot(path="/tmp/screen-switcher-web-mobile.png", full_page=True)
    assert not errors, errors
    browser.close()
    print("Desktop, mobile, switch, keyboard, copy feedback and FAQ: PASS")
