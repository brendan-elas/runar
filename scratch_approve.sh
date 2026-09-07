#!/bin/sh
# Approve the pending workflow runs for an outside-contributor PR branch.
set -u
BRANCH="$1"
for id in $(gh run list --branch "$BRANCH" --limit 20 --json databaseId,conclusion \
              --jq '.[] | select(.conclusion=="action_required") | .databaseId'); do
  printf 'approving %s ... ' "$id"
  gh api -X POST "repos/icellan/runar/actions/runs/$id/approve" >/dev/null 2>&1 \
    && echo ok || echo "failed (may already be approved)"
done
