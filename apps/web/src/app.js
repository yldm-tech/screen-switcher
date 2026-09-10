const toggle = document.querySelector('#mirror-toggle');
toggle.addEventListener('click', () => {
  const mirrored = toggle.getAttribute('aria-checked') !== 'true';
  toggle.setAttribute('aria-checked', String(mirrored));
  document.querySelector('#screens').classList.toggle('mirrored', mirrored);
  document.querySelector('#mode-description').textContent = mirrored
    ? 'Same content. Ready to share.' : 'More space. Two independent screens.';
});
document.querySelector('#copy').addEventListener('click', async () => {
  const status = document.querySelector('#copy-status');
  try {
    await navigator.clipboard.writeText(document.querySelector('#commands').textContent);
    status.textContent = 'Commands copied.';
  } catch {
    status.textContent = 'Select the commands above and copy them manually.';
  }
});
