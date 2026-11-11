#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Foundation Devices, Inc. <hello@foundation.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later
# The review bot's only write to GitHub: review.json as a comment review on one PR, or a thumbs-up.
set -euo pipefail
[ $# -eq 2 ] || { echo "usage: $0 <owner/repo> <pr-number>" >&2; exit 2; }
repo=$1
pr=$2
bot='claude[bot]'

# A thumbs-up only vouches for the latest commit.
for id in $(gh api --paginate "repos/$repo/issues/$pr/reactions" --jq ".[] | select(.user.login == \"$bot\" and .content == \"+1\") | .id"); do
  gh api --method DELETE "repos/$repo/issues/$pr/reactions/$id" > /dev/null
done

if [ -s review.json ]; then
  jq '{event: "COMMENT", body: (.body // ""), comments: (.comments // [])}' review.json > review-post.json
  gh api --method POST "repos/$repo/pulls/$pr/reviews" --input review-post.json > /dev/null
  echo "Posted a review with $(jq '.comments | length' review-post.json) inline comments."
else
  gh api --method POST "repos/$repo/issues/$pr/reactions" -f content=+1 > /dev/null
  echo "No review.json, so reacted with a thumbs-up."
fi
