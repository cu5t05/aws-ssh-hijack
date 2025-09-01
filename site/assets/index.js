/* /assets/index.js — Robingentrified (landing) */
(function () {
  'use strict';

  // Elements
  const errEl = document.getElementById('err');
  function showError(msg) {
    if (errEl) {
      errEl.textContent = msg;
      errEl.style.display = 'block';
    }
  }

  // Config
  const cfg = (window && window.AWSAUTH_CONFIG) || {};
  const required = ['HOSTED_UI_DOMAIN', 'APP_CLIENT_ID', 'REDIRECT_URI'];
  for (const k of required) {
    if (!cfg[k]) {
      showError(`Missing ${k} in /assets/config.js`);
      return;
    }
  }
  // Host domain for Hosted UI already includes https:// in config; normalize to no trailing slash
  const hostedBase = String(cfg.HOSTED_UI_DOMAIN).replace(/\/+$/, '');
  const scopes = (cfg.SCOPES || 'openid email').trim().replace(/\s+/g, ' ');

  // Helpers
  function base64UrlFromBytes(bytes) {
    let binary = '';
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
  }
  function randomVerifier() {
    const bytes = new Uint8Array(64); // 64 bytes → ~86 chars base64url
    crypto.getRandomValues(bytes);
    return base64UrlFromBytes(bytes);
  }
  async function sha256Base64Url(str) {
    const data = new TextEncoder().encode(str);
    const digest = await crypto.subtle.digest('SHA-256', data);
    return base64UrlFromBytes(new Uint8Array(digest));
  }

  async function beginAuth(mode) {
    try {
      const verifier = randomVerifier();
      const challenge = await sha256Base64Url(verifier);
      const state = Math.random().toString(36).slice(2) + Date.now().toString(36);

      sessionStorage.setItem('pkce_code_verifier', verifier);
      sessionStorage.setItem('oauth_state', state);

      const params = new URLSearchParams({
        client_id: cfg.APP_CLIENT_ID,
        response_type: 'code',
        redirect_uri: cfg.REDIRECT_URI, // e.g., https://<cf-domain>/auth/callback/ (with trailing slash)
        scope: scopes,
        state,
        code_challenge: challenge,
        code_challenge_method: 'S256'
      });

      // Managed Login endpoints
      // - signup → /signup
      // - signin/default → /login
      const path = mode === 'signup' ? '/signup' : '/login';
      const url  = `${hostedBase}${path}?${params.toString()}`;
      window.location.assign(url);
    } catch (e) {
      showError('Auth start failed. ' + (e && e.message ? e.message : e));
    }
  }

  // Wire buttons
  const signupBtn = document.getElementById('signup');
  const signinBtn = document.getElementById('signin');
  if (signupBtn) signupBtn.addEventListener('click', () => beginAuth('signup'));
  if (signinBtn) signinBtn.addEventListener('click', () => beginAuth());
})();
