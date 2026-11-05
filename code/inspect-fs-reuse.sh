#!/bin/bash
# Read-only: what an fMRIPrep run did with the FreeSurfer 8 recon it was given.
# usage: code/inspect-fs-reuse.sh <dataset> <subject label> [<run commit>]
# The run commit defaults to the last `datalad run` record, not HEAD, which may
# be a merge or a hand commit.
set -u
DATASET="$1"
SUB="$2"
REV="${3:-$(git log -1 --format=%h --grep='^\[DATALAD RUNCMD\]')}"
FS=derivatives/$DATASET/freesurfer

echo "== recon-all steps logged by the subject (a fresh '#@# MotionCor' means a rerun)"
tail -n 5 "$FS/sub-$SUB/scripts/recon-all-status.log"
echo "== fsaverage: a real directory (copied by the FS8 run), not a link into the container?"
ls -ld "$FS/fsaverage"
echo "== files under $FS changed by $REV: $(git log -1 --format=%s "$REV")"
echo "   (expected: lh/rh.midthickness at resampling, nothing at full)"
git show --stat=200 --format= "$REV" -- "$FS"
echo "== FreeSurfer mentions in the fMRIPrep runs' stdout for $DATASET sub-$SUB"
grep -i -h -E "recon-all|reconall|fsaverage|subjects_dir" logs/fmriprep-*_"${DATASET}"_sub-"${SUB}"_*_stdout 2>/dev/null
