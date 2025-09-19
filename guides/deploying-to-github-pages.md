# Deploying to GitHub Pages

GitHub Pages can host the static files that Tableau produces. This guide walks through a production-ready setup that you can adopt for your own site.

## Prepare your Tableau project

1. Set the production `url` in `config/prod.exs` (your custom domain or the full GitHub Pages URL):

   ```elixir
   # config/prod.exs
   config :tableau, :config,
     url: "https://your-domain.tld"
   ```

2. If you serve additional assets (Tailwind, esbuild, etc.), add the corresponding Mix tasks to the `build` alias so they also run in CI.

## Add the GitHub Pages workflow

Create `.github/workflows/deploy.yml` with the following workflow. It installs Erlang/OTP + Elixir, builds the site in production mode, and publishes the `_site` directory to GitHub Pages:

```yaml
name: Deploy site to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Set up Erlang/OTP and Elixir
        uses: erlef/setup-beam@v1
        with:
          otp-version: "28"
          elixir-version: "1.18"

      - name: Cache Mix deps
        uses: actions/cache@v4
        with:
          path: |
            ~/.mix
            deps
            _build
          key: ${{ runner.os }}-otp-28-elixir-1.18-mix-${{ hashFiles('**/mix.lock') }}
          restore-keys: |
            ${{ runner.os }}-otp-28-elixir-1.18-mix-

      - name: Install dependencies
        run: MIX_ENV=prod mix deps.get --only prod

      - name: Build site
        run: MIX_ENV=prod mix build

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v4
        with:
          path: _site

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Workflow notes

- Set `otp-version` and `elixir-version` to match your project.
- Update the cache key when you bump OTP or Elixir so a fresh build occurs.
- If `mix build` already chains your asset pipelines, no other changes are needed. Otherwise, insert additional steps before "Upload artifact".
- The cache step speeds up successive runs but can be removed if you prefer.

## Enable GitHub Pages

1. Push the workflow to your default branch (the example uses `main`).
2. In your repository, open **Settings → Pages**.
3. Under **Build and deployment**, choose **GitHub Actions**.
4. After the first successful run, the deployment will appear under the **Deployments** tab and the workflow output prints the public URL.

## Custom domains & pages.io URLs

If you have a custom domain:

- Add a `CNAME` file at the repo root containing the domain, e.g. `example.com`.
- Configure your DNS to point at GitHub Pages.
- Keep `config :tableau, :config, url: "https://your-domain"` in sync so absolute links are generated correctly.
- GitHub’s docs cover the DNS details in depth: <https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages>.

If you deploy to `<user>.github.io/<repo>`, use the full Pages URL (e.g. `https://username.github.io/my-site`) and optionally set `base_path: "/my-site"` in `config/prod.exs` so local links match production.

## Troubleshooting

- See a 404 for nested routes? Double-check `base_path` in `config/prod.exs` when deploying under a subdirectory.
- Need to rebuild assets? Append those build steps to the `build` alias so `mix build` runs everything locally and in CI.
- Want to test locally? Run `MIX_ENV=prod mix build` and inspect the output directory (which defaults to  `_site/`) before pushing.

With these pieces in place, every push to `main` rebuilds your Tableau site and deploys it to GitHub Pages.
