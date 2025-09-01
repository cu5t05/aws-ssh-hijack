/* /assets/config.js
   Fill these placeholders at deploy time (e.g., via Terraform outputs).
   HOSTED_UI_DOMAIN: e.g., "yourdomain.auth.us-east-1.amazoncognito.com" (no protocol)
   APP_CLIENT_ID:    your Cognito App Client ID (no secret)
   REDIRECT_URI:     e.g., "https://your.site/auth/callback/"
   LOGOUT_URI:       e.g., "https://your.site/"
   SCOPES:           keep minimal (openid email) or add profile if needed
*/
window.AWSAUTH_CONFIG = {
  HOSTED_UI_DOMAIN: "https://auth-xxxxxxxxxxxxxx.amazoncognito.com",
  APP_CLIENT_ID: "xxxxxxxxxxxxxx",
  REDIRECT_URI: "https://xxxxxxxxxxxxxx.cloudfront.net/auth/callback/index.html",
  LOGOUT_URI: "https://xxxxxxxxxxxxxx.cloudfront.net/",
  SCOPES: "openid email profile"
};
