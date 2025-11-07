# NPM Publishing Guide

## Authentication Options

You have **two ways** to publish to npm from GitHub Actions:

### Option 1: Trusted Publishing (OIDC) ✅ Recommended
**No secrets needed!** Uses GitHub's OIDC tokens for authentication.

### Option 2: NPM Token
Traditional method using `NPM_TOKEN` secret.

---

## Option 1: Trusted Publishing Setup (Current)

The workflow is currently configured to use **trusted publishing** via OIDC. This is the most secure method.

### Setup Steps

1. **Configure on npmjs.com:**
   - Go to [npmjs.com](https://www.npmjs.com/) and log in
   - Navigate to your package settings (or account settings if creating new package)
   - Look for "Publishing" or "Automation tokens" section
   - Set up **GitHub Actions** as a trusted publisher
   - Configure:
     - **Repository:** `Swader/x402facilitators`
     - **Workflow file:** `release.yml`
     - **Environment:** (leave empty or set to `npm` if you want)

2. **Ensure workflow has correct permissions:**
   ```yaml
   permissions:
     id-token: write  # Required for OIDC
   ```
   ✅ Already configured in `release.yml`

3. **That's it!** No secrets to manage.

### How It Works
- GitHub Actions generates an OIDC token
- npm verifies the token matches your configured repository
- Publishes automatically with cryptographic provenance
- More secure than long-lived tokens

---

## Option 2: NPM Token (Fallback)

If trusted publishing doesn't work or you prefer tokens:

### Setup Steps

1. **Generate an Automation Token:**
   - Go to [npmjs.com](https://www.npmjs.com/) → Account → Access Tokens
   - Create new token → **Automation** type (required for provenance)
   - Copy the token

2. **Add to GitHub Secrets:**
   - Repository → Settings → Secrets → Actions
   - New secret: `NPM_TOKEN`
   - Paste your token

3. **Update workflow** (if needed):
   ```yaml
   - name: Publish to npm
     env:
       NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
     run: npm publish --access public --provenance
   ```

---

## Local Publishing

### Yes, it will work! ✅

If you're logged in locally with `npm login`, you can publish directly:

```bash
# Build the package
bun run build:lib

# Verify what will be published
npm pack --dry-run

# Publish (if logged in)
npm publish --access public
```

### Local Publishing with Provenance

For provenance locally, you need npm ≥9.5.0:

```bash
# Check npm version
npm --version

# Publish with provenance (requires being logged in)
npm publish --access public --provenance
```

**Note:** Local provenance is less trustworthy than GitHub Actions OIDC provenance. GitHub Actions is preferred for production releases.

---

## Current Workflow Status

Your workflow is configured for:
- ✅ **Trusted Publishing (OIDC)** - Primary method
- ✅ **Provenance attestation** - Cryptographic proof of build
- ✅ **Access: public** - Package is publicly accessible
- ✅ **OIDC permissions** - `id-token: write` enabled

### What Happens on Release

1. GitHub Actions generates OIDC token
2. Workflow builds package with `bun run build:lib`
3. npm validates OIDC token against trusted publisher config
4. Package published with provenance attestation
5. Website deployed to GitHub Pages

---

## Testing Before Real Release

### Dry Run Locally
```bash
bun run build:lib
npm publish --dry-run --access public
```

### Dry Run in GitHub Actions
1. Go to Actions → "Release and Publish"
2. Click "Run workflow"
3. Enable "dry_run" option
4. Reviews artifacts without publishing

---

## First-Time Publish Checklist

If this is your first time publishing `facilitators`:

- [ ] Package name `facilitators` is available on npm
- [ ] You're logged in: `npm whoami` shows your username
- [ ] package.json has correct metadata:
  - [ ] `"name": "facilitators"`
  - [ ] `"version": "0.0.8"` (or current)
  - [ ] `"main"`, `"types"`, `"exports"` are correct
- [ ] `.npmignore` excludes unnecessary files
- [ ] Trusted publisher configured on npmjs.com (for OIDC)
- [ ] OR `NPM_TOKEN` secret added to GitHub (for token auth)

---

## Verifying Publication

After publishing, verify:

```bash
# Check package info
npm view facilitators

# Check specific version
npm view facilitators@0.0.8

# Install and test
npm install facilitators
```

Or visit: https://www.npmjs.com/package/facilitators

---

## Troubleshooting

### "OIDC token request failed"
**Cause:** Trusted publishing not configured or permissions missing.  
**Fix:** Either:
- Set up trusted publishing on npmjs.com
- OR add `NPM_TOKEN` secret and update workflow

### "Package already exists"
**Cause:** Version already published.  
**Fix:** Bump version in package.json

### "401 Unauthorized" (Local)
**Cause:** Not logged in.  
**Fix:** Run `npm login`

### "403 Forbidden" (Local)
**Cause:** Not authorized to publish.  
**Fix:** Ensure you're logged in as the package owner

---

## Recommended Flow

1. **Develop locally** with `bun run build`
2. **Test locally** with `npm pack --dry-run`
3. **Commit & push** changes
4. **Create release** on GitHub
5. **Let GitHub Actions publish** automatically with OIDC
6. **Verify** on npmjs.com and website

This ensures reproducible builds and maximum security!

---

## Resources

- [npm Provenance Documentation](https://docs.npmjs.com/generating-provenance-statements)
- [GitHub OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [npm Publishing Guide](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry)

