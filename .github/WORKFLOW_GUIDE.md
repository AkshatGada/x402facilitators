# GitHub Actions Workflows Guide

This repository uses GitHub Actions for automated CI/CD. Here's how everything works.

---

## 📋 Workflows Overview

### 1. **CI Workflow** (`ci.yml`)
Runs on every push and pull request to `main`/`master`.

**What it does:**
- ✅ Type checks with `bun run check:types`
- ✅ Lints code with `bun run lint`
- ✅ Builds library (`bun run build:lib`)
- ✅ Verifies library outputs (index.js, index.d.ts)
- ✅ Builds website (`bun run build:website`)
- ✅ Verifies website output (index.html)
- ✅ Runs package verification (`npm pack --dry-run`)

**Purpose:** Ensures all changes build correctly before merging.

---

### 2. **Release and Publish Workflow** (`release.yml`)
Runs when you create/publish a GitHub release.

**What it does:**

#### Job 1: Build and Publish to npm
1. ✅ Checks out code
2. ✅ Sets up Bun and Node.js
3. ✅ Installs dependencies
4. ✅ Builds library with `bun run build:lib`
5. ✅ Verifies build outputs
6. ✅ Creates and uploads artifacts
7. ✅ Packs npm package
8. ✅ **Publishes to npm** with provenance
9. ✅ Verifies publication

#### Job 2: Deploy Website to GitHub Pages
1. ✅ Checks out code (clean state)
2. ✅ Sets up Bun
3. ✅ Installs dependencies
4. ✅ Builds website with `bun run build:website`
5. ✅ Adds CNAME file for custom domain
6. ✅ **Deploys to GitHub Pages**
7. ✅ Confirms deployment

**Features:**
- 🔐 **Provenance attestation** - npm package includes cryptographic proof of build
- 🌐 **Parallel deployment** - Website deploys after npm publish succeeds
- 🎯 **Manual trigger** - Can run manually with dry-run option
- 📦 **Artifact preservation** - Build artifacts kept for 30-90 days

---

## 🔧 Setup Requirements

### 1. NPM Authentication

**Option A: Trusted Publishing (Recommended)** ✅
No secrets needed! Configure on npmjs.com:
1. Go to your package settings on npmjs.com
2. Set up GitHub Actions as trusted publisher:
   - Repository: `Swader/x402facilitators`
   - Workflow: `release.yml`
3. That's it! OIDC handles authentication automatically.

**Option B: NPM Token (Fallback)**
If you prefer traditional tokens:
1. Generate an Automation token on npmjs.com
2. Add to GitHub Secrets as `NPM_TOKEN`
3. Update workflow to use `NODE_AUTH_TOKEN`

See [NPM_PUBLISHING_GUIDE.md](./NPM_PUBLISHING_GUIDE.md) for detailed setup.

### 2. GitHub Pages
Enable GitHub Pages in repository settings:

1. Go to Settings → Pages
2. Set Source to: **GitHub Actions**
3. The custom domain will be configured automatically from CNAME

### 3. DNS Configuration
Point your custom domain to GitHub Pages:

**For `facilitators.x402.watch`:**
- Add CNAME record in your DNS provider:
  - Host: `facilitators`
  - Target: `<your-username>.github.io`

---

## 🚀 How to Release

### Step 1: Prepare Release
```bash
# Update version in package.json
bun version patch  # or minor, or major

# Build and test locally
bun run build
npm pack --dry-run

# Commit version bump
git add package.json
git commit -m "chore: bump version to X.X.X"
git push
```

### Step 2: Create GitHub Release
```bash
# Create and push tag
git tag vX.X.X
git push origin vX.X.X
```

Then on GitHub:
1. Go to **Releases** → **Draft a new release**
2. Choose your tag
3. Generate release notes or write custom notes
4. Click **Publish release**

