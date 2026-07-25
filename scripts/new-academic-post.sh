#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: scripts/new-academic-post.sh MODE SLUG [--date RFC3339] [--no-cover]

MODE is one of: bilingual, en-only, zh-only.
SLUG must contain only lowercase letters, digits, and single hyphens.

New language pages are drafts. The default shared cover is an anonymous SVG;
replace it before publishing, or pass --no-cover to omit it.
EOF
}

if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
    exit 0
fi

if [[ $# -lt 2 ]]; then
    usage >&2
    exit 2
fi

mode="$1"
slug="$2"
shift 2

case "${mode}" in
    bilingual|en-only|zh-only) ;;
    *)
        echo "Unsupported mode: ${mode}" >&2
        usage >&2
        exit 2
        ;;
esac

if [[ ! "${slug}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "Invalid slug: ${slug}" >&2
    exit 2
fi

published="${ACADEMIC_NOW:-}"
with_cover=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --date)
            [[ $# -ge 2 ]] || { echo "--date requires a value" >&2; exit 2; }
            published="$2"
            shift 2
            ;;
        --no-cover)
            with_cover=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "${published}" ]]; then
    compact_date="$(date '+%Y-%m-%dT%H:%M:%S%z')"
    published="${compact_date:0:${#compact_date}-2}:${compact_date: -2}"
fi

if [[ ! "${published}" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(Z|[+-]([0-9]{2}):([0-9]{2}))$ ]]; then
    echo "Publication date must be RFC3339 with seconds and a timezone: ${published}" >&2
    exit 2
fi

year=$((10#${BASH_REMATCH[1]}))
month=$((10#${BASH_REMATCH[2]}))
day=$((10#${BASH_REMATCH[3]}))
hour=$((10#${BASH_REMATCH[4]}))
minute=$((10#${BASH_REMATCH[5]}))
second=$((10#${BASH_REMATCH[6]}))
offset_hour=0
offset_minute=0
if [[ "${BASH_REMATCH[7]}" != Z ]]; then
    offset_hour=$((10#${BASH_REMATCH[8]}))
    offset_minute=$((10#${BASH_REMATCH[9]}))
fi

days_in_month=(0 31 28 31 30 31 30 31 31 30 31 30 31)
if (( year > 0 && (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) )); then
    days_in_month[2]=29
fi

if (( year == 0 || month < 1 || month > 12 || day < 1 || day > days_in_month[month] || hour > 23 || minute > 59 || second > 59 || offset_hour > 23 || offset_minute > 59 )); then
    echo "Publication date is not a valid RFC3339 calendar time: ${published}" >&2
    exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
content_root="${ACADEMIC_CONTENT_ROOT:-${repo_root}/content/academic/acad-blog}"

if [[ ! -d "${content_root}" ]]; then
    echo "Academic content root does not exist: ${content_root}" >&2
    exit 1
fi

target_dir="${content_root}/${slug}"
lock_dir="${content_root}/.${slug}.scaffold.lock"
if ! mkdir -- "${lock_dir}" 2>/dev/null; then
    echo "Refusing to scaffold while another creation lock exists: ${lock_dir}" >&2
    exit 1
fi

stage_dir=""
cleanup() {
    if [[ -n "${stage_dir}" && -d "${stage_dir}" ]]; then
        rm -rf -- "${stage_dir}"
    fi
    if [[ -n "${lock_dir}" && -d "${lock_dir}" ]]; then
        rmdir -- "${lock_dir}" 2>/dev/null || true
    fi
}
trap cleanup EXIT HUP INT TERM

if [[ -e "${target_dir}" || -L "${target_dir}" ]]; then
    echo "Refusing to overwrite existing academic bundle or path: ${target_dir}" >&2
    exit 1
fi

stage_dir="$(mktemp -d "${content_root}/.${slug}.tmp.XXXXXX")"

mkdir -p "${stage_dir}/assets/figures" "${stage_dir}/assets/attachments"
printf '' > "${stage_dir}/assets/figures/.gitkeep"
printf '' > "${stage_dir}/assets/attachments/.gitkeep"

{
    printf '%s\n' \
        '---' \
        "title: \"${slug}\"" \
        'academic_bundle: true' \
        'build:' \
        '  list: local' \
        '  publishResources: true' \
        '  render: never' \
        'cascade:' \
        "  - date: ${published}" \
        '    type: acad-blog' \
        '    params:' \
        '      academic_post: true'
    if [[ "${with_cover}" == true ]]; then
        printf '%s\n' '      image: "assets/cover.svg"'
    fi
    printf '%s\n' '---'
} > "${stage_dir}/_index.md"

write_language_page() {
    local language="$1"
    local title="$2"
    local description="$3"
    local image_alt="$4"
    local route_prefix="$5"
    local draft_note="$6"

    mkdir -p "${stage_dir}/${language}"
    {
        printf '%s\n' \
            '---' \
            "title: \"${title}\"" \
            "description: \"${description}\"" \
            'draft: true' \
            "url: ${route_prefix}${slug}/" \
            "academic_lang: ${language}"
        if [[ "${with_cover}" == true ]]; then
            printf 'image_alt: "%s"\n' "${image_alt}"
        fi
        printf '%s\n' \
            'keywords: []' \
            '---' \
            '' \
            "> **${draft_note}**" \
            '' \
            '# TODO' \
            '' \
            'TODO'
    } > "${stage_dir}/${language}/index.md"
}

if [[ "${mode}" == bilingual || "${mode}" == en-only ]]; then
    write_language_page \
        'en' \
        'TODO: English title' \
        'TODO: English abstract.' \
        'TODO: Describe the cover image' \
        '/acad-blog/' \
        'Draft article. Remove `draft: true` after the content and metadata are ready.'
fi

if [[ "${mode}" == bilingual || "${mode}" == zh-only ]]; then
    write_language_page \
        'zh-cn' \
        'TODO：中文标题' \
        'TODO：中文摘要。' \
        'TODO：描述封面图片' \
        '/zh-cn/acad-blog/' \
        '文章草稿。完成正文与元数据后，请删除 `draft: true`。'
fi

if [[ "${with_cover}" == true ]]; then
    cat > "${stage_dir}/assets/cover.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 750" role="img" aria-labelledby="title desc">
  <title id="title">Academic note placeholder cover</title>
  <desc id="desc">Abstract lines and nodes on a neutral background</desc>
  <rect width="1200" height="750" fill="#f3f3f0"/>
  <g fill="none" stroke="#315f9a" stroke-width="8" opacity=".85">
    <path d="M170 520 420 260l210 190 250-250 150 150"/>
    <path d="M170 590h860" opacity=".35"/>
  </g>
  <g fill="#315f9a">
    <circle cx="170" cy="520" r="18"/><circle cx="420" cy="260" r="18"/>
    <circle cx="630" cy="450" r="18"/><circle cx="880" cy="200" r="18"/>
    <circle cx="1030" cy="350" r="18"/>
  </g>
  <text x="170" y="145" fill="#202124" font-family="system-ui, sans-serif" font-size="54">Academic Note</text>
</svg>
EOF
fi

if [[ -e "${target_dir}" || -L "${target_dir}" ]]; then
    echo "Refusing to overwrite academic bundle created concurrently: ${target_dir}" >&2
    exit 1
fi

mv "${stage_dir}" "${target_dir}"
stage_dir=""
rmdir -- "${lock_dir}"
lock_dir=""
trap - EXIT HUP INT TERM

printf 'Created %s academic bundle at %s\n' "${mode}" "${target_dir}"
printf 'Preview drafts with: hugo server -D\n'
