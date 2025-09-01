/* /assets/profile.js — Robingentrified (profile page) */
(function () {
  'use strict';

  // UI
  const emailEl = document.getElementById('email');
  const errEl = document.getElementById('err');
  const logoutEl = document.getElementById('logout');

  function showError(msg) {
    if (errEl) {
      errEl.textContent = msg;
      errEl.style.display = 'block';
    }
  }

  // Config
  const cfg = (window && window.AWSAUTH_CONFIG) || {};
  const required = ['HOSTED_UI_DOMAIN', 'APP_CLIENT_ID', 'LOGOUT_URI'];
  for (const k of required) {
    if (!cfg[k]) {
      showError(`Missing ${k} in /assets/config.js`);
      return;
    }
  }
  const domain = String(cfg.HOSTED_UI_DOMAIN).replace(/^https?:\/\//, '').replace(/\/+$/, '');

  // Token helpers
  function base64UrlToBase64(s) { return s.replace(/-/g, '+').replace(/_/g, '/'); }
  function decodeJwtPayload(token) {
    const parts = String(token).split('.');
    if (parts.length !== 3) throw new Error('Invalid JWT');
    const json = atob(base64UrlToBase64(parts[1]).padEnd(parts[1].length + (4 - parts[1].length % 4) % 4, '='));
    return JSON.parse(json);
  }
  function isExpired(payload, skewSec = 60) {
    if (!payload || typeof payload.exp !== 'number') return true;
    const nowSec = Math.floor(Date.now() / 1000);
    return nowSec >= (payload.exp - skewSec);
  }

  // Read ID token from sessionStorage
  const idToken = sessionStorage.getItem('id_token');
  if (!idToken) {
    // Not signed in — bounce home
    window.location.replace('/');
    return;
  }

  let payload;
  try {
    payload = decodeJwtPayload(idToken);
  } catch (e) {
    // Corrupt token — bounce home
    window.location.replace('/');
    return;
  }

  if (isExpired(payload)) {
    // Expired — bounce home
    window.location.replace('/');
    return;
  }

  // Show email (fallbacks if scope/email missing)
  const email = payload.email || payload['cognito:username'] || payload.sub || 'Unknown user';
  if (emailEl) emailEl.textContent = `Signed in as ${email}`;

  // Wire logout link to Hosted UI /logout
  if (logoutEl) {
    const p = new URLSearchParams({
      client_id: cfg.APP_CLIENT_ID,
      logout_uri: cfg.LOGOUT_URI
    });
    logoutEl.setAttribute('href', `https://${domain}/logout?${p.toString()}`);
  }
})();
