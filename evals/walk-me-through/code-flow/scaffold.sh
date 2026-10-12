#!/usr/bin/env bash
set -e
mkdir -p web gateway iam docs/decisions
cat > web/activity.js <<'P'
// Counts only real input. Shared across tabs through localStorage.
const KEY = "lastActivity";
export function onInput() { localStorage.setItem(KEY, String(Date.now())); }
for (const ev of ["keydown", "pointerdown", "wheel", "touchstart"]) addEventListener(ev, onInput, { passive: true });
P
cat > web/idle-timer.js <<'P'
import { warn, signOut } from "./dialogs.js";
const WARN_BEFORE_MS = 2 * 60 * 1000;
export function startIdleTimer(idleLimitMs) {
  setInterval(() => {
    const idle = Date.now() - Number(localStorage.getItem("lastActivity") || Date.now());
    if (idle >= idleLimitMs) signOut("idle");
    else if (idle >= idleLimitMs - WARN_BEFORE_MS) warn(idleLimitMs - idle);
  }, 1000);
}
P
cat > web/boot.js <<'P'
import { startIdleTimer } from "./idle-timer.js";
const me = await fetch("/bff/me").then(r => r.json());
startIdleTimer(me.session.idleSeconds * 1000);
P
cat > gateway/me.py <<'P'
def me(session):
    claims = session.id_token_claims
    return {"user": claims["sub"], "session": {"idleSeconds": claims["ma_session_idle"]}}
P
cat > iam/token_customizer.py <<'P'
def customize(claims, tenant, policies):
    policy = policies.get(tenant)
    claims["ma_session_idle"] = policy.idle_seconds
    return claims
P
cat > docs/decisions/0007-limits-in-token.md <<'P'
# 0007 Session limits travel in the ID token

Status: accepted, 2026-09-30

We considered letting the gateway read tenant_session_policy on each request, and calling IAM for it.
Both add a database or network call to every request. The gateway must stay stateless,
so IAM writes the limits into the ID token at sign-in and the gateway reads them from the session.
P
