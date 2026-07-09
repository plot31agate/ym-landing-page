# Win a Messi Boot — Dev Handoff

Everything YM engineering needs to ship the Signed Messi Boot Giveaway campaign
(entry page + thank-you page) and wire it into the platform.

- **Campaign name:** Signed Messi Boot Giveaway
- **Traffic tag:** `WIN-MESSI` (baked into the entry form as a hidden field)
- **Entries close:** immediately before FIFA World Cup 2026 Final kickoff, Sunday 19 July 2026
- **Winner drawn + announced:** Monday 20 July 2026
- **Prize:** 1 × hand-signed Lionel Messi football boot, framed dome, Firma Stella Certificate of Authenticity

---

## 1. Files in this repo

Static assets ready to deploy. All live at repo root on branch `claude/adoring-pascal-6ycJN`.

| File | Purpose |
|---|---|
| `win-messi.html` | Entry page (hero, prize, authenticity, follow-required section, sign-up form, T&Cs) |
| `thank-you.html` | Post-signup confirmation + Predictor cross-sell (single-hero, `noindex`) |
| `messi-boot-prize.png` | Framed prize image, used in hero + prize card of `win-messi.html` |
| `ym-bg-image.png` | Shared hero background (also used on `index.html` and `about.html`) |
| `ymp-logo-white.png` | Header logo (white — for dark hero) |
| `logo_short.svg` | Footer logo (dark — for white footer) |

Dependencies loaded from CDN inline (no build step required):

- Tailwind CSS via `<script src="https://cdn.tailwindcss.com">`
- Google Fonts — Space Grotesk (400/500/600/700) + Anton (400)

---

## 2. URL structure

Deploy the pages at these exact paths (T&Cs and internal links reference them literally):

| Path | Serves |
|---|---|
| `/win-messi` | `win-messi.html` |
| `/thank-you` | `thank-you.html` |
| `/world-cup-2026` | (existing) — main World Cup Predictor landing page, referenced by the thank-you CTA |

If you're serving `.html` extensions instead of clean URLs:

- Update T&Cs Section 4 in `win-messi.html`: change `ympredictions.com/win-messi` to whatever URL you use
- Update the thank-you CTA link in `thank-you.html`: currently `href="/world-cup-2026"`
- Update the form `data-success-redirect` attribute in `win-messi.html`: currently `"thank-you.html"`

---

## 3. Sign-up form — wiring

The form in `win-messi.html` is the entire on-page conversion. It sits inside
`<section id="enter">`.

### 3.1 Form attributes to fill in

```html
<form action=""                              <!-- POST endpoint goes here -->
      method="post"
      data-success-redirect="thank-you.html" <!-- redirect target after success -->
      novalidate>
```

### 3.2 Fields the form submits

| Name | Type | Required | Notes |
|---|---|---|---|
| `source` | hidden | yes | Value is fixed to `WIN-MESSI`. Store on the account for attribution. |
| `email` | email | yes | Standard email input, `autocomplete="email"` |
| `password` | password | yes | `minlength=8`. Same rules as main platform |
| `promo_code` | text | no | Max 32 chars, uppercase-styled input. Used for partner codes on non-Cam Cards traffic. Store on the account. Behaviour TBC by product |
| `over18` | checkbox | yes | 18+ confirmation |
| `terms` | checkbox | yes | Consent to competition T&Cs + platform terms + privacy policy |
| `marketing` | checkbox | no | Marketing opt-in for Predictor updates + future competitions |

### 3.3 Expected server behaviour

