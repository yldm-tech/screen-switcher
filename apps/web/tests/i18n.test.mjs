import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolveLanguage } from '../src/i18n.js';

test('explicit choice, region matching, browser priorities and English fallback', () => {
  assert.equal(resolveLanguage('fr', ['zh-CN']), 'fr');
  assert.equal(resolveLanguage('system', ['zh-TW']), 'zh-Hans');
  assert.equal(resolveLanguage('system', ['pt-BR', 'de-DE']), 'de');
  assert.equal(resolveLanguage('system', ['ja-JP']), 'ja');
  assert.equal(resolveLanguage('invalid', ['ko-KR']), 'ko');
  assert.equal(resolveLanguage('system', []), 'en');
  assert.equal(resolveLanguage('system', ['unknown']), 'en');
});

const languages = ['en', 'zh-Hans', 'ja', 'ko', 'es', 'fr', 'de'];
test('all seven translation files cover the page and interactive states', async () => {
  const tables = [];
  for (const language of languages) {
    const text = await readFile(new URL('../src/locales/' + language + '.json', import.meta.url), 'utf8').catch(() => null);
    assert.ok(text, 'Missing translation file: ' + language);
    tables.push(JSON.parse(text));
  }
  const keys = Object.keys(tables[0]).sort();
  for (const table of tables) {
    assert.deepEqual(Object.keys(table).sort(), keys);
    assert.ok(Object.values(table).every(value => typeof value === 'string' && value.trim()));
    for (const key of ['page.title', 'language.system', 'demo.on', 'demo.off', 'copy.success', 'copy.error', 'faq.privacy.answer']) {
      assert.ok(table[key], key);
    }
  }
  const html = await readFile(new URL('../src/index.html', import.meta.url), 'utf8');
  for (const match of html.matchAll(/data-i18n(?:-aria|-content)?="([^"]+)"/g)) {
    assert.ok(keys.includes(match[1]), 'Unknown page key: ' + match[1]);
  }
  assert.ok((html.match(/data-i18n=/g) || []).length > 35, 'All page text must be localized');
});
