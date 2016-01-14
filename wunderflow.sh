#!/bin/sh
#
# wunderflow - a set of git commands to help you having sane git repositories.
# Created at Wunderkraut and freely inspired by Git-Flow
# (https://github.com/nvie/gitflow)
#

# set this to workaround expr problems in shFlags on freebsd
if uname -s | egrep -iq 'bsd'; then export EXPR_COMPAT=1; fi

# enable debug mode
if [ "$DEBUG" = "yes" ]; then
	set -x
fi

# The sed expression here replaces all backslashes by forward slashes.
# This helps our Windows users, while not bothering our Unix users.
export GITFLOW_DIR=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")

usage() {
	echo "usage: git wunderflow <subcommand>"
	echo
	echo "Available subcommands are:"
	echo "   init      Initialize a new git repo with support for the branching model."
	echo "   feature   Manage your feature branches."
	echo "   release   Manage your release branches."
	echo "   hotfix    Manage your hotfix branches."
	echo "   version   Shows version information."
	echo
	echo "Try 'git wunderflow <subcommand> help' for details."
}

main() {
	if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

	# load common functionality
	#. "$GITFLOW_DIR/gitflow-common"

	# This environmental variable fixes non-POSIX getopt style argument
	# parsing, effectively breaking git-flow subcommand parsing on several
	# Linux platforms.
	export POSIXLY_CORRECT=1

	# sanity checks
	SUBCOMMAND="$1"; shift

	if [ ! -e "$GITFLOW_DIR/git-wunderflow-$SUBCOMMAND" ]; then
		usage
		exit 1
	fi

	# run command
	. "$GITFLOW_DIR/git-wunderflow-$SUBCOMMAND"
	FLAGS_PARENT="git wunderflow $SUBCOMMAND"

	# test if the first argument is a flag (i.e. starts with '-')
	# in that case, we interpret this arg as a flag for the default
	# command
	SUBACTION="default"
	if [ "$1" != "" ] && { ! echo "$1" | grep -q "^-"; } then
		SUBACTION="$1"; shift
	fi
	if ! type "cmd_$SUBACTION" >/dev/null 2>&1; then
		warn "Unknown subcommand: '$SUBACTION'"
		usage
		exit 1
	fi

	# run the specified action
  if [ $SUBACTION != "help" ] && [ $SUBCOMMAND != "init" ] ; then
    init
  fi
  cmd_$SUBACTION "$@"
}

main "$@"
