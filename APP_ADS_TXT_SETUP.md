# App-ads.txt Setup Guide for AdMob

## What is app-ads.txt?

The app-ads.txt file is a text file that helps prevent unauthorized ad sales and ensures you receive proper revenue from your ads. It must be hosted on your website.

## File Created

✅ `app-ads.txt` file has been created with your AdMob publisher ID.

## Step 1: Host the File on a Website

You need to host this file on a website. The domain must match what's listed in your Google Play Console app listing.

### Option A: GitHub Pages (Free & Recommended)

1. **Create a GitHub repository:**
   - Go to https://github.com/new
   - Create a new repository (e.g., `arcadia-website` or `luziv-website`)
   - Make it public

2. **Upload the app-ads.txt file:**
   - Click "Add file" → "Upload files"
   - Upload the `app-ads.txt` file from your project
   - Commit the file

3. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Under "Source", select "Deploy from a branch"
   - Select "main" branch and "/ (root)" folder
   - Click Save

4. **Get your website URL:**
   - Your site will be: `https://[your-username].github.io/[repository-name]/`
   - Example: `https://luziv.github.io/arcadia-website/`
   - The app-ads.txt will be at: `https://[your-username].github.io/[repository-name]/app-ads.txt`

5. **Update Play Console:**
   - Go to Play Console → Your app → Store presence → Main store listing
   - Add your website URL in the "Website" field
   - Make sure the domain matches exactly (e.g., `[your-username].github.io`)

### Option B: Google Sites (Free)

1. **Create a Google Site:**
   - Go to https://sites.google.com
   - Create a new site
   - Name it (e.g., "Arcadia App")

2. **Add the app-ads.txt file:**
   - Create a new page or use the homepage
   - Insert → File upload
   - Upload `app-ads.txt`
   - Publish the site

3. **Get your website URL:**
   - Your site URL will be: `https://sites.google.com/view/[your-site-name]`
   - The app-ads.txt will be at: `https://sites.google.com/view/[your-site-name]/app-ads.txt`

4. **Update Play Console:**
   - Add the website URL to your Play Console listing
   - Domain should be: `sites.google.com`

### Option C: Netlify (Free)

1. **Create a Netlify account:**
   - Go to https://www.netlify.com
   - Sign up with GitHub

2. **Deploy:**
   - Create a new site
   - Drag and drop a folder containing `app-ads.txt`
   - Your site will be: `https://[random-name].netlify.app`

3. **Update Play Console:**
   - Add the Netlify URL to your Play Console listing

### Option D: Your Own Domain (If You Have One)

If you have your own domain:
1. Upload `app-ads.txt` to the root of your website
2. It should be accessible at: `https://yourdomain.com/app-ads.txt`
3. Make sure this domain is listed in Play Console

## Step 2: Verify the File is Accessible

1. **Test the URL:**
   - Open your browser
   - Go to: `https://[your-website]/app-ads.txt`
   - You should see: `google.com, pub-6329609540816457, DIRECT, f08c47fec0942fa0`

2. **Check file format:**
   - File must be plain text (not HTML)
   - Must be accessible via HTTPS
   - Must be at the root or in a standard location

## Step 3: Update Play Console

1. **Add Website to Play Console:**
   - Go to Play Console → Your app
   - Store presence → Main store listing
   - Find "Website" field
   - Enter your website URL (e.g., `https://luziv.github.io/arcadia-website`)
   - Save

2. **Important:** The domain in Play Console must match the domain where app-ads.txt is hosted.

## Step 4: Wait for AdMob Verification

1. **Wait 24-48 hours:**
   - AdMob crawls websites periodically
   - It may take up to 48 hours to verify

2. **Check status in AdMob:**
   - Go to AdMob Console
   - Navigate to your app
   - Check "app-ads.txt status"
   - It should show "Verified" once processed

## Troubleshooting

### File Not Found (404 Error)
- Make sure the file is in the root directory
- Check the file name is exactly `app-ads.txt` (lowercase, with hyphen)
- Verify the file is publicly accessible

### Domain Mismatch
- The domain in Play Console must match where the file is hosted
- Example: If file is at `github.io`, Play Console must list `github.io` domain

### AdMob Not Verifying
- Wait at least 24 hours
- Check file is accessible via HTTPS
- Verify file content is correct (no extra spaces, correct format)
- Make sure domain is listed in Play Console

## Quick Checklist

- [ ] `app-ads.txt` file created with correct content
- [ ] File hosted on a website (GitHub Pages, Google Sites, etc.)
- [ ] File accessible at `https://[your-domain]/app-ads.txt`
- [ ] Website URL added to Play Console listing
- [ ] Domain in Play Console matches hosting domain
- [ ] Wait 24-48 hours for AdMob verification
- [ ] Check AdMob console for verification status

## Current File Content

```
google.com, pub-6329609540816457, DIRECT, f08c47fec0942fa0
```

This is correct and ready to upload!

---

**Note:** If you don't have a website yet, GitHub Pages is the easiest and free option. It takes about 5 minutes to set up.


