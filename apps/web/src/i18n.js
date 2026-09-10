export const languages = ['en', 'zh-Hans', 'ja', 'ko', 'es', 'fr', 'de'];
export const storageKey = 'screen-switcher.website.language';

export function resolveLanguage(selection, preferred = []) {
  if (languages.includes(selection)) return selection;
  for (const locale of preferred) {
    const base = locale.toLowerCase().split(/[-_]/)[0];
    if (base === 'zh') return 'zh-Hans';
    if (languages.includes(base)) return base;
  }
  return 'en';
}

// Storage can be unavailable in private or restricted browser contexts.
export function readSelection() {
  try {
    const value = localStorage.getItem(storageKey);
    return languages.includes(value) ? value : 'system';
  } catch { return 'system'; }
}

export function saveSelection(value) {
  try {
    if (value === 'system') localStorage.removeItem(storageKey);
    else localStorage.setItem(storageKey, value);
  } catch { /* Switching still works for the current page. */ }
}

const cache = new Map();
export async function loadMessages(language) {
  if (!languages.includes(language)) throw new Error('Unsupported language');
  if (!cache.has(language)) {
    cache.set(language, fetch(new URL('./locales/' + language + '.json', import.meta.url)).then(response => {
      if (!response.ok) throw new Error('Translation request failed');
      return response.json();
    }).catch(error => { cache.delete(language); throw error; }));
  }
  return cache.get(language);
}

export function translatePage(messages, fallback) {
  for (const [attribute, target] of [['data-i18n', null], ['data-i18n-aria', 'aria-label'], ['data-i18n-content', 'content']]) {
    for (const element of document.querySelectorAll('[' + attribute + ']')) {
      const key = element.getAttribute(attribute);
      const value = messages[key] ?? fallback[key];
      if (typeof value !== 'string') continue;
      if (target) element.setAttribute(target, value);
      else element.textContent = value;
    }
  }
}
