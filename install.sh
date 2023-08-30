#!/bin/env sh
# SPDX-License-Identifier: MIT

# Elevate privileges if necessary.
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Install git-upstream-merge.sh to /usr/local/bin/git-upstream-merge.
install -m 755 git-upstream-merge.sh /usr/local/bin 
status=$?

# If success.
if [ $status -eq 0 ]; then
    echo "Installed to /usr/local/bin/git-upstream-merge."
    echo "If /usr/local/bin is in your PATH, you can run git-upstream-merge."
    exit 0
fi

# If failure.
echo "Failed to install /usr/local/bin/git-upstream-merge." 2>&1
echo "You can install this manually by moving git-upstream-merge.sh to a" 2>&1
echo "location in your system's PATH." 2>&1
exit ${status}