1. Validate inputs (email format, password strength, both required checkboxes present).
2. **Do NOT reject on password reuse** — this is a real platform account, treat it as `POST /register`.
3. Create the YM Predictions platform account (identical to normal registration).
4. Store `source=WIN-MESSI` and `promo_code` on the account record.
5. Send verification email (Section 4 below).
6. On success, redirect the browser to `/thank-you`.
7. On validation error, re-render the page with error messages (or use client-side JS — that's your call, HTML5 `required`/`minlength` are already set).

### 3.4 Analytics event

**Fire the campaign conversion on email-verified, NOT on form submit.**
(This was called out in the original brief. Form-submit fires would inflate the funnel.)

- Registered event → GA/GTM + Meta Pixel, on POST success
- Verified event → GA/GTM + Meta Pixel + campaign conversion, on verification link click

---

## 4. Email verification flow

Verifying the email is what actually locks the entry in and what fires the
campaign conversion. This is called out in the T&Cs Section 4.

1. On successful registration, send a verification email with a unique tokenised link.
2. Verification landing page:
   - Marks the platform email as verified
   - Marks the competition entry as **valid** (draws only pull from valid entries)
   - Fires the campaign conversion event
   - Redirects to the Predictor / main platform, OR shows a confirmation screen
3. If verification is not completed by the closing time (Sun 19 Jul), the entry is discarded.

---

## 5. Follow-to-enter (required)

The T&Cs (Section 4) state that following YM Predictions on **at least one** of
Instagram / X / TikTok / Facebook is required to enter.

### 5.1 On the entry page

Four platform buttons already sit in a dedicated **"Follow YM Predictions"**
section between the hero and the prize section. They link to placeholder URLs
right now:

- `https://instagram.com/ympredictions`
- `https://x.com/ympredictions`
- `https://tiktok.com/@ympredictions`
- `https://facebook.com/ympredictions`

**Action for social team:** confirm the real handle on each platform and
give dev the actual URLs. Dev then updates the four `<a href="…">` in the
`FOLLOW TO ENTER` section of `win-messi.html`.

### 5.2 At winner claim

Section 6 of the T&Cs says the winner must confirm they were following at
the time of the draw. This is a manual check, not automated:

1. Draw pulls a random valid entry (verified email + `source=WIN-MESSI`).
2. Notification email asks the winner to reply with the social handle
   they follow YMP from.
3. Social team verifies the follow exists AND that the account existed
   before the draw (Mon 20 Jul).
4. If not verified: forfeit, draw an alternative winner.

Store the winner's confirmed platform + handle for record-keeping.

---

## 6. Thank-you page

`thank-you.html` is the single-page confirmation.

- Add `<meta name="robots" content="noindex">` is already set — search engines shouldn't index it.
- Users only see it after form success (server-side redirect from step 3.3).
- CTA button links to `/world-cup-2026` — confirm that path is correct on production; update if it lives elsewhere (e.g. `/predictor`).

No form on this page. It's purely informational.

---

## 7. Tracking / attribution

### 7.1 Sources

- **`source=WIN-MESSI`** is on every registration from the entry page (hidden form field).
- **UTMs** should still be respected on inbound URLs for channel-level attribution:
  - `utm_source=camcards` for Cam Cards traffic
  - `utm_source=meta` / `utm_source=google` for paid
  - `utm_source=organic` etc for organic
- **Promo code** field on the form can carry partner codes for non-Cam Cards traffic (behaviour to be defined by product — extra entry? no functional effect, just tracking? TBC).

### 7.2 Conversion event

Fire on **email verified**, not form submit:

- GA4 event: `messi_boot_entry_verified`
- Meta Pixel: `CompleteRegistration` + custom `Lead` with campaign=`win-messi`
- Google Ads: conversion tag

### 7.3 Paid ads pre-clear

Meta and Google gambling / promotion policy — per the campaign brief the paid
team needs to pre-clear creatives before launch. This is a paid-team task, not
dev, but call it out on launch checklist.

---

## 8. CRM sequence

From the original brief:

1. **Email 1** — Verification email (immediate, on registration)
2. **Email 2** — Thanks + play Predictor (immediately post-verification)
3. **Email 3** — Nudge if no Predictor pick made within N days
4. **Recurring** — Match fixtures + leaderboard position

CRM owner + Activewin build the sequence. Dev only needs to fire the trigger
events (`registered`, `email_verified`, `first_predictor_pick`, etc.) to CRM.

---

## 9. Winner draw + prize claim

| Date | Action | Owner |
|---|---|---|
| Sun 19 Jul, before Final kickoff | Entries close automatically at published UTC time | Dev |
| Mon 20 Jul | Winner drawn at random from valid entries | Dev / Ops |
| Mon 20 Jul | Winner notified by email | CRM |
| Mon 20 Jul → +7 days | Winner responds + provides ID + confirms social handle | Ops |
| On successful verification | Prize dispatched | YM Ops |
| No response within 7 days | Draw alternative winner | Ops |

The valid-entries pool is: `verified_email = true AND source = 'WIN-MESSI' AND registered_before = 2026-07-19T[close_time]Z`.

---

## 10. Content items still to confirm

These placeholders are already resolved to reasonable defaults on the page,
but should be confirmed by the relevant owner before launch. Nothing here
needs a code change to display — but change the values in `win-messi.html`
if the confirmed answer differs.

| Item | Current value | Owner | Change in |
|---|---|---|---|
| Promoter legal entity | YM Predictions Europe Ltd. | Legal | T&Cs Section 1 |
| Eligible territories | UK + EU + Iceland/Liechtenstein/Norway/Switzerland | Legal | T&Cs Section 2 |
| Exact close time (UTC) | "immediately before Final kickoff, exact UTC on Platform at launch" | Ops | T&Cs Section 3 |
| Response window | 7 days from notification | Legal | T&Cs Section 6 |
| KYC scope at claim | Photo ID + 18+ + resident + follow verify | Legal | T&Cs Section 6 |
| Governing law | Malta | Legal | T&Cs Section 12 |
| Social handles (4) | `ympredictions` on each platform | Social | Follow-to-enter section + Section 4 wording (if handles differ significantly) |
| Prize value declaration | Removed (not stated) | Legal | T&Cs Section 5 (add if legally required in territory) |

---

## 11. Timeline

From the original campaign brief. Adjust to actual dates as they land.

| Date | Milestone | Blocker for |
|---|---|---|
| By Wed 8 Jul | LP live, tracking + CRM armed, boot secured, T&Cs signed off | Launch |
| Thu 9 Jul (target) | Launch — pinned across all channels, paid live | Quarter-finals kickoff |
| 9–15 Jul | Momentum — reminders, stories, shorts | Semis |
| 16–17 Jul | Final countdown — last-chance push + paid retargeting | Entries close |
| Fri 17 Jul → Sun 19 Jul | Entry window open to Final kickoff | Draw |
| Sun 19 Jul (Final kickoff) | Entries close | Draw |
| Mon 20 Jul | Winner drawn + announced across CraigCamCards + YMP channels | Prize dispatch |

---

## 12. Launch checklist

Before flipping DNS / removing `noindex`:

- [ ] Form `action=""` filled in with registration endpoint URL
- [ ] Form success redirect confirmed (`data-success-redirect` matches the deployed thank-you URL)
- [ ] Email verification link tested end-to-end (creation → click → conversion event → CRM enrolment)
- [ ] Four social platform URLs updated with real handles
- [ ] T&Cs reviewed and approved by YM legal (banner still reads "Draft for legal review before publication")
- [ ] `source=WIN-MESSI` visible on registered account records in the DB
- [ ] Promo code storage confirmed on account records
- [ ] Meta Pixel + Google Ads tags firing on the verify event, not the form submit
- [ ] Boot secured, packaged, insured
- [ ] Winner-notification email drafted and staged in CRM
- [ ] Paid creatives cleared under Meta + Google promo policy
- [ ] `noindex` on `thank-you.html` confirmed live

---

Contact: post-signup redirects to `/thank-you`. Any dev questions on the
static markup can reference this doc and the file at
`win-messi.html` on branch `claude/adoring-pascal-6ycJN`.
