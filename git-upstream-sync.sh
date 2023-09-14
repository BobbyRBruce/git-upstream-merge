#!/usr/bin/env sh
# Copyright (c) 2023 Bobby R. Bruce
# SPDX-License-Identifier: MIT

usage() { 
    echo "${0} is a tool to to sync a branch on a local clone of a"
    echo "forked git repository with its upstream. E.g., An upstream is forked
    echo " and this fork is cloned locally. A branch X in the local repo can"
    echo "be updated to be in-sync with branch X on the upstream via a FF
    echo "merge."
    echo
    echo "Options exist to both pull from origin B prior to this operation "
    echo "and push to origin B after."
    echo
    echo "Usage: $0 [-b] [-l] [-p] [-o] [-u] [-h]"
    echo "-b         : The name of the branch to sync. If this branch doesn't"
    echo "             exist it will be created. Defaults to the current"
    echo "             branch."
    echo "-p         : Push the branch to the remote origin repository after"
    echo "             syncing with the upstream repository."
    echo "-o <remote>: The remote forked repository to sync with Defaults to"
    echo "             \"origin\"."
    echo "-u <remote>: The remote upstream repository to sync. Defaults to "
    echo "             \"upstream\"."
    echo "-h         : Display this help message explaining usage."
    echo
    echo "Note: This tool only supports fast-forward merges. From upstream to"
    echo "local and from origin to local."
}

# Default values. May be overridden by command line options.
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
BRANCH="NOT SET"
TO_RETURN_BRANCH=0
PUSH=0

# Parse the command line options.
while getopts "b:po:u:h" opt; do
    case "${opt}" in
        b)
            BRANCH="${OPTARG}"
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

# Ensure the current branch is clean.
if ! git diff-index --quiet HEAD --; then
    echo "The current branch has uncommitted changes."
    exit 1
fi

# Regardless as to whether we are using the current branch or a specified
# branch, we have ensured we can safely checkout another branch or merge into
# the current branch.

# If no branch was specified, use the current branch.
if [ "${BRANCH}" == "NOT SET" ]; then
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    TO_RETURN_BRANCH="${BRANCH}"
fi

TO_RETURN_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

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

# Ensure the BRANCH exists in the local repository.
# If it doesn't create it and check it out.
# If it does exist, check it out.
if ! git branch | grep -q "^.* ${BRANCH}$"; then
   git switch -q -c "${BRANCH}"
else
    git switch -q "${BRANCH}"
fi

# Merge the upstream branch into the current branch.
git merge --ff-only "${UPSTREAM_REMOTE}/${BRANCH}"
if [ $? -ne 0 ]; then
    echo "Failed to FF merge upstream into '${BRANCH}'."
    echo "This may be due to merge conflicts. To resolve these:"
    echo "'git switch ${BRANCH} && git merge ${UPSTREAM_REMOTE}/${BRANCH}'"
    if [ "${PUSH}" -eq 1 ]; then
        echo "Push to remote origin cancelled."
    fi
    exit 1
fi

# Push the merged changes to the origin remote if requested.
if [ "${PUSH}" -eq 1 ]; then
    git push "${ORIGIN_REMOTE}" "${BRANCH}"
    if [ $? -ne 0 ]; then
        echo "Failed to push '${BRANCH}' to origin."
        git switch -q "${TO_RETURN_BRANCH}"
        exit 1
    fi
fi

git switch -q "${TO_RETURN_BRANCH}"
