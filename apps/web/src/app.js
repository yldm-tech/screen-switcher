import { resolveLanguage, readSelection, saveSelection, loadMessages, translatePage } from './i18n.js';

const toggle = document.querySelector('#mirror-toggle');
const select = document.querySelector('#language');
const status = document.querySelector('#copy-status');
let messages = {};
let fallback = {};
let copyState = '';
let generation = 0;
let activeSelection = 'system';
let activeLanguage = 'en';

function updateDemo() {
  const mirrored = toggle.getAttribute('aria-checked') === 'true';
  document.querySelector('#screens').classList.toggle('mirrored', mirrored);
  const key = mirrored ? 'demo.on' : 'demo.off';
  const description = document.querySelector('#mode-description');
  if (messages[key] || fallback[key]) description.textContent = messages[key] ?? fallback[key];
  if (copyState) status.textContent = messages[copyState] ?? fallback[copyState] ?? '';
}

async function changeLanguage(selection, persist = false) {
  const request = ++generation;
  const language = resolveLanguage(selection, navigator.languages);
  try {
    const [english, translated] = await Promise.all([loadMessages('en'), loadMessages(language)]);
    if (request !== generation) return;
    fallback = english;
    messages = translated;
    activeSelection = selection;
    activeLanguage = language;
    translatePage(messages, fallback);
    document.documentElement.lang = language;
    select.value = selection;
    if (persist) saveSelection(selection);
    updateDemo();
  } catch {
    if (request !== generation) return;
    // Keep the last working language and the static English page on first load.
    select.value = activeSelection;
    document.documentElement.lang = activeLanguage;
  }
}

select.value = readSelection();
select.addEventListener('change', () => changeLanguage(select.value, true));
window.addEventListener('languagechange', () => {
  if (select.value === 'system') changeLanguage('system');
});
toggle.addEventListener('click', () => {
  toggle.setAttribute('aria-checked', String(toggle.getAttribute('aria-checked') !== 'true'));
  updateDemo();
});
document.querySelector('#copy').addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(document.querySelector('#commands').textContent);
    copyState = 'copy.success';
  } catch {
    copyState = 'copy.error';
  }
  updateDemo();
});
changeLanguage(select.value);

const motion = document.querySelector('#motion-toggle');
motion.addEventListener('click', () => {
  const paused = motion.getAttribute('aria-pressed') !== 'true';
  motion.setAttribute('aria-pressed', String(paused));
  document.documentElement.dataset.motion = paused ? 'paused' : 'running';
  const key = paused ? 'motion.resume' : 'motion.pause';
  motion.dataset.i18n = key;
  motion.textContent = messages[key] ?? fallback[key] ?? motion.textContent;
});
document.addEventListener('visibilitychange', () => {
  document.documentElement.toggleAttribute('data-background-suspended', document.hidden);
});
