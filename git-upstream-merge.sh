#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

usage() { 
    echo "${0} is a tool to to sync a branch on a local clone of a"
    echo "forked git repository with its upstream. E.g., upstream A is forked"
    echo "to origin B, and cloned locally to C. When working on branch X in"
    echo "local repo C this tool may be used to merge branch X from upstream "
    echo "A. "
    echo
    echo "Options exist to both pull from origin B prior to this operation "
    echo "and push to origin B after."
    echo
    echo "Usage: $0 [-l] [-p] [-o] [-u]"
    echo "-l         : Update branch with a pull from origin before the "
    echo "             upstream merge."
    echo "-p         : Push the merged changes to the remote "origin""
    echo "             repository after merging with the upstream repository."
    echo "-o <remote>: The remote forked repository to sync."
    echo "             Defaults to \"origin\"."
    echo "-u <remote>: The remote upstream repository to sync."
    echo "             Defaults to \"upstream\"."
    echo "-h         : Display this help message explaining usage."
}

# Default values. May be overridden by command line options.
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
PULL=0
PUSH=0

# Parse the command line options.
while getopts "l:p:o:u:h" opt; do
    case "${opt}" in
        l)
            PULL=1
            ;;
        p)
            PUSH=1
            ;;
        o)
            ORIGIN_REMOTE="${OPTARG}"
            ;;
        u)
            UPSTREAM_REMOTE="${OPTARG}"
            ;;
        h) 
            usage
            exit 0
            ;;
        *)
            echo "Unknown option '${opt}'"
            echo
            usage
            exit 1
            ;;
    esac
done

# Ensure the current directory is a git repository.
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "The current directory is not a git repository."
    exit 1
fi

# Ensure the current branch is not detached.
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "The current branch is detached."
    exit 1
fi

# Get the current branch name.
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Pull from the origin remote if requested.
if [ "${PULL}" -eq 1 ]; then
    git pull "${ORIGIN_REMOTE}" "${BRANCH}"
fi

# Ensure the upstream remote exists.
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    echo "The upstream remote '${UPSTREAM_REMOTE}' does not exist."
    exit 1
fi

# Fetch the upstream remote.
git fetch "${UPSTREAM_REMOTE}"

# Ensure the upstream branch exists.
if ! git branch -r | grep -q "^ *${UPSTREAM_REMOTE}/${BRANCH}$"; then
    echo "The upstream branch '${UPSTREAM_REMOTE}/${BRANCH}' does not exist."
    exit 1
fi

# Ensure the current branch is clean.
if ! git diff-index --quiet HEAD --; then
    echo "The current branch '${BRANCH}' has uncommitted changes."
    exit 1
fi

# Merge the upstream branch into the current branch.
git merge "${UPSTREAM_REMOTE}/${BRANCH}"

# Push the merged changes to the origin remote if requested.
if [ "${PUSH}" -eq 1 ]; then
    git push "${ORIGIN_REMOTE}" "${BRANCH}"
fi
