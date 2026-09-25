#!/usr/bin/env bash
# Rebuild every PDF from its markdown source, against the current course.yaml.
#
#   bash tools/build-all-documents.sh

set -euo pipefail
cd "$(dirname "$0")/.."

BUILD="/home/abhijith/Documents/Work/Amrita/Teaching&Mentoring/Courses/_toolkit/pdfbuild/build.py"
[ -f "$BUILD" ] || { echo "The ASAI toolkit is not at $BUILD"; exit 1; }

doc() { python3 "$BUILD" doc  "$1" --course course.yaml --out "$2"; }
deck() { python3 "$BUILD" deck "$1" --course course.yaml --out "$2"; }

deck material/deck/src/afternoon.md                          material/deck/build/afternoon.pdf
doc  material/prep-guide/src/afternoon-preparation-guide.md  material/prep-guide/build/afternoon-preparation-guide.pdf
doc  material/activity-guide/src/afternoon-activity-guide.md material/activity-guide/build/afternoon-activity-guide.pdf
doc  material/participant-sheet/src/participant-setup-today.md material/participant-sheet/build/participant-setup-today.pdf
doc  material/handout/src/reading-list.md                    material/handout/build/reading-list.pdf
doc  admin/programme-guide/src/programme-and-participant-guide.md \
     admin/programme-guide/build/programme-and-participant-guide.pdf

echo
echo "All documents rebuilt. Open each one and look at it before sending it anywhere."
