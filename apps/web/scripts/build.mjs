import { mkdir, copyFile, cp } from 'node:fs/promises';
const files = ['index.html', 'styles.css', 'app.js', 'i18n.js', 'icon.svg', 'robots.txt', 'sitemap.xml'];
await mkdir(new URL('../dist/', import.meta.url), { recursive: true });
for (const file of files) {
  await copyFile(new URL('../src/' + file, import.meta.url), new URL('../dist/' + file, import.meta.url));
}
console.log('Built static website in apps/web/dist');
await cp(new URL('../src/locales/', import.meta.url), new URL('../dist/locales/', import.meta.url), { recursive: true });
