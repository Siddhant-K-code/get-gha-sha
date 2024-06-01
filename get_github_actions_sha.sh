#!/bin/bash
set -euo pipefail

show_help() {
    echo "Usage: $0 <owner>/<repo> [<tag-name>]"
    echo "  Fetches the commit SHA for the specified tag of a GitHub repository."
    echo "  If no tag is specified, fetches the latest release's commit SHA."
}

if [[ "$#" -eq 1 ]] && { [[ "$1" == "help" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; }; then
    show_help
    exit 0
fi

if [[ "$#" -lt 1 ]]; then
    echo -e "Error: Repository name not provided.\n" >&2
    show_help >&2
    exit 1
fi

REPO_NAME="${1}"
GITHUB_API="https://api.github.com/repos/${REPO_NAME}"

if [ -z "${REPO_NAME}" ]; then
    echo "Usage: $0 <owner>/<repo> [<tag-name>]" >&2
    exit 1
fi

TAG_NAME="${2:-}"

# Function to fetch the latest release tag name
fetch_latest_release_tag() {
    curl -s "${GITHUB_API}/releases/latest" | jq -r '.tag_name'
}

# Function to fetch the tag object type
fetch_tag_object_type() {
    local tag_name=$1
    curl -s "${GITHUB_API}/git/ref/tags/${tag_name}" | jq -r '.object.type'
}

# Function to fetch the commit SHA for a tag
fetch_commit_sha_for_tag() {
    local tag_name=$1
    curl -s "${GITHUB_API}/git/ref/tags/${tag_name}" | jq -r '.object.sha'
}

# Function to fetch the commit SHA for an annotated tag
fetch_commit_sha_for_annotated_tag() {
    local tag_sha=$1
    curl -s "${GITHUB_API}/git/tags/${tag_sha}" | jq -r '.object.sha'
}

if [ -z "${TAG_NAME}" ]; then
    TAG_NAME="$(fetch_latest_release_tag)"

    if [ -z "${TAG_NAME}" ]; then
        echo "Failed to fetch the latest release tag name. Check https://github.com/${REPO_NAME}/releases for a valid release name." >&2
        exit 1
    fi
fi

TAG_OBJECT_TYPE="$(fetch_tag_object_type "${TAG_NAME}")"

# If the tag object is a commit, we can just use the SHA directly.
if [ "${TAG_OBJECT_TYPE}" == "commit" ]; then
    COMMIT_SHA="$(fetch_commit_sha_for_tag "${TAG_NAME}")"

    if [ -z "${COMMIT_SHA}" ]; then
        echo "Failed to fetch the commit SHA for tag ${TAG_NAME}." >&2
        exit 1
    fi
else
    TAG_SHA="$(fetch_commit_sha_for_tag "${TAG_NAME}")"

    if [ -z "${TAG_SHA}" ]; then
        echo "Failed to fetch the commit SHA for tag ${TAG_NAME}." >&2
        exit 1
    fi

    COMMIT_SHA="$(fetch_commit_sha_for_annotated_tag "${TAG_SHA}")"

    if [ -z "${COMMIT_SHA}" ]; then
        echo "Failed to fetch the commit SHA for tag ${TAG_NAME}." >&2
        exit 1
    fi
fi

echo "${REPO_NAME}@${COMMIT_SHA} # ${TAG_NAME}"
