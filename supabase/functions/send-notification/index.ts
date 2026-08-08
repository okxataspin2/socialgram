// Supabase Edge Function: send-notification
//
// Server-side FCM push sender. The Firebase service account private key
// lives ONLY here (in Supabase function secrets) - never in the mobile app.
//
// Usage from the app:
//   Supabase.instance.client.functions.invoke(
//     'send-notification',
//     body: {
//       'token': receiver.pushToken,
//       'title': 'SocialGram',
//       'body': 'message preview',
//       'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'chat_id': ...},
//     },
//   );
//
// Deploy:
//   supabase login
//   supabase link --project-ref <your-project-ref>
//   supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat path/to/service-account.json)"
//   supabase functions deploy send-notification
//
// NOTE: Verify the caller is an authenticated user by uncommenting the
// Authorization check below before enabling public access.

import { createClient } from 'npm:@supabase/supabase-js@2';

const SERVICE_ACCOUNT = JSON.parse(
  Deno.env.get('FCM_SERVICE_ACCOUNT_JSON') ?? '{}',
);

let cachedAccessToken: { value: string; expiresAt: number } | null = null;

async function getAccessToken(): Promise<string> {
  const now = Date.now();
  if (cachedAccessToken && now < cachedAccessToken.expiresAt) {
    return cachedAccessToken.value;
  }

  const jwtHeader = {
    alg: 'RS256',
    typ: 'JWT',
  };
  const nowSeconds = Math.floor(now / 1000);
  const jwtPayload = {
    iss: SERVICE_ACCOUNT.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: nowSeconds,
    exp: nowSeconds + 3600,
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

  const signingInput = `${encode(jwtHeader)}.${encode(jwtPayload)}`;

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    pemToBinary(SERVICE_ACCOUNT.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );
  const jwt = `${signingInput}.${btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')}`;

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!tokenResponse.ok) {
    throw new Error(`OAuth token failed: ${tokenResponse.status}`);
  }

  const tokenJson = await tokenResponse.json();
  cachedAccessToken = {
    value: tokenJson.access_token,
    expiresAt: now + (tokenJson.expires_in ?? 3600) * 1000 - 60_000,
  };
  return cachedAccessToken.value;
}

function pemToBinary(pem: string): ArrayBuffer {
  const base64 = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  // Uncomment to restrict to authenticated Supabase users:
  // const authHeader = req.headers.get('Authorization') ?? '';
  // if (!authHeader) return new Response('Unauthorized', { status: 401 });
  // const supabase = createClient(
  //   Deno.env.get('SUPABASE_URL')!,
  //   Deno.env.get('SUPABASE_ANON_KEY')!,
  //   { global: { headers: { Authorization: authHeader } } },
  // );
  // const { data: { user }, error } = await supabase.auth.getUser();
  // if (error || !user) return new Response('Unauthorized', { status: 401 });

  const { token, title, body, data } = await req.json();

  if (!token || !title || !body) {
    return new Response('Missing token, title or body', { status: 400 });
  }

  try {
    const accessToken = await getAccessToken();

    const payload = {
      message: {
        token,
        notification: { title, body },
        data: data ?? {},
        android: {
          priority: 'high',
          notification: {
            channel_id: 'instagram_channel',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: { aps: { 'content-available': 1 } },
        },
      },
    };

    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${SERVICE_ACCOUNT.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(payload),
      },
    );

    if (!fcmResponse.ok) {
      return new Response(await fcmResponse.text(), {
        status: fcmResponse.status,
      });
    }

    return new Response('Notification sent', { status: 200 });
  } catch (error) {
    return new Response(
      `Internal error: ${(error as Error).message}`,
      { status: 500 },
    );
  }
});
