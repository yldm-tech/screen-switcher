# Security

This is an early-stage macOS utility. There are no signed stable releases or
guaranteed security support windows yet; fixes target the default branch.

Do not publish exploitable vulnerabilities, secrets, or private logs in public issues.
Use GitHub's **Security → Report a vulnerability** when available. Otherwise ask
a maintainer for a private contact channel without disclosing exploit details.

The app uses local CoreGraphics, AppKit, and ServiceManagement APIs. It does not
implement analytics, screen capture, or application network requests. Notification
authorization is optional. Login-at-startup registration is changed only on request.

Development builds are ad-hoc signed, not Developer ID signed or notarized.
Build from reviewed source. Never disable Gatekeeper globally to run this app.
