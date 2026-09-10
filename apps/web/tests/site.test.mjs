import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
test('site identifies the domain and honest source build instructions', async () => {
  const html = await readFile(new URL('../src/index.html', import.meta.url), 'utf8');
  assert.match(html, /https:\/\/screenswitcher.yldm.tech\//);
  assert.match(html, /open apps\/macos\/dist\/ScreenSwitcher.app/);
  assert.match(html, /not a notarized binary release/);
  assert.match(html, /role="switch" aria-checked="false"/);
  assert.doesNotMatch(html, /<br\b/i, 'Text must wrap naturally, not use forced line breaks');
  assert.match(html, /class="ambient" aria-hidden="true"/);
  assert.match(html, /id="motion-toggle"/);
  const ids = [...html.matchAll(/id="([^"]+)"/g)].map(match => match[1]);
  assert.equal(ids.length, new Set(ids).size);
  for (const match of html.matchAll(/href="#([^"]+)"/g)) assert.ok(ids.includes(match[1]));
});
