#!/usr/bin/env bash
set -euo pipefail

CREDENTIALS="$HOME/.claude/.credentials.json"

if [[ ! -f "$CREDENTIALS" ]]; then
  echo "Error: credentials not found at $CREDENTIALS" >&2
  exit 1
fi

TOKEN=$(jq -r '
  if .accessToken then .accessToken
  elif .claudeAiOauth.accessToken then .claudeAiOauth.accessToken
  else (to_entries[] | .value | .accessToken? // empty)
  end
' "$CREDENTIALS" 2>/dev/null | head -1)

if [[ -z "$TOKEN" ]]; then
  echo "Error: could not extract accessToken from credentials" >&2
  exit 1
fi

HEADERS=$(curl -si \
  -X POST "https://api.anthropic.com/v1/messages" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Content-Type: application/json" \
  -H "User-Agent: claude-code/2.1.5" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' \
  2>/dev/null)

get_header() {
  echo "$HEADERS" | grep -i "^$1:" | tail -1 | sed 's/^[^:]*: *//' | tr -d '\r'
}

SESSION_PCT=$(get_header "anthropic-ratelimit-unified-5h-utilization")
SESSION_RESET=$(get_header "anthropic-ratelimit-unified-5h-reset")
WEEKLY_PCT=$(get_header "anthropic-ratelimit-unified-7d-utilization")
WEEKLY_RESET=$(get_header "anthropic-ratelimit-unified-7d-reset")
STATUS=$(get_header "anthropic-ratelimit-unified-5h-status")

if [[ -z "$SESSION_PCT" ]]; then
  HTTP_STATUS=$(echo "$HEADERS" | head -1)
  echo "Error: no rate-limit headers in response. HTTP status: $HTTP_STATUS" >&2
  exit 1
fi

pct_int() {
  printf "%.0f" "$(echo "$1 * 100" | bc -l 2>/dev/null || echo 0)"
}

reset_in() {
  local ts="$1"
  local now
  now=$(date +%s)
  local diff=$(( ${ts%.*} - now ))
  if (( diff <= 0 )); then
    echo "now"
  elif (( diff < 3600 )); then
    printf "%dm" $(( diff / 60 ))
  else
    printf "%dh%dm" $(( diff / 3600 )) $(( (diff % 3600) / 60 ))
  fi
}

bar() {
  local pct=$1
  local width=30
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  # color: green < 60, yellow < 85, red >= 85
  if (( pct >= 85 )); then
    local color="\033[0;31m"
  elif (( pct >= 60 )); then
    local color="\033[0;33m"
  else
    local color="\033[0;32m"
  fi
  local reset="\033[0m"
  printf "${color}"
  if (( filled > 0 )); then printf '█%.0s' $(seq 1 $filled); fi
  printf "${reset}"
  if (( empty > 0 )); then printf '░%.0s' $(seq 1 $empty); fi
}

SESSION_INT=$(pct_int "$SESSION_PCT")
WEEKLY_INT=$(pct_int "$WEEKLY_PCT")
SESSION_RESET_IN=$(reset_in "$SESSION_RESET")
WEEKLY_RESET_IN=$(reset_in "$WEEKLY_RESET")

printf "\n  \033[1mClaude Usage\033[0m\n\n"
printf "  5h  %3d%%  $(bar $SESSION_INT)  resets in %s\n" "$SESSION_INT" "$SESSION_RESET_IN"
printf "  7d  %3d%%  $(bar $WEEKLY_INT)  resets in %s\n\n" "$WEEKLY_INT" "$WEEKLY_RESET_IN"
if [[ -n "$STATUS" && "$STATUS" != "allowed" ]]; then
  printf "  \033[0;31mstatus: %s\033[0m\n\n" "$STATUS"
fi
