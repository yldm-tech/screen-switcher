"""Run with Playwright and the development server listening on port 4321."""
from playwright.sync_api import sync_playwright, expect

URL = "http://127.0.0.1:4321/"
with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    context = browser.new_context(locale="zh-CN", viewport={"width": 1440, "height": 1000})
    page = context.new_page()
    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))
    page.goto(URL, wait_until="networkidle")
    expect(page.locator("html")).to_have_attribute("lang", "zh-Hans")
    expect(page.locator("#language")).to_have_value("system")
    page.get_by_role("switch").click()
    for language in ["en", "zh-Hans", "ja", "ko", "es", "fr", "de"]:
        table = page.request.get(URL + "locales/" + language + ".json").json()
        page.locator("#language").select_option(language)
        expect(page.locator("html")).to_have_attribute("lang", language)
        expect(page.get_by_role("switch")).to_have_attribute("aria-checked", "true")
        expect(page.locator("#mode-description")).to_have_text(table["demo.on"])
        for element in page.locator("[data-i18n]").all():
            key = element.get_attribute("data-i18n")
            expected = table["demo.on"] if key == "demo.off" else table[key]
            assert element.text_content() == expected, (language, key, element.text_content())
        assert page.title() == table["page.title"]
        expect(page.locator('meta[name="description"]')).to_have_attribute("content", table["page.description"])
        page.locator("#copy").click()
        expect(page.locator("#copy-status")).to_have_text(table["copy.success"])
        for width in [320, 390, 768, 1440]:
            page.set_viewport_size({"width": width, "height": 1000})
            assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth"), (language, width, page.evaluate("[...document.querySelectorAll('body *')].filter(e=>e.getBoundingClientRect().right>innerWidth).map(e=>e.tagName+'.'+e.className).slice(0,10)"))
        page.reload(wait_until="networkidle")
        expect(page.locator("html")).to_have_attribute("lang", language)
        expect(page.locator("#language")).to_have_value(language)
        page.get_by_role("switch").click()
    page.locator("#language").select_option("system")
    expect(page.locator("html")).to_have_attribute("lang", "zh-Hans")
    assert page.evaluate("localStorage.getItem('screen-switcher.website.language')") is None
    page.screenshot(path="/tmp/screen-switcher-web-zh.png", full_page=True)
    page.set_viewport_size({"width": 390, "height": 844})
    page.screenshot(path="/tmp/screen-switcher-web-zh-mobile.png", full_page=True)
    context.close()

    # A failed translation fetch must preserve the last successfully rendered page.
    context = browser.new_context(locale="en-US")
    page = context.new_page()
    page.goto(URL, wait_until="networkidle")
    page.route("**/locales/de.json", lambda route: route.abort())
    page.locator("#language").select_option("de")
    expect(page.locator("#language")).to_have_value("system")
    expect(page.locator("html")).to_have_attribute("lang", "en")
    expect(page.locator('[data-i18n="hero.first"]')).to_have_text("Two screens.")
    context.close()

    # Language changes must still work when the browser disallows persistence.
    context = browser.new_context(locale="en-US")
    context.add_init_script("Object.defineProperty(window, 'localStorage', {get() { throw new Error('blocked'); }});")
    page = context.new_page()
    page.goto(URL, wait_until="networkidle")
    page.locator("#language").select_option("ja")
    expect(page.locator("html")).to_have_attribute("lang", "ja")
    context.close()
    assert not errors, errors
    browser.close()
    print("PASS: seven languages, browser default, metadata, dynamic states, persistence, mobile layout and failure fallback")
