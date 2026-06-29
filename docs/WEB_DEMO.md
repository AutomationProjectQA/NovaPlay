# WEB_DEMO.md — Public playable web build

NovaPlay's web build is a great **pre-launch demo**: a shareable URL for player
feedback, wishlist/buzz building, and quick QA — no app store or signing needed.
It runs the **prod** entrypoint, so there's no debug banner and no dev gallery;
native services (ads, analytics, Firebase) fall back to **web-safe stubs**, so
nothing external is required to host it.

## One-time setup (GitHub Pages — zero extra accounts)

1. Push the repo to GitHub (already there).
2. In the repo: **Settings → Pages → Build and deployment → Source = "GitHub
   Actions"**.
3. The [`deploy-web.yml`](../.github/workflows/deploy-web.yml) workflow runs on
   every push to `main` (or manually from the Actions tab) and publishes to:

   `https://<your-user>.github.io/NovaPlay/`

> The workflow builds with `--base-href "/NovaPlay/"` to match the Pages
> sub-path. If you rename the repo, use a custom domain, or use a user/org page
> (served at the domain root), update `--base-href` accordingly (root = `"/"`).

## Other hosting options

- **Firebase Hosting** — `flutter build web --release -t lib/main_prod.dart`
  then `firebase deploy`. Base href stays `/`. Good if you'll wire Firebase
  anyway (custom domain, faster CDN).
- **itch.io** — zip `build/web` and upload as an HTML5 project. Great for
  gathering player feedback and comments from a gaming audience.
- **Any static host** (Netlify, Cloudflare Pages, S3) — serve `build/web`.

## Build locally to preview

```bash
flutter build web --release -t lib/main_prod.dart
# serve it (any static server), e.g.:
python3 -m http.server --directory build/web 8080
```

## Notes & limitations

- **Stubs on web:** no real ads/analytics/crash reporting; the in-app review and
  store-listing actions no-op. Local progress persists via Hive (IndexedDB).
- **Audio** may require a user gesture before it starts (browser autoplay policy)
  — the first tap unlocks it.
- **Performance:** the web (CanvasKit) renderer is heavier than native; the
  fixed-timestep physics keeps gameplay correct, but very low-end machines may
  see lower FPS than on device. Fine for a demo.
- Treat the demo as **marketing/QA**, not the shipping product — the real economy
  and monetization come alive only with the native services wired.
