"""Playwright check against the local dev server."""
from playwright.sync_api import sync_playwright, expect

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    page = browser.new_page(locale="en-US", viewport={"width": 1440, "height": 1000})
    page.goto("http://127.0.0.1:4321/", wait_until="networkidle")
    expect(page.locator(".ambient")).to_have_count(1)
    expect(page.locator(".ambient")).to_have_attribute("aria-hidden", "true")
    assert page.locator(".ambient").evaluate("e => getComputedStyle(e).pointerEvents") == "none"
    assert page.locator(".ambient").evaluate("e => e.getAnimations({subtree:true}).filter(a=>a.playState==='running').length") >= 2
    page.locator("#motion-toggle").click()
    expect(page.locator("#motion-toggle")).to_have_attribute("aria-pressed", "true")
    assert page.locator(".ambient").evaluate("e => e.getAnimations({subtree:true}).every(a=>a.playState==='paused')")
    page.locator("#motion-toggle").click()
    expect(page.locator("#motion-toggle")).to_have_attribute("aria-pressed", "false")
    page.screenshot(path="/tmp/screen-switcher-background.png", full_page=True)
    page.emulate_media(reduced_motion="reduce")
    assert page.locator(".ambient").evaluate("e => e.getAnimations({subtree:true}).length") == 0
    page.set_viewport_size({"width": 390, "height": 844})
    assert page.evaluate("document.documentElement.scrollWidth <= innerWidth")
    browser.close()
    print("PASS: decorative motion, pause/resume, reduced motion and mobile bounds")
