# git-upstream-sync

`git-upstream-sync` exists when you have three repositories to consider:

* **origin**: The forked repository.
* **upstream**: The original repository origin is forked from.
* **local**: A local clone of origin.

It is assumed the local repository has the upstream and origin repositories configured as remotes.
If not, see the section on [Adding "origin" and "upstream" remotes to your local repository](#adding-origin-and-upstream-remotes-to-your-local-repository).

**Motivation**: If you wish to sync changes from the upstream repository into a branch in your local repository, using just git you have to do the following:

```sh
# Go to the branch you wish to update.
git switch <branch>

# Fetch the upstream changes.
git fetch upstream

# Merge the upstream changes into the local branch.
# Fast-forward only to "sync".
git git merge --ff-only upstream/<branch>

# [Optional] Push the changes to origin repo.
git push
```

Doing this frequently can be tedious.

`git-upstream-sync` automates this process.
With it the above can be done by executing `git-upstream-sync -p` within the branch you wish to update in the local repository.

**Note**: By default, the upstream and origin repositories are assumed to be named "upstream" and "origin" in as remotes in your local repository.
`git-upstream-sync` has flags `-u` and `-o` to override this.
For example, `git-upstream-sync -u another-upstream -o another-origin` will use repositories set as "another-upstream" and "another-origin" instead.

## Installation

The "git-upstream-sync.sh" script is a script which can be directly.
`./git-upstream-sync.sh` will execute the script.

If you wish to use `git-upstream-sync` as a day-to-day tool you may wish to install it somewhere in your system's `PATH`.
The install.sh script will do this automatically for you.
It will copy "git-upstream-sync.sh" to "/usr/local/bin/" and renaming it "git-upstream-sync" in the process.

```sh
./install.sh
```

When complete, you should be able to execute `git-upstream-sync` from anywhere in your system.

## Usage

A message on usage will be displayed if you run `git-upstream-sync -h`. The following will be returned:

```txt
git-upstream-sync.sh is a tool to to sync a branch on a local clone of a
forked git repository with its upstream. E.g., An upstream is forked
    echo  and this fork is cloned locally. A branch X in the local repo can
    echo be updated to be in-sync with branch X on the upstream via a FF
merge.

Options exist to both pull from origin B prior to this operation 
and push to origin B after.

Usage: ./git-upstream-sync.sh [-b] [-l] [-p] [-o] [-u] [-h]
-b         : The name of the branch to sync. If this branch doesn't
             exist it will be created. Defaults to the current
             branch.
-p         : Push the branch to the remote origin repository after
             syncing with the upstream repository.
-o <remote>: The remote forked repository to sync with Defaults to
             "origin".
-u <remote>: The remote upstream repository to sync. Defaults to 
             "upstream".
-h         : Display this help message explaining usage.

Note: This tool only supports fast-forward merges. From upstream to
local and from origin to local.
```

### Working on a feature branch

If you are working on a feature branch, you may wish to rebase or merge changes from the upstream repository into your feature branch.

Let us assume in this example that your feature branch is named `feature` and it was created from the branch `main` in your local repo.
`main` is tracking the branch `main` in the origin repository, and that origin repository from the upstream repository.

```sh
# Go to your feature branch.
git switch feature

# Sync the main branch with the upstream repository.
git-upstream-sync -b main

# Alternatively, if you want your origin repos main branch to be updated with
# the upstream repository, you can do:
# `it-upstream-sync -b main -p``

# Rebase your feature branch on top of the updated main branch.
git rebase main

# Alterative, Merge main into feature.
# `git merge main``

```

## Adding "origin" and "upstream" remotes to your local repository

In most cases "origin" will be setup as the remote your local repository is cloned from by default.
If this is note the case you may do so with:

```sh
git remote add origin <origin-repo-url>
```

`git-upstream-sync` assumes that you have "upstream" setup as a remote to your local repository.
If not you can do so with:

```sh
git remote add upstream <upstream-repo-url>
```

As mentioned before, while `git-upstream-sync` assumes the remotes are named "origin" and "upstream", you can override this with the `-o` and `-u` flags.
