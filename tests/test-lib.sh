#!/bin/false
#
# This helper library should be sourced at the beginning of unit test scripts,
# not executed.
#
# It creates a temporary directory, sets it up for automatic removal, and
# changes to that directory. This way, each unit test may make a mess in its
# working directory and not worry about cleanup.
#
set -e

unset HOME
unset XDG_CONFIG_HOME
unset CDPATH
unset GREP_OPTIONS
unset UNZIP

case "$(uname -s)" in
	"Darwin")
		canonicalize() {
			python -c 'import sys,os;print(os.path.realpath(sys.argv[1]))' "$1"
		}
		;;
	*)	canonicalize() { readlink -f "$1"; } ;;
esac

cd "$(mktemp -d "${TMPDIR:-/tmp}"/tmp.XXXXXXXXXX)"
export TRASH_DIRECTORY="$(pwd -P)"
[ "$DEBUG" ] || trap "rm -rf '$TRASH_DIRECTORY'" EXIT
trap
export HOME="$TRASH_DIRECTORY"

[ "$DEBUG" ] && set -x