### Step 3: Automated Deployment
The workflow will automatically:
1. ⏳ Build library and publish to npm (~2-3 minutes)
2. ⏳ Build and deploy website to GitHub Pages (~2-3 minutes)
3. ✅ Both should complete successfully

### Step 4: Verify
- **NPM:** https://www.npmjs.com/package/facilitators
- **Website:** https://facilitators.x402.watch
- **Actions:** Check workflow run for any issues

---

## 🧪 Testing Releases

You can test the release process without publishing:

```bash
# Manually trigger workflow with dry-run
# Go to Actions → Release and Publish → Run workflow
# Check "dry_run" option
```

This will:
- ✅ Build everything
- ✅ Create artifacts
- ✅ Run `npm publish --dry-run`
- ❌ Skip actual publication
- ❌ Skip GitHub Pages deployment

---

## 📊 Workflow Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI** | Push/PR to main | Quality checks |
| **Release** | GitHub Release | Publish to npm + deploy website |
| **Release** | Manual dispatch | Testing with dry-run option |

---

## 🔐 Security Features

### NPM Provenance
The workflow uses npm's provenance feature:
- 🔒 Cryptographic attestation of build
- 🔍 Transparent build process
- ✅ Verifiable package origin
- 📜 Build log transparency

This requires:
- `id-token: write` permission
- `--provenance` flag
- GitHub Actions OIDC

### Minimal Permissions
Each workflow uses least-privilege permissions:
- **CI:** Read-only
- **Release:** Contents write, ID token write, Pages write

---

## 📦 Artifacts

The release workflow preserves:

1. **Library Build** (30 days)
   - All JS files
   - All TypeScript declarations
   - Source maps
   - package.json, README, LICENSE

2. **NPM Tarball** (90 days)
   - Complete `.tgz` package file
   - Can be downloaded and inspected
   - Useful for debugging

---

## 🐛 Troubleshooting

### NPM Publish Fails
- **Check:** Is `NPM_TOKEN` secret set correctly?
- **Check:** Does the token have Automation permissions?
- **Check:** Is the version number already published?
- **Fix:** Bump version and try again

### GitHub Pages Deploy Fails
- **Check:** Is GitHub Pages enabled in settings?
- **Check:** Is the source set to "GitHub Actions"?
- **Check:** Are workflow permissions correct?
- **Fix:** Check Settings → Actions → General → Workflow permissions

### Build Fails
- **Check:** Does it build locally with `bun run build`?
- **Check:** Are there any linting errors?
- **Check:** Is bun.lock committed?
- **Fix:** Run `bun install` and commit updated lock file

### DNS Not Working
- **Check:** Have you added the CNAME record?
- **Check:** Has DNS propagated? (can take 24-48 hours)
- **Check:** Is CNAME file in dist/ after website build?
- **Fix:** Use `dig facilitators.x402.watch` to check DNS

---

## 📝 Best Practices

### Before Each Release
1. ✅ All tests pass locally
2. ✅ Version bumped in package.json
3. ✅ CHANGES.md updated (if exists)
4. ✅ README updated if needed
5. ✅ No uncommitted changes

### Release Notes
Write clear release notes:
- What's new
- What changed
- Breaking changes (if any)
- Migration notes (if needed)

### Versioning
Follow semantic versioning:
- **MAJOR** (1.x.x): Breaking changes
- **MINOR** (x.1.x): New features, backward compatible
- **PATCH** (x.x.1): Bug fixes, backward compatible

---

## 🎯 Quick Commands

```bash
# Check build locally
bun run build

# Verify package contents
npm pack --dry-run

# Create patch release
bun version patch && git push && git push --tags

# Create minor release
bun version minor && git push && git push --tags

# Create major release
bun version major && git push && git push --tags
```

---

## 📚 Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [npm Provenance](https://docs.npmjs.com/generating-provenance-statements)
- [GitHub Pages Docs](https://docs.github.com/en/pages)
- [Semantic Versioning](https://semver.org/)

---

**Need help?** Check the Actions tab for detailed logs of each run.

