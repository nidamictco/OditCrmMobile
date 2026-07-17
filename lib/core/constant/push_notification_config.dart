/// Connection settings for the `odit-notify-server` Node.js push service
/// (see odit-notify-server/index.js — POST /send-push).
///
/// IMPORTANT:
/// - [baseUrl] must point at your deployed Render URL (or local server while
///   testing), with NO trailing slash.
/// - [apiSecret] MUST be identical to the `PUSH_API_SECRET` environment
///   variable configured on the server. The server currently falls back to
///   the placeholder 'CHANGE_THIS_TO_A_LONG_RANDOM_STRING' when that env var
///   isn't set — replace BOTH sides with a real random string before
///   shipping to production, otherwise every client shares a guessable key.
class PushNotificationConfig {
  PushNotificationConfig._();

  static const String baseUrl = 'https://odit-notify-server.onrender.com';
  static const String apiSecret = 'abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz';
} 