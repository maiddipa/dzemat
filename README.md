# Angular PhotoWall — Cloudinary + Google Login, no backend

This project is **Angular only**. There is no ASP.NET, Node API, Firebase, or database server.

## What it does

- Google Sign-In with Google Identity Services in the browser
- Direct image upload from Angular to Cloudinary
- No Cloudinary API secret in the frontend
- Public home gallery loaded from Cloudinary using a shared tag
- Caption and uploader display name stored as Cloudinary contextual metadata
- Immediate display of a just-uploaded image in the current browser while Cloudinary's list cache refreshes

## Important security limitation

A zero-backend app cannot securely enforce Google authentication for Cloudinary uploads. The Angular route requires login, but an unsigned Cloudinary upload preset is visible to browser users and can be called outside the app. Do **not** put your Cloudinary API secret in Angular.

For a production app where only authenticated users may upload, use a small backend/serverless function to verify the Google ID token and generate a signed Cloudinary upload signature.

## 1. Configure Google Sign-In

1. Open Google Cloud Console.
2. Configure the OAuth consent screen.
3. Create an **OAuth 2.0 Client ID** of type **Web application**.
4. Add this JavaScript origin for local development:

   `http://localhost:4200`

5. Add your deployed site origin later, for example:

   `https://your-site.example`

6. Copy the Web Client ID.

## 2. Configure Cloudinary

In your Cloudinary Console:

1. Create an **unsigned upload preset**.
2. Recommended restrictions in the preset:
   - Allowed formats: `jpg,jpeg,png,webp,gif`
   - Max file size: `8388608` bytes (8 MB)
   - Optional asset folder: `photowall`
   - Disallow custom public IDs if available
3. In **Security settings**, under restricted media/image types, enable client-side **Resource list** delivery by clearing/unrestricting `Resource list`.
4. The app uses the tag `photowall_public`. You can keep that value or change it in `environment.ts`.

Cloudinary's client-side resource-list response is cached for about 60 seconds. The app keeps newly uploaded photos in localStorage briefly so the uploader sees them immediately.

## 3. Set Angular configuration

Edit:

`src/environments/environment.ts`

```ts
export const environment = {
  googleClientId: 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com',
  cloudinary: {
    cloudName: 'YOUR_CLOUD_NAME',
    uploadPreset: 'YOUR_UNSIGNED_UPLOAD_PRESET',
    galleryTag: 'photowall_public'
  }
};
```

Only put the following Cloudinary values in Angular:

- Cloud name
- Unsigned upload preset name
- Gallery tag

**Never put `api_secret` in Angular.**

## 4. Run

Requirements: Node.js version compatible with Angular 22 (this project declares Node >= 22.22.3).

```bash
npm install
npm start
```

Open:

`http://localhost:4200`

## How the app works

### Login

Google Identity Services returns a Google ID-token credential to Angular. This frontend-only version decodes the profile fields and stores the displayed user in localStorage. There is no server verification, so this is not a trusted backend authentication session.

### Upload

Angular sends the image directly to:

`https://api.cloudinary.com/v1_1/<cloud-name>/image/upload`

The request contains:

- the selected file
- the unsigned upload preset
- the gallery tag
- caption and Google display name as contextual metadata

### Home gallery

Angular reads images tagged with the gallery tag from Cloudinary's client-side list URL:

`https://res.cloudinary.com/<cloud-name>/image/list/<gallery-tag>.json`

No database is needed.

## What is intentionally not included

- Backend API
- Firebase
- Cloudinary API secret
- Secure server-side Google ID-token verification
- Permanent authenticated delete from Cloudinary

If you later need secure delete, private galleries, user roles, or guaranteed authenticated uploads, add a backend or serverless function.
