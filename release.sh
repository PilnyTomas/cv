#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

force=false
if [[ $# -gt 1 ]] || { [[ $# -eq 1 ]] && [[ "$1" != "-f" ]]; }; then
  printf 'Usage: %s [-f]\n' "${0##*/}" >&2
  exit 2
fi
if [[ $# -eq 1 ]]; then
  force=true
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  printf 'Cannot release: Git remote "origin" is not configured.\n' >&2
  exit 1
fi

release_tag_available() {
  local candidate=$1 status

  if git show-ref --verify --quiet "refs/tags/$candidate"; then
    return 1
  fi

  if git ls-remote --exit-code --refs origin "refs/tags/$candidate" >/dev/null 2>&1; then
    return 1
  else
    status=$?
    if [[ $status -ne 2 ]]; then
      return 2
    fi
  fi

  return 0
}

timestamp=$(date +%F-%H-%M-%S)
date_part=${timestamp:0:10}
time_part=${timestamp:11:5}
second_part=${timestamp:17:2}
tag="v$date_part"
if release_tag_available "$tag"; then
  :
else
  status=$?
  if [[ $status -ne 1 ]]; then
    printf 'Cannot check release tags on remote "origin".\n' >&2
    exit 1
  fi

  tag="v$date_part-$time_part"
  if release_tag_available "$tag"; then
    :
  else
    status=$?
    if [[ $status -ne 1 ]]; then
      printf 'Cannot check release tags on remote "origin".\n' >&2
      exit 1
    fi

    tag="v$date_part-$time_part-$second_part"
    suffix=2
    while true; do
      if release_tag_available "$tag"; then
        break
      else
        status=$?
        if [[ $status -ne 1 ]]; then
          printf 'Cannot check release tags on remote "origin".\n' >&2
          exit 1
        fi
      fi
      tag="v$date_part-$time_part-$second_part-$suffix"
      suffix=$((suffix + 1))
    done
  fi
fi

if previous_tag=$(git describe --tags --match 'v????-??-??*' --abbrev=0 2>/dev/null); then
  commit_count=$(git rev-list --count "$previous_tag"..HEAD)
  file_summary=$(git diff --shortstat "$previous_tag"..HEAD)
  changed_file_count=$(git diff --name-only "$previous_tag"..HEAD | wc -l | tr -d ' ')
  printf 'Previous release: %s\n' "$previous_tag"
  printf 'Commits since previous release: %s\n' "$commit_count"
  printf 'Changed files: %s\n' "$changed_file_count"
  printf 'Change summary: %s\n' "${file_summary:-none}"
else
  commit_count=$(git rev-list --count HEAD)
  tracked_file_count=$(git ls-tree -r --name-only HEAD | wc -l | tr -d ' ')
  printf 'Previous release: none (first dated release)\n'
  printf 'Commits in history: %s\n' "$commit_count"
  printf 'Tracked files in this release: %s\n' "$tracked_file_count"
fi

dirty_count=$(git status --short | wc -l | tr -d ' ')
printf 'Uncommitted paths: %s\n' "$dirty_count"
if [[ "$dirty_count" -gt 0 ]]; then
  git status --short
fi

printf 'Release tag: %s\n' "$tag"
if [[ "$force" != true ]]; then
  read -r -p 'Are you sure you want to release? [y/N] ' answer
  case "$answer" in
    y|Y|yes|YES|Yes) ;;
    *) printf 'Release cancelled.\n'; exit 0 ;;
  esac
fi

git tag "$tag"
git push origin "$tag"
printf 'Pushed %s; GitHub Actions will build and publish the PDF.\n' "$tag"
