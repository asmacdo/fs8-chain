#!/bin/bash
# FreeSurfer 8 (bids-apps/freesurfer, ReproNim/containers bids-freesurfer) on
# one subject, straight singularity run, no babs.
# Run from the dataset root under `datalad run` (see the Makefile), so the
# command, inputs and outputs are recorded and `datalad rerun` can replay it.
# Args mirror unity-campaign bids-app-configs/fs8-chain/FreeSurfer-8.2.0.yaml.
#
# usage: code/run-fs8.sh <subject label>
# host needs: singularity/apptainer, FS_LICENSE=<FreeSurfer license file>
export PS4='> '
set -x
set -eu

SUB="$1"
SIF=containers/images/bids/bids-freesurfer--8.2.0-unstable.sif
RAW=inputs/ds000030
OUT=outputs/fs8
: "${FS_LICENSE:?set FS_LICENSE to a FreeSurfer license file}"

# Scratch for the container's /tmp, outside the dataset.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/fs8-XXXXXXX")"
trap 'case "$TMP" in */fs8-???????) /usr/bin/rm -rf "$TMP" ;; esac' EXIT

mkdir -p "$OUT" logs
# The whole dataset is bound so annex symlinks in the subdatasets resolve.
con-duct run -p "logs/fs8_sub-${SUB}_{datetime}_" \
  singularity run --containall \
    -B "$PWD:$PWD" --pwd "$PWD" -B "$TMP:/tmp" \
    -B "$FS_LICENSE:/fs-license.txt:ro" \
    "$SIF" "$PWD/$RAW" "$PWD/$OUT" participant \
    --participant_label "$SUB" \
    --3T false --refine_pial T2 --hires_mode auto \
    --skip_bids_validator --n_cpus 2 --license_file /fs-license.txt
