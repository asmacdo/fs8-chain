#!/bin/bash
# fMRIPrep on one subject, reusing the FreeSurfer 8 recon in outputs/fs8,
# straight singularity run, no babs. Run under `datalad run` (see the Makefile).
# Flags follow unity-campaign bids-app-configs/fMRIPrep-25.2.5+full.yaml,
# except --level, the scheduler-sized resources, and the FreeSurfer reuse.
#
# usage: code/run-fmriprep.sh <image path> <level> <dataset> <subject label> <output dir>
# host needs: singularity/apptainer, FS_LICENSE=<FreeSurfer license file>
export PS4='> '
set -x
set -eu

SIF="$1"
LEVEL="$2"
DATASET="$3"
SUB="$4"
OUT="$5"
RAW=inputs/$DATASET
: "${FS_LICENSE:?set FS_LICENSE to a FreeSurfer license file}"

# Scratch for the container's /tmp (the nipype workdir goes there; a short path,
# con/mechababs#150), outside the dataset.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/fmriprep-XXXXXXX")"
trap 'case "$TMP" in */fmriprep-???????) /usr/bin/rm -rf "$TMP" ;; esac' EXIT

mkdir -p "$OUT" logs
# The whole dataset is bound so annex symlinks resolve. templateflow is a pinned
# subdataset, bound read-only: a template the run needs but did not declare
# fails loudly instead of being fetched unpinned from S3.
# outputs/fs8 is the --fs-subjects-dir and is declared an output of the run, so
# anything fMRIPrep writes there shows up in the run's commit.
con-duct run -p "logs/fmriprep-${LEVEL}_${DATASET}_sub-${SUB}_{datetime}_" \
  singularity run --containall \
    -B "$PWD:$PWD" --pwd "$PWD" -B "$TMP:/tmp" \
    -B "$PWD/inputs/templateflow:$PWD/inputs/templateflow:ro" \
    --env "TEMPLATEFLOW_HOME=$PWD/inputs/templateflow" \
    -B "$FS_LICENSE:/fs-license.txt:ro" \
    "$SIF" "$PWD/$RAW" "$PWD/$OUT" participant \
    --participant-label "$SUB" \
    --bids-filter-file "$PWD/code/bids-filter-$DATASET.json" \
    --fs-subjects-dir "$PWD/outputs/fs8" \
    --fs-license-file /fs-license.txt \
    -w /tmp/wkdir \
    --level "$LEVEL" \
    --output-spaces MNI152NLin2009cAsym:res-2:res-native MNI152NLin6Asym:res-2:res-native fsaverage \
    --cifti-output 91k \
    --random-seed 12345 --skull-strip-fixed-seed --skull-strip-t1w force \
    --use-syn-sdc warn --me-output-echos \
    --notrack --md-only-boilerplate --skip-bids-validation --stop-on-first-crash \
    --nprocs 8 --omp-nthreads 8 --mem-mb 32000
