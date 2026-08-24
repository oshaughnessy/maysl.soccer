---
name: check-render
description: Measure a rendered page on the MAYSL dev server instead of eyeballing it — fold position, box heights, mobile stacking, tap-target sizes, horizontal overflow, computed styles. Use after any CSS or layout change, when a style change "isn't applying", or when asked whether something looks right on mobile.
---

# Check Render

Eyeballing misses things that measuring catches. Real examples from this site: an
answer box 510px tall whose bottom landed at 924px in a 900px viewport; body text
that computed to 13.68px on a phone; `<summary>` tap targets at 23px against a
44px minimum. All three looked fine in a screenshot.

Requires `make serve` running on `http://localhost:4000`.

## First: is the page even current?

Three failure modes look identical to "my CSS is broken." Rule them out **in this
order** before touching code.

**1. `_site` is stale.** A Liquid parse error silently freezes output — the
watcher keeps running and serves the last good build.

```sh
ls -lT _site/index.html _pages/<page>.md | awk '{print $6,$7,$8,$9,$10}'
```

Source newer than output means the build didn't happen. Check the `make serve`
terminal for `Liquid Exception`. Also common: the watcher rebuilds between two
rapid edits and misses the second — `touch` the file to retrigger.

**2. The browser cached the stylesheet.** `/assets/css/main.css` is served with
caching, so a reload of the HTML keeps the old CSS. Confirm by asking the CSSOM
whether the rule even exists, then inject a cache-busted copy:

```js
// does the browser actually have the rule?
[...document.styleSheets].map(s => { try { return s.cssRules.length } catch { return 'CORS' } })
```

```js
await new Promise((res, rej) => {
  const l = document.createElement('link');
  l.rel = 'stylesheet'; l.href = '/assets/css/main.css?bust=' + Date.now();
  l.onload = res; l.onerror = rej; document.head.appendChild(l);
});
await new Promise(r => setTimeout(r, 400));   // rAF is NOT enough — layout is
                                              // still settling and you'll read
                                              // wrong numbers
```

**3. You measured mid-reflow.** Always `setTimeout` ~400ms after injecting CSS or
resizing before reading geometry.

## Viewports

| Width × height | Why |
|---|---|
| 390 × 844 | iPhone-class. ~2/3 of this site's traffic. `html` is 16px here |
| 1280 × 900 | Laptop. Minimal Mistakes scales `html` to 22px at this width, and the right sidebar goes absolute at 1024px |

Anything using `em` behaves differently between those two because the root size
changes — that's how the 13.68px mobile text happened.

## The measurement

```js
() => {
  const el = document.querySelector('<SELECTOR>');
  const r = el.getBoundingClientRect();
  const cs = getComputedStyle(el);
  return {
    viewport: window.innerWidth + 'x' + window.innerHeight,
    fontSize: cs.fontSize,
    display: cs.display,
    height: Math.round(r.height),
    top: Math.round(r.top + window.scrollY),
    bottom: Math.round(r.bottom + window.scrollY),
    fitsAboveFold: (r.bottom + window.scrollY) <= window.innerHeight,
    headroom: Math.round(window.innerHeight - (r.bottom + window.scrollY)),
    horizontalOverflow: document.documentElement.scrollWidth > window.innerWidth
  };
}
```

Add as needed:

- **Tap targets** — every `<summary>`, `.btn`, and standalone link:
  `Math.round(el.getBoundingClientRect().height) >= 44` (Apple HIG; Google says
  48dp). Inline links in a sentence are **exempt** — don't try to size them, it
  detaches their underline.
- **Visual order** (after any flex `order` reshuffle) — sort children by rendered
  top rather than trusting source order:
  ```js
  [...el.children].map(c => ({tag: c.tagName, top: Math.round(c.getBoundingClientRect().top + window.scrollY)}))
    .sort((a,b) => a.top - b.top)
  ```
- **Mobile stacking** — `getComputedStyle(cell).display === 'block'`
- **Clamped scroll areas** — `el.scrollHeight > el.clientHeight`
- **Padding actually applied** — compare a child's left edge against the
  container's, don't trust the computed value. `padding` is ignored on a table
  with `border-collapse: collapse`, and it computes non-zero while doing nothing.

## Thresholds worth holding

| Check | Target |
|---|---|
| Answer box / lead content | clears the fold at 1280×900 with headroom to spare |
| Tap targets | ≥ 44px, excluding inline text links |
| Mobile body text | don't let `em`-based sizing fall below ~15px at 390px |
| Horizontal overflow | `scrollWidth === innerWidth` at 390px |

## Report numbers, not impressions

Say "302px, clears the fold by 185px" rather than "looks good." When a number
fails a threshold, say what you changed and re-measure — and if an earlier
measurement was taken mid-reflow or from cached CSS, correct it explicitly rather
than quietly re-reporting.
