#!/usr/bin/env bash
#
# Unified asset updater — downloads all external data files used by the app.
# Usage: ./scripts/update-assets.sh [--group bangs|bridges|url-cleaner|url-shorteners] ...
#   Without --group flags, all groups are updated.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAX_RETRIES=3
RETRY_DELAY=5
CURL_TIMEOUT=30

# ── helpers ──────────────────────────────────────────────────────────────────

log()  { printf '[INFO]  %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; }

# Fetch a URL to a local path with retries and atomic write.
# Uses a temp file so a failed download never clobbers an existing asset.
fetch() {
  local url="$1" dest="$2"
  local tmp="${dest}.tmp.$$"

  mkdir -p "$(dirname "$dest")"

  for attempt in $(seq 1 "$MAX_RETRIES"); do
    log "Attempt $attempt/$MAX_RETRIES: $url"
    if curl --proto '=https' --tlsv1.2 -fsSL \
         --max-time "$CURL_TIMEOUT" \
         --retry 0 \
         -o "$tmp" "$url"; then

      # Basic sanity: reject empty files
      if [ ! -s "$tmp" ]; then
        err "Downloaded file is empty: $url"
        rm -f "$tmp"
        return 1
      fi

      mv "$tmp" "$dest"
      log "OK: $dest"
      return 0
    fi

    err "Failed (attempt $attempt/$MAX_RETRIES): $url"
    rm -f "$tmp"
    [ "$attempt" -lt "$MAX_RETRIES" ] && sleep "$RETRY_DELAY"
  done

  err "Giving up after $MAX_RETRIES attempts: $url"
  return 1
}

# Clears temp files a previous run left in an asset directory.
#
# Asset directories are declared with a trailing slash in pubspec.yaml, so every
# file in them is bundled into the APK, and a stale `bangs.json.tmp.*` was riding
# along at 1.2 MB. Every path through fetch() already moves or removes its own
# temp file; the one that cannot is an abort in the middle of curl, and this is
# what collects those on the next run.
sweep_stale_temp_files() {
  local swept=0

  while IFS= read -r -d '' stale; do
    rm -f "$stale"
    log "Removed stale temp asset: ${stale#"$REPO_ROOT/"}"
    swept=$((swept + 1))
  done < <(find "$REPO_ROOT/apps/weblibre/assets" -type f -name '*.tmp.*' -print0)

  [ "$swept" -gt 0 ] && log "Swept $swept stale temp asset(s)."
  return 0
}

# ── asset groups ─────────────────────────────────────────────────────────────

update_bangs() {
  local dir="$REPO_ROOT/apps/weblibre/assets/bangs"
  log "Updating bangs..."

  fetch "https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json" \
        "$dir/bangs.json"
  fetch "https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json" \
        "$dir/kagi_bangs.json"
  fetch "https://raw.githubusercontent.com/FaFre/bangs/refs/heads/custom/data/custom.json" \
        "$dir/custom.json"

  date -u --iso-8601=seconds > "$dir/last_sync.txt"
  log "Bangs sync completed at $(cat "$dir/last_sync.txt")"
}

update_bridges() {
  local dir="$REPO_ROOT/apps/weblibre/assets/preferences"
  log "Updating Tor bridges..."

  fetch "https://bridges.torproject.org/moat/circumvention/builtin" \
        "$dir/builtin-bridges.json"
}

update_url_cleaner() {
  local dir="$REPO_ROOT/apps/weblibre/assets/preferences"
  log "Updating URL cleaner catalog..."

  fetch "https://rules2.clearurls.xyz/data.minify.json" \
        "$dir/url_cleaner_data.minify.json"
}

update_url_shorteners() {
  local dir="$REPO_ROOT/apps/weblibre/assets/preferences"
  log "Updating URL shortener list..."

  fetch "https://raw.githubusercontent.com/MISP/misp-warninglists/refs/heads/main/lists/url-shortener/list.json" \
        "$dir/url-shortener-list.json"
}

update_ublock() {
  local dir="$REPO_ROOT/apps/weblibre/assets/ublock"
  log "Updating uBlock Origin assets..."

  fetch "https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json" \
        "$dir/assets.json"

  date -u --iso-8601=seconds > "$dir/last_sync.txt"
  log "uBlock assets sync completed at $(cat "$dir/last_sync.txt")"
}

# Raw inputs for the popular-sites database. These are build-time only and are
# consumed by scripts/build_sites_db.py to produce assets/sites/sites.db. The
# raw/ directory is gitignored; only the compiled sites.db is committed.
update_popular_sites() {
  local dir="$REPO_ROOT/apps/weblibre/assets/sites/raw"
  log "Updating popular-sites source lists..."

  # Tranco top-1M (manipulation-resistant aggregate ranking). The download
  # endpoint 307-redirects to the latest list; fetch() follows redirects.
  fetch "https://tranco-list.eu/top-1m.csv.zip" \
        "$dir/tranco-top-1m.csv.zip"

  # StevenBlack "gambling-porn-only": the porn + gambling category domains
  # WITHOUT the unified malware/ad base list mixed in.
  fetch "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-only/hosts" \
        "$dir/stevenblack-gambling-porn.txt"

  # Disconnect tracker list (basis of Firefox ETP). build_sites_db.py pulls
  # only the Advertising/Analytics/FingerprintingInvasive/Cryptomining
  # categories so first-party Social/Content sites are preserved.
  fetch "https://raw.githubusercontent.com/disconnectme/disconnect-tracking-protection/master/services.json" \
        "$dir/disconnect-services.json"

  date -u --iso-8601=seconds > "$dir/last_sync.txt"
  log "Popular-sites sources sync completed at $(cat "$dir/last_sync.txt")"
}

# ── main ─────────────────────────────────────────────────────────────────────

ALL_GROUPS=(bangs bridges url-cleaner url-shorteners ublock popular-sites)
SELECTED_GROUPS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group) SELECTED_GROUPS+=("$2"); shift 2 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

if [ ${#SELECTED_GROUPS[@]} -eq 0 ]; then
  SELECTED_GROUPS=("${ALL_GROUPS[@]}")
fi

FAILURES=0

sweep_stale_temp_files

for group in "${SELECTED_GROUPS[@]}"; do
  case "$group" in
    bangs)          update_bangs          || ((FAILURES++)) ;;
    bridges)        update_bridges        || ((FAILURES++)) ;;
    url-cleaner)    update_url_cleaner    || ((FAILURES++)) ;;
    url-shorteners) update_url_shorteners || ((FAILURES++)) ;;
    ublock)         update_ublock         || ((FAILURES++)) ;;
    popular-sites)  update_popular_sites  || ((FAILURES++)) ;;
    *) err "Unknown group: $group"; ((FAILURES++)) ;;
  esac
done

if [ "$FAILURES" -gt 0 ]; then
  err "$FAILURES group(s) failed"
  exit 1
fi

log "All assets updated successfully."
