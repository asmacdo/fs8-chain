#!/bin/bash
# Build an fMRIPrep singularity image from a Docker Hub digest into images/.
# Run under `datalad run` (see the Makefile) so the build is recorded and the
# image annexed; a digest, not a tag, because tags like `unstable` move.
#
# usage: code/build-fmriprep-image.sh <sha256:digest> <image name>
export PS4='> '
set -x
set -eu

DIGEST="$1"
NAME="$2"

# Build scratch and layer cache outside the dataset.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/sifbuild-XXXXXXX")"
trap 'case "$TMP" in */sifbuild-???????) /usr/bin/rm -rf "$TMP" ;; esac' EXIT
export SINGULARITY_TMPDIR="$TMP" APPTAINER_TMPDIR="$TMP"
export SINGULARITY_CACHEDIR="$TMP/cache" APPTAINER_CACHEDIR="$TMP/cache"

mkdir -p images logs
con-duct run -p "logs/build_${NAME}_{datetime}_" \
  singularity build "images/$NAME.sif" "docker://nipreps/fmriprep@$DIGEST"
