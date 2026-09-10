import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
const types = { 'index.html': 'text/html', 'styles.css': 'text/css', 'app.js': 'text/javascript', 'icon.svg': 'image/svg+xml', 'robots.txt': 'text/plain', 'sitemap.xml': 'application/xml' };
types['i18n.js'] = 'text/javascript';
for (const language of ['en', 'zh-Hans', 'ja', 'ko', 'es', 'fr', 'de']) types['locales/' + language + '.json'] = 'application/json';
createServer(async (req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  const file = path === '/' ? 'index.html' : path.slice(1);
  if (!Object.hasOwn(types, file)) { res.writeHead(404); res.end('Not found'); return; }
  res.setHeader('Content-Type', types[file] + '; charset=utf-8');
  res.end(await readFile(new URL('../src/' + file, import.meta.url)));
}).listen(4321, '127.0.0.1', () => console.log('Website: http://127.0.0.1:4321'));
