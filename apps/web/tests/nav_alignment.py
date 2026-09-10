"""Run with Python Playwright, Chrome and the dev server on port 4321."""
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    page = browser.new_page(locale="en-US", viewport={"width": 1440, "height": 900})
    page.goto("http://127.0.0.1:4321/", wait_until="networkidle")
    for width in [1440, 1024, 768]:
        page.set_viewport_size({"width": width, "height": 900})
        boxes = [element.bounding_box() for element in page.locator("nav > a, #language").all()]
        centers = [box["y"] + box["height"] / 2 for box in boxes]
        assert max(centers) - min(centers) <= 1, (width, centers)
    page.set_viewport_size({"width": 390, "height": 844})
    assert page.evaluate("document.documentElement.scrollWidth <= innerWidth")
    browser.close()
    print("PASS: desktop navigation centers align within 1px; mobile has no overflow")
