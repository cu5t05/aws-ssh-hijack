/* /assets/callback.js — Robingentrified (PKCE code exchange) */
(function () {
  'use strict';

  // UI
  const errEl = document.getElementById('err');
  const dbgEl = document.getElementById('dbg');
  function showError(msg) {
    if (errEl) {
      errEl.textContent = msg;
      errEl.style.display = 'block';
    }
  }

  // Config checks
  const cfg = (window && window.AWSAUTH_CONFIG) || {};
  const required = ['HOSTED_UI_DOMAIN', 'APP_CLIENT_ID', 'REDIRECT_URI'];
  for (const k of required) {
    if (!cfg[k]) {
      showError(`Missing ${k} in /assets/config.js`);
      return;
    }
  }
  const domain = String(cfg.HOSTED_UI_DOMAIN).replace(/^https?:\/\//, '').replace(/\/+$/, '');

  // Parse query
  const params = new URLSearchParams(window.location.search);
  const code = params.get('code');
  const state = params.get('state') || '';
  const storedState = sessionStorage.getItem('oauth_state') || '';
  const verifier = sessionStorage.getItem('pkce_code_verifier') || '';

  // Basic validation
  if (!code) {
    showError('Missing authorization code.');
    return;
  }
  if (!state || !storedState || state !== storedState) {
    showError('State verification failed.');
    return;
  }
  if (!verifier) {
    showError('Missing PKCE code_verifier (start from the landing page).');
    return;
  }

  // Exchange code for tokens
  const tokenUrl = `https://${domain}/oauth2/token`;
  const body = new URLSearchParams({
    grant_type: 'authorization_code',
    client_id: cfg.APP_CLIENT_ID,
    code,
    redirect_uri: cfg.REDIRECT_URI,
    code_verifier: verifier
  });

  fetch(tokenUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
    },
    body: body.toString(),
    // credentials: 'omit' — default; Cognito token endpoint does not need cookies from us
  })
    .then(async (res) => {
      if (!res.ok) {
        const text = await res.text().catch(() => '');
        throw new Error(`Token endpoint ${res.status}: ${text.slice(0, 200)}`);
      }
      return res.json();
    })
    .then((tok) => {
      // Expect: { id_token, access_token, token_type, expires_in, ... }
      if (!tok || !tok.id_token) {
        throw new Error('No id_token returned.');
      }

      // Store ephemeral tokens in sessionStorage (tab-scoped)
      sessionStorage.setItem('id_token', tok.id_token);
      if (tok.access_token) sessionStorage.setItem('access_token', tok.access_token);
      if (typeof tok.expires_in === 'number') {
        sessionStorage.setItem('expires_at', String(Date.now() + (tok.expires_in * 1000)));
      }

      // Clean up one-time values
      sessionStorage.removeItem('oauth_state');
      sessionStorage.removeItem('pkce_code_verifier');

      // Redirect to profile
      window.location.replace('/profile.html');
    })
    .catch((e) => {
      showError('Sign-in failed. ' + (e && e.message ? e.message : e));
      if (dbgEl) {
        dbgEl.textContent = 'Debug: ' + (e && (e.stack || e.message) ? (e.stack || e.message) : String(e));
        dbgEl.classList.remove('hidden');
      }
    });
})();
