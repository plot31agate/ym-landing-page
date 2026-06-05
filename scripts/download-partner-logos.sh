#!/usr/bin/env bash
# Download partner / sponsor logos into ./partner-logos/
#
# Requires outbound network access to logo.clearbit.com and the company
# domains. In Claude Code on the web, this needs a network policy broader
# than the default GitHub-only allowlist (set "No limitations" or a custom
# allowlist when creating the environment, then start a fresh session).
#
# Usage:  bash scripts/download-partner-logos.sh
set -uo pipefail

OUT="partner-logos"
mkdir -p "$OUT"

# slug|company name|primary domain (used for Clearbit logo API)
ENTRIES=(
  "pronet-gaming|Pronet Gaming|pronetgaming.com"
  "betcomply|BetComply|betcomply.com"
  "sportingtech|Sportingtech|sportingtech.com"
  "epic-global-solutions|Epic Global Solutions|epicglobalsolutions.com"
  "mindway-ai|Mindway AI|mindway.ai"
  "casino-kings|Casino Kings|casinokings.com"
  "which-bingo|Which Bingo|whichbingo.co.uk"
  "affiverse|Affiverse|affiversemedia.com"
  "888-holdings|888 Holdings|888holdings.com"
  "vivo-gaming|Vivo Gaming|vivogaming.com"
)

fetch() { # url outfile
  curl -fsSL --max-time 30 -o "$2" "$1" 2>/dev/null
}

for e in "${ENTRIES[@]}"; do
  IFS='|' read -r slug name domain <<<"$e"
  out="$OUT/$slug.png"
  printf '%-22s ' "$name"
  if fetch "https://logo.clearbit.com/${domain}?size=512&format=png" "$out" \
     && [ -s "$out" ]; then
    echo "OK  ($(wc -c <"$out") bytes) <- clearbit:${domain}"
  else
    rm -f "$out"
    echo "FAILED  (try official source manually for ${domain})"
  fi
done

echo
echo "Done. Files in ./$OUT/  — review each for quality/correctness before use."
