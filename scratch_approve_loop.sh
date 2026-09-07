#!/bin/sh
# Approve outside-contributor workflow runs as they appear, then report when
# every check on the PR has reached a terminal state. Emits a line per
# terminal non-pass check plus a final summary, so silence never means
# "everything is fine".
BRANCH="$1"
PR="$2"
i=0
while [ $i -lt 60 ]; do
  for id in $(gh run list --branch "$BRANCH" --limit 20 --json databaseId,conclusion \
                --jq '.[] | select(.conclusion=="action_required") | .databaseId'); do
    gh api -X POST "repos/icellan/runar/actions/runs/$id/approve" >/dev/null 2>&1 \
      && echo "approved run $id"
  done
  s=$(gh pr checks "$PR" --json name,bucket 2>/dev/null)
  if [ -n "$s" ]; then
    pending=$(printf '%s' "$s" | jq -r '[.[] | select(.bucket=="pending")] | length')
    total=$(printf '%s' "$s" | jq -r 'length')
    if [ "$pending" = "0" ] && [ "$total" != "0" ]; then
      printf '%s' "$s" | jq -r '.[] | select(.bucket=="fail") | "FAILED: " + .name'
      printf 'PR#%s CI COMPLETE: %s pass / %s fail / %s total\n' "$PR" \
        "$(printf '%s' "$s" | jq -r '[.[]|select(.bucket=="pass")]|length')" \
        "$(printf '%s' "$s" | jq -r '[.[]|select(.bucket=="fail")]|length')" "$total"
      exit 0
    fi
  fi
  i=$((i+1))
  sleep 45
done
echo "PR#$PR watch timed out with checks still pending"
