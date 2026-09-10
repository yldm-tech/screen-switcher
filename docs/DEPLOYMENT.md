# Website deployment

The website is a dependency-free Node.js workspace in `apps/web`.

```sh
npm ci
npm run dev
npm run check:web
npm run build:web
```

Development serves only loopback at http://127.0.0.1:4321.
Production output is `apps/web/dist`, deployable to any static host.
No credentials, analytics, external fonts, or backend services are needed.

## GitHub Pages

The Pages workflow uploads `apps/web/dist` and deploys pushes to main.
Enable Pages with **GitHub Actions** as the build source in repository settings.
Pull requests run checks but do not deploy.

## Custom domain

Target: `screenswitcher.yldm.tech`.
For GitHub Pages, set this DNS record at the DNS provider:

| Type | Name | Target |
| --- | --- | --- |
| CNAME | screenswitcher | yldm-tech.github.io |

Before configuring the Pages custom domain, verify ownership of the domain in the
organization's Pages settings if required. Do not overwrite an existing DNS record
without checking its current use. Once the record resolves, set the repository's
Pages custom domain to `screenswitcher.yldm.tech`, wait for certificate provisioning,
and enable HTTPS enforcement.

Canonical URL, sitemap, and robots.txt target the custom domain. The site remains
accessible at the default Pages URL during DNS setup, but should not be announced as
available on the custom domain until DNS and HTTPS are verified.
