// ignore_for_file: public_member_api_docs

enum Env {
  supabaseUrl('SUPABASE_URL'),
  powerSyncUrl('POWERSYNC_URL'),
  iOSClientId('IOS_CLIENT_ID'),
  webClientId('WEB_CLIENT_ID'),
  supabaseAnonKey('SUPABASE_ANON_KEY'),
  fcmProjectId('FCM_PROJECT_ID'),
  cloudinaryCloudName('CLOUDINARY_CLOUD_NAME'),
  cloudinaryUploadPreset('CLOUDINARY_UPLOAD_PRESET'),
  zegoAppId('ZEGO_APP_ID'),
  zegoAppSign('ZEGO_APP_SIGN');

  const Env(this.value);

  final String value;
}
