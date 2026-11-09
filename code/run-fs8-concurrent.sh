#!/bin/bash
# bids-apps/freesurfer#104 under real concurrency: two FreeSurfer 8 participant
# runs started together into one fresh output dir, with the PR's run.py bound
# over the image's. The image's /run.py is identical to the PR's base (52fc53b),
# so the PR's change is the only difference from run-fs8.sh's runs, and there is
# no copy step here: the PR copies fsaverage and lh/rh.EC_average itself.
# Run from the dataset root under `datalad run` (see the Makefile).
#
# usage: code/run-fs8-concurrent.sh <dataset> <subject label> <subject label>
# host needs: singularity/apptainer, FS_LICENSE=<FreeSurfer license file>
export PS4='> '
set -x
set -eu

DATASET="$1"
SUB1="$2"
SUB2="$3"
SIF=containers/images/bids/bids-freesurfer--8.2.0-unstable.sif
RAW=sourcedata/$DATASET
OUT=derivatives/$DATASET/freesurfer-pr104-concurrent
: "${FS_LICENSE:?set FS_LICENSE to a FreeSurfer license file}"

# Scratch for each container's /tmp, outside the dataset.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/fs8-XXXXXXX")"
trap 'case "$TMP" in */fs8-???????) /usr/bin/rm -rf "$TMP" ;; esac' EXIT

if [ -e "$OUT" ]; then echo "$OUT exists" >&2; exit 1; fi
mkdir -p "$OUT" logs

fs8() {
  mkdir "$TMP/$1"
  con-duct run -p "logs/fs8-pr104_${DATASET}_sub-$1_{datetime}_" \
    singularity run --containall \
      -B "$PWD:$PWD" --pwd "$PWD" -B "$TMP/$1:/tmp" \
      -B "$PWD/code/run-pr104.py:/run.py:ro" \
      -B "$FS_LICENSE:/fs-license.txt:ro" \
      "$SIF" "$PWD/$RAW" "$PWD/$OUT" participant \
      --participant_label "$1" \
      --3T false --refine_pial T2 --hires_mode auto \
      --skip_bids_validator --n_cpus 2 --license_file /fs-license.txt
}

# Both start at once, so both reach the copy block of run.py together.
fs8 "$SUB1" & pid1=$!
fs8 "$SUB2" & pid2=$!
rc=0
wait "$pid1" || rc=1
wait "$pid2" || rc=1
exit "$rc"
