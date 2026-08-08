# SocialGram - Supabase Setup Guide

## Quick Start

1. Create a [Supabase project](https://supabase.com/dashboard)
2. Go to **SQL Editor** → **New Query**
3. **Copy & paste** the entire contents of `complete_schema.sql`
4. Click **Run** (Play button)
5. Wait ~30 seconds for completion

That's it! Your database is fully set up.

## Make First User Admin

```sql
UPDATE auth.users 
SET raw_app_meta_data = '{"role": "admin"}' 
WHERE email = 'your-admin@email.com';
```

> Use `raw_app_meta_data` (not `app_metadata`) — newer Supabase versions removed
> the `app_metadata` column. Sign out and back in after running this, so the
> JWT (which the app reads via `user.appMetadata['role']`) is refreshed.

## Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```env
SUPABASE_URL=https://[project-ref].supabase.co
SUPABASE_ANON_KEY=your-anon-key
POWERSYNC_URL=your-powersync-url
FCM_SERVER_KEY=your-fcm-server-key
IOS_CLIENT_ID=your-ios-client-id
WEB_CLIENT_ID=your-web-client-id
FCM_PROJECT_ID=your-firebase-project-id
FCM_SERVICE_ACCOUNT_JSON=your-full-service-account-json
CLOUDINARY_CLOUD_NAME=your-cloudinary-cloud-name
CLOUDINARY_UPLOAD_PRESET=socialgram_uploads
```

## Cloudinary Setup (Free Tier)

### 1. Create Account
- Go to [Cloudinary.com](https://cloudinary.com/users/register)
- Note your **Cloud Name** from the dashboard

### 2. Upload Preset
- Go to **Settings** → **Upload** → **Upload presets**
- Create new preset: `socialgram_uploads`
- Set to **Unsigned** (for client-side uploads)
- In **Upload Options** set:
  - `folder` = `socialgram`
  - `resource_type` = `auto` (handles both images and videos)
- Save preset

### 3. Environment Variables
Add these to your `.env` file:
```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=socialgram_uploads
```

### Free Tier Capacity
- **25 GB** storage (thousands of photos)
- **25 GB** bandwidth (thousands of views)
- **1,000 transformations** per month
- **Unlimited** files (no hard count limit)

Perfect for **1,000-5,000 active users**.

## File Limits (Enforced in App)

| Content Type | Max Size | Additional Limits |
|-------------|----------|-------------------|
| Profile Picture | 5 MB | - |
| Post Photo | 5 MB | - |
| Post Video | 50 MB | 20 seconds max |
| Story Photo | 5 MB | Auto-delete after 24h |
| Story Video | 50 MB | 20 seconds max, auto-delete |
| Chat Media | 5 MB | - |

## Folder Structure (Cloudinary)

```
/socialgram/
├── users/
│   └── {userId}/profile.jpg
├── posts/
│   ├── images/{postId}.jpg
│   └── videos/{postId}.mp4
├── stories/
│   ├── images/{storyId}.jpg
│   └── videos/{storyId}.mp4
└── chat/
    ├── group_chats/
    │   └── {chatId}/{messageId}.jpg
    └── direct_chats/
        └── {chatId}/{messageId}.jpg
```

## Storage Optimization

Cloudinary automatically:
- Converts to WebP/AVIF for browsers
- Applies auto-quality compression (~60-70% smaller)
- Resizes for responsive design
- Generates multiple thumbnail sizes
- Serves via global CDN (200+ locations)

## 📞 Voice Messages & Calls

Voice messages are stored in Supabase Storage bucket:
- **Bucket**: `messages` (private, `public = false`)
- **Folder structure**: `messages/{conversationId}/voice_{uuid}.m4a`
- **Access**: Participants only (RLS on `storage.objects`); playback uses short-lived signed URLs via `createSignedUrl` (10-minute expiry), resolved right before playback in the app

Video/audio calls use:
- **ZEGOCLOUD**: `ZegoUIKitPrebuiltCall` + `ZegoUIKitPrebuiltCallInvitationService` (free tier, requires `ZEGO_APP_ID`/`ZEGO_APP_SIGN` in env)
- **Call history**: Stored in `calls` table (synced via PowerSync)

## 🏁 Production Checklist

- [ ] Set up Cloudinary account
- [ ] Create upload preset
- [ ] Configure authentication providers
- [ ] Set your first admin user
- [ ] Copy `.env.example` → `.env` with real credentials
- [ ] Set up ZEGOCLOUD (required) for video calls
