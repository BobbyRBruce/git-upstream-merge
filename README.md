# git-upstream-merge

`git-upstream-merge` exists when you have three repositories to consider:

* **origin**: The forked repository.
* **upstream**: The original repository origin is forked from.
* **local**: A local clone of origin.

It is assumed the local repository has the upstream and origin repositories configured as remotes.
If not, see the section on [Adding "origin" and "upstream" remotes to your local repository](#adding-origin-and-upstream-remotes-to-your-local-repository).

**Motivation**: If you wish to merge changes from the upstream repository into a branch in your local repository, using just git you have to do the following:

```sh
# Go to the branch you wish to update.
git switch <branch>

# [Optional] Pull changes from origin, ensure the local repo is up to date.
git pull origin 

# Fetch the upstream changes.
git fetch upstream

# Merge the upstream changes into the local branch.
git git merge upstream/<branch>

# [Optional] Push the changes to origin repo.
git push
```

Doing this frequently can be tedious.

`git-upstream-merge` automates this process.
With it the above can be done by executing `git-upstream-merge -l -p` within the branch you wish to update in the local repository.

**Note**: By default, the upstream and origin repositories are assumed to be named "upstream" and "origin" in as remotes in your local repository.
`git-upstream-merge` has flags `-u` and `-o` to override this.
For example, `git-upstream-merge -u another-upstream -o another-origin` will use repositories set as "another-upstream" and "another-origin" instead.

## Installation

The "git-upstream-merge.sh" script is a script which can be directly.
`./git-upstream-merge.sh` will execute the script.

If you wish to use `git-upstream-merge` as a day-to-day tool you may wish to install it somewhere in your system's `PATH`.
The install.sh script will do this automatically for you.
It will copy "git-upstream-merge.sh" to "/usr/local/bin/" and renaming it "git-upstream-merge" in the process.

```sh
./install.sh
```

When complete, you should be able to execute `git-upstream-merge` from anywhere in your system.

## Usage

A message on usage will be displayed if you run `git-upstream-merge -h`. The following will be returned:

```txt
./git-upstream-merge.sh is a tool to to update a branch on a local clone of a
forked git repository with its upstream. E.g., upstream A is forked
to origin B, and cloned locally to C. When working on branch X in
local repo C this tool may be used to merge branch X from upstream 
A. 

Options exist to both pull from origin B prior to this operation 
and push to origin B after.

Usage: ./git-upstream-merge.sh [-l] [-p] [-o] [-u]
-l         : Update branch with a pull from origin before the 
             upstream merge.
-p         : Push the merged changes to the remote origin
             repository after merging with the upstream repository.
-o <remote>: The remote forked repository to sync.
             Defaults to "origin".
-u <remote>: The remote upstream repository to sync.
             Defaults to "upstream".
-h         : Display this help message explaining usage.
```

## Adding "origin" and "upstream" remotes to your local repository

In most cases "origin" will be setup as the remote your local repository is cloned from by default.
If this is note the case you may do so with:

```sh
git remote add origin <origin-repo-url>
```

`git-upstream-merge` assumes that you have "upstream" setup as a remote to your local repository.
If not you can do so with:

```sh
git remote add upstream <upstream-repo-url>
```

As mentioned before, while `git-upstream-merge` assumes the remotes are named "origin" and "upstream", you can override this with the `-o` and `-u` flags.
