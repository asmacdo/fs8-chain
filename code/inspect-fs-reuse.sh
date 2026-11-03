#!/bin/bash
# Read-only: what an fMRIPrep run did with the FreeSurfer 8 recon it was given.
# usage: code/inspect-fs-reuse.sh <subject label> [<run commit>, default HEAD]
set -u
SUB="$1"
REV="${2:-HEAD}"
FS=outputs/fs8

echo "== recon-all steps logged by the subject (a fresh '#@# MotionCor' means a rerun)"
tail -n 5 "$FS/sub-$SUB/scripts/recon-all-status.log"
echo "== fsaverage: still the container link, or a real directory now?"
ls -ld "$FS/fsaverage"
echo "== files under $FS changed by $REV (empty = fMRIPrep wrote nothing there)"
git show --stat --format='%h %s' "$REV" -- "$FS" | tail -n 15
echo "== FreeSurfer mentions in the run's stdout"
grep -i -h -E "recon-all|reconall|fsaverage|subjects_dir" logs/fmriprep-*_sub-"${SUB}"_*_stdout 2>/dev/null | tail -n 15
