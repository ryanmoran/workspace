#!/usr/bin/env bash

set -e
set -u
set -o pipefail

curl \
  --silent \
  --request GET \
  --url https://bifrost.corp.hadrian.co/v1/models \
  --header "Authorization: Bearer ${BIFROST_API_KEY}" |
  jq -r -S '.data[] | {
    id,
    name: .normalized_name,
    context_window: .max_input_tokens,
    default_max_tokens: .max_output_tokens,
    cost_per_1m_in: ((.pricing.prompt|tonumber) * 1000000),
    cost_per_1m_out: ((.pricing.completion|tonumber) * 1000000),
    cost_per_1m_in_cached: ((.pricing.input_cache_write|tonumber? // .pricing.prompt|tonumber? // 0) * 1000000),
    cost_per_1m_out_cached: ((.pricing.input_cache_read|tonumber? // .pricing.completion|tonumber? // 0) * 1000000)
  }' |
  jq -r -S --slurp '{models: .}'
