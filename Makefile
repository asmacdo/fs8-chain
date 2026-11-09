# Dev loop for FreeSurfer 8 -> fMRIPrep resampling -> full, run straight (no babs).
#   make venv              pinned tools (code/requirements.txt) in .venv
#   make run-fs8           FS8 on $(DATASET) $(SUBJECT)
#   make image-fmriprep    fetch the fMRIPrep image named below, or build it if new
#   make run-resampling    fMRIPrep --level resampling on $(DATASET) $(SUBJECT), reusing the FS8 recon
#   make run-full          fMRIPrep --level full, reusing the FS8 recon and the resampling output
# e.g. make run-fs8 DATASET=ds002345 SUBJECT=265
# Every run and build is a `datalad run` record.
# Host needs: python3, git, git-annex, singularity/apptainer, FS_LICENSE set,
# TMPDIR on scratch with room (image builds and fMRIPrep workdirs take tens of GB).

# ds000030 sub-10159: T1w only, and c6 holds fMRIPrep's FS7 recon of it.
# ds002345 sub-265: one T1w (sub-mm, so -hires) and one 1 mm T2w (exercises --refine_pial).
DATASET ?= ds000030
SUBJECT ?= 10159
VENV := .venv
DL := PATH=$(CURDIR)/$(VENV)/bin:$$PATH datalad

FS8_SIF := containers/images/bids/bids-freesurfer--8.2.0-unstable.sif
# Per dataset: derivatives/<dataset>/{freesurfer,fmriprep-resampling,fmriprep-full}
FS_DIR := derivatives/$(DATASET)/freesurfer

# fMRIPrep image from a Docker Hub digest (tags like `unstable` move), named
# <tag>-<push date>-<digest prefix> so several builds can sit side by side.
# To try a newer one, bump all four together. Drop old ones with
# `datalad drop images/<name>.sif`; the build record stays.
FMRIPREP_TAG ?= unstable
FMRIPREP_DATE ?= 20261028
FMRIPREP_DIGEST ?= sha256:b6d4843cd137fafc59530c3122867ebbd1e7e9a31a426ac0cb8c15d6f9857228
FMRIPREP_SHORT ?= b6d4843c
FMRIPREP_NAME := fmriprep-$(FMRIPREP_TAG)-$(FMRIPREP_DATE)-$(FMRIPREP_SHORT)
FMRIPREP_SIF := images/$(FMRIPREP_NAME).sif

# Templates the fMRIPrep runs read (subdatasets of sourcedata/templateflow).
TEMPLATES := $(addprefix -i sourcedata/templateflow/tpl-,MNI152NLin2009cAsym MNI152NLin6Asym OASIS30ANTs fsLR fsaverage)

.PHONY: venv preflight run-fs8 run-fs8-concurrent image-fmriprep run-resampling run-full

venv: $(VENV)/.done

# Before any `datalad run`: a failure after it starts leaves its outputs unlocked.
MIN_TMP_GB ?= 50
preflight:
	@test -n "$$FS_LICENSE" && test -f "$$FS_LICENSE" || { echo "set FS_LICENSE to a FreeSurfer license file" >&2; exit 1; }
	@free=$$(df -P -BG "$${TMPDIR:-/tmp}" | awk 'NR==2 {print $$4+0}'); \
	  test "$$free" -ge $(MIN_TMP_GB) || { echo "TMPDIR ($${TMPDIR:-/tmp}) has $${free}G free, need $(MIN_TMP_GB)G; point TMPDIR at scratch" >&2; exit 1; }

$(VENV)/.done: code/requirements.txt
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -q --upgrade pip
	$(VENV)/bin/pip install -q -r code/requirements.txt
	touch $@

run-fs8: venv preflight
	$(DL) run \
	  -m "FreeSurfer 8 on $(DATASET) sub-$(SUBJECT)" \
	  -i sourcedata/$(DATASET)/sub-$(SUBJECT)/anat -i $(FS8_SIF) \
	  -o $(FS_DIR) -o logs \
	  code/run-fs8.sh $(DATASET) $(SUBJECT)

# bids-apps/freesurfer#104 (copy fsaverage + EC_average, not link) with two
# participant runs at once into one output dir, the case it guards against.
SUBJECT2 ?= 10171
run-fs8-concurrent: venv preflight
	$(DL) run \
	  -m "FreeSurfer 8 with bids-apps/freesurfer#104's run.py, $(DATASET) sub-$(SUBJECT) + sub-$(SUBJECT2) at once" \
	  -i sourcedata/$(DATASET)/sub-$(SUBJECT)/anat -i sourcedata/$(DATASET)/sub-$(SUBJECT2)/anat -i $(FS8_SIF) \
	  -o derivatives/$(DATASET)/freesurfer-pr104-concurrent -o logs \
	  code/run-fs8-concurrent.sh $(DATASET) $(SUBJECT) $(SUBJECT2)

# Already recorded in this dataset: fetch it. Otherwise build it.
image-fmriprep: venv preflight
	if git ls-files --error-unmatch $(FMRIPREP_SIF) >/dev/null 2>&1; then \
	  $(DL) get $(FMRIPREP_SIF); \
	else \
	  $(DL) run -m "Build $(FMRIPREP_NAME).sif from nipreps/fmriprep@$(FMRIPREP_DIGEST)" \
	    -o $(FMRIPREP_SIF) -o logs \
	    code/build-fmriprep-image.sh $(FMRIPREP_DIGEST) $(FMRIPREP_NAME); \
	fi

run-resampling: preflight image-fmriprep
	$(DL) run \
	  -m "fMRIPrep $(FMRIPREP_NAME) --level resampling on $(DATASET) sub-$(SUBJECT), reusing FS8" \
	  -i sourcedata/$(DATASET)/sub-$(SUBJECT) -i $(FS_DIR)/sub-$(SUBJECT) -i $(FS_DIR)/fsaverage -i $(FMRIPREP_SIF) $(TEMPLATES) \
	  -o derivatives/$(DATASET)/fmriprep-resampling -o $(FS_DIR) -o logs \
	  code/run-fmriprep.sh $(FMRIPREP_SIF) resampling $(DATASET) $(SUBJECT) derivatives/$(DATASET)/fmriprep-resampling

# One upstream only (the resampling output, which carries the anat outputs too),
# plus FS8 via --fs-subjects-dir: no multi-derivative clobber.
run-full: preflight image-fmriprep
	$(DL) run \
	  -m "fMRIPrep $(FMRIPREP_NAME) --level full on $(DATASET) sub-$(SUBJECT), reusing FS8 + resampling" \
	  -i sourcedata/$(DATASET)/sub-$(SUBJECT) -i $(FS_DIR)/sub-$(SUBJECT) -i $(FS_DIR)/fsaverage -i derivatives/$(DATASET)/fmriprep-resampling -i $(FMRIPREP_SIF) $(TEMPLATES) \
	  -o derivatives/$(DATASET)/fmriprep-full -o $(FS_DIR) -o logs \
	  code/run-fmriprep.sh $(FMRIPREP_SIF) full $(DATASET) $(SUBJECT) derivatives/$(DATASET)/fmriprep-full derivatives/$(DATASET)/fmriprep-resampling
