#!/usr/bin/env bash

set -euo pipefail

output_dir="${1:-public}"
output_dir="${output_dir%/}"
site_url="${SITE_URL:-https://livinfly.github.io}"
site_url="${site_url%/}"

if [[ ! -f "${output_dir}/index.html" \
    || ! -f "${output_dir}/zh-cn/index.html" \
    || ! -f "${output_dir}/life-blog/index.html" \
    || ! -f "${output_dir}/acad-blog/index.html" \
    || ! -f "${output_dir}/zh-cn/acad-blog/index.html" ]]; then
    echo "Expected bilingual academic pages and the life blog under ${output_dir}" >&2
    exit 1
fi

write_redirect() {
    local output_file="$1"
    local target_path="$2"

    mkdir -p "$(dirname "${output_file}")"

    printf '%s\n' \
        '<!doctype html>' \
        '<html lang="en">' \
        '<head>' \
        '  <meta charset="utf-8">' \
        '  <meta name="viewport" content="width=device-width, initial-scale=1">' \
        "  <link rel=\"canonical\" href=\"${site_url}${target_path}\">" \
        "  <meta http-equiv=\"refresh\" content=\"0; url=${target_path}\">" \
        '  <meta name="robots" content="noindex">' \
        '  <title>Redirecting…</title>' \
        '</head>' \
        '<body>' \
        "  <p>This page has moved to <a href=\"${target_path}\">${target_path}</a>.</p>" \
        "  <script>location.replace(\"${target_path}\" + location.search + location.hash)</script>" \
        '</body>' \
        '</html>' > "${output_file}"
}

# Keep the historical root paginator working while the canonical paginator now
# lives under /life-blog/page/N/.
if [[ -d "${output_dir}/life-blog/page" ]]; then
    for source_file in "${output_dir}"/life-blog/page/*/index.html; do
        [[ -f "${source_file}" ]] || continue

        page_number="$(basename "$(dirname "${source_file}")")"
        [[ "${page_number}" =~ ^[0-9]+$ ]] || continue

        write_redirect \
            "${output_dir}/page/${page_number}/index.html" \
            "/life-blog/page/${page_number}/"
    done
fi

# Keep the original page URLs canonical. Matching /life-blog/xxx/ routes use
# lightweight redirects.
while IFS= read -r -d '' source_file; do
    relative_path="${source_file#"${output_dir}/"}"

    case "${relative_path}" in
        index.html|acad-blog/*|academic/*|life-blog/*|page/*|zh-cn/*)
            continue
            ;;
    esac

    target_path="/${relative_path%index.html}"

    target_file="${output_dir}/life-blog/${relative_path}"
    [[ -e "${target_file}" ]] && continue
    write_redirect "${target_file}" "${target_path}"
done < <(find "${output_dir}" -type f -name index.html -print0)
