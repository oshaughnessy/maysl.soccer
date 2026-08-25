#!/usr/bin/env bash
# Set the season phase in _data/season.yml.
#
#   ./bin/set-phase.sh season      (or: make phase PHASE=season)
#   ./bin/set-phase.sh             shows the current value and the options
#
# This is the field that changes most often -- roughly five times a year -- and
# it drives the home page's status block and call-to-action card. See PHASES.md.
set -euo pipefail
cd "$(dirname "$0")/.."
FILE=_data/season.yml
VALID="signup preseason season wrapup offseason"
CURRENT="$(awk '/^phase:/ {print $2}' "$FILE")"

if [ $# -eq 0 ]; then
  echo "phase is currently: $CURRENT"
  echo "options:$(printf ' %s' $VALID)"
  echo
  echo "usage: make phase PHASE=<one of the above>"
  exit 0
fi

WANT="$1"
case " $VALID " in
  *" $WANT "*) ;;
  *) echo "'$WANT' isn't a phase. Options:$(printf ' %s' $VALID)" >&2; exit 1 ;;
esac

if [ "$WANT" = "$CURRENT" ]; then
  echo "phase is already $WANT -- nothing to do."
  exit 0
fi

# BSD sed (macOS) needs the empty -i argument; GNU sed doesn't accept it.
if sed --version >/dev/null 2>&1; then
  sed -i "s/^phase: .*/phase: $WANT/" "$FILE"
else
  sed -i '' "s/^phase: .*/phase: $WANT/" "$FILE"
fi
echo "phase: $CURRENT -> $WANT"
echo
echo "Reminders for this phase:"
case "$WANT" in
  signup)    echo "  - check the three register: links and the fees block" ;;
  preseason) echo "  - set dates.practices_start"
             echo "  - registration_open: false once rosters lock" ;;
  season)    echo "  - schedules_posted: true once division pages are up"
             echo "  - tag those pages 'tags: <year>-season schedule <div>'" ;;
  wrapup)    echo "  - adult.signups_open drives the winter-league message" ;;
  offseason) echo "  - next fall's game_days -- see the season-rollover skill" ;;
esac
