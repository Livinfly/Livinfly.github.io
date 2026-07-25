#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fixture_root="$(mktemp -d)"
cleanup() {
    rm -rf -- "${fixture_root}"
}
trap cleanup EXIT HUP INT TERM

content_root="${fixture_root}/acad-blog"
mkdir -p "${content_root}"
fixed_date='2026-07-25T12:34:56+08:00'

create() {
    ACADEMIC_CONTENT_ROOT="${content_root}" \
    ACADEMIC_NOW="${fixed_date}" \
        "${script_dir}/new-academic-post.sh" "$@" >/dev/null
}

create bilingual bilingual-note
create en-only english-note
create zh-only chinese-note
create en-only coverless-note --no-cover

test -f "${content_root}/bilingual-note/en/index.md"
test -f "${content_root}/bilingual-note/zh-cn/index.md"
test -f "${content_root}/bilingual-note/assets/cover.svg"
test -d "${content_root}/bilingual-note/assets/figures"
test -d "${content_root}/bilingual-note/assets/attachments"
grep -Fq "date: ${fixed_date}" "${content_root}/bilingual-note/_index.md"
grep -Fq 'url: /acad-blog/bilingual-note/' "${content_root}/bilingual-note/en/index.md"
grep -Fq 'url: /zh-cn/acad-blog/bilingual-note/' "${content_root}/bilingual-note/zh-cn/index.md"
grep -Fq 'draft: true' "${content_root}/bilingual-note/en/index.md"

test -f "${content_root}/english-note/en/index.md"
test ! -e "${content_root}/english-note/zh-cn"
test -f "${content_root}/chinese-note/zh-cn/index.md"
test ! -e "${content_root}/chinese-note/en"
test ! -e "${content_root}/coverless-note/assets/cover.svg"
! grep -Fq 'image:' "${content_root}/coverless-note/_index.md"

printf 'do-not-overwrite\n' > "${content_root}/bilingual-note/sentinel"
if create bilingual bilingual-note 2>/dev/null; then
    echo 'Existing bundle was overwritten' >&2
    exit 1
fi
grep -Fq 'do-not-overwrite' "${content_root}/bilingual-note/sentinel"

if create en-only Bad-Slug 2>/dev/null; then
    echo 'Invalid slug was accepted' >&2
    exit 1
fi
if find "${content_root}" -maxdepth 1 -name '.Bad-Slug.tmp.*' | grep -q .; then
    echo 'Failed creation left a staging directory' >&2
    exit 1
fi

if create en-only invalid-calendar --date '2026-02-30T09:00:00+08:00' 2>/dev/null; then
    echo 'Invalid calendar date was accepted' >&2
    exit 1
fi
if create en-only missing-timezone --date '2026-07-25T09:00:00' 2>/dev/null; then
    echo 'Timezone-free date was accepted' >&2
    exit 1
fi
test ! -e "${content_root}/invalid-calendar"
test ! -e "${content_root}/missing-timezone"

mkdir "${content_root}/.locked-note.scaffold.lock"
if create en-only locked-note 2>/dev/null; then
    echo 'Existing scaffold lock was ignored' >&2
    exit 1
fi
rmdir "${content_root}/.locked-note.scaffold.lock"
test ! -e "${content_root}/locked-note"

ln -s missing-target "${content_root}/dangling-note"
if create en-only dangling-note 2>/dev/null; then
    echo 'Dangling target symlink was overwritten' >&2
    exit 1
fi
test -L "${content_root}/dangling-note"

if find "${content_root}" -maxdepth 1 \( -name '.*.tmp.*' -o -name '.*.scaffold.lock' \) | grep -q .; then
    echo 'Scaffold left a temporary directory or lock' >&2
    exit 1
fi

echo 'Academic post scaffold tests passed.'
