# Dev loop for FreeSurfer 8 -> fMRIPrep resampling -> full, run straight (no babs).
#   make venv              pinned tools (code/requirements.txt) in .venv
#   make run-fs8           FS8 on $(DATASET) $(SUBJECT)
#   make image-fmriprep    fetch the fMRIPrep image named below, or build it if new
#   make run-resampling    fMRIPrep --level resampling on $(DATASET) $(SUBJECT), reusing outputs/fs8
# e.g. make run-fs8 DATASET=ds002345 SUBJECT=265
# Every run and build is a `datalad run` record.
# Host needs: python3, git, git-annex, singularity/apptainer, FS_LICENSE set.

# ds000030 sub-10159: T1w only, and c6 holds fMRIPrep's FS7 recon of it.
# ds002345 sub-265: one T1w (sub-mm, so -hires) and one 1 mm T2w (exercises --refine_pial).
DATASET ?= ds000030
SUBJECT ?= 10159
VENV := .venv
DL := PATH=$(CURDIR)/$(VENV)/bin:$$PATH datalad

FS8_SIF := containers/images/bids/bids-freesurfer--8.2.0-unstable.sif

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

# Templates the fMRIPrep runs read (subdatasets of inputs/templateflow).
TEMPLATES := $(addprefix -i inputs/templateflow/tpl-,MNI152NLin2009cAsym MNI152NLin6Asym OASIS30ANTs fsLR fsaverage)

.PHONY: venv run-fs8 image-fmriprep run-resampling

venv: $(VENV)/.done

$(VENV)/.done: code/requirements.txt
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -q --upgrade pip
	$(VENV)/bin/pip install -q -r code/requirements.txt
	touch $@

run-fs8: venv
	$(DL) run \
	  -m "FreeSurfer 8 on $(DATASET) sub-$(SUBJECT)" \
	  -i inputs/$(DATASET)/sub-$(SUBJECT)/anat -i $(FS8_SIF) \
	  -o outputs/fs8 -o logs \
	  code/run-fs8.sh $(DATASET) $(SUBJECT)

# Already recorded in this dataset: fetch it. Otherwise build it.
image-fmriprep: venv
	if git ls-files --error-unmatch $(FMRIPREP_SIF) >/dev/null 2>&1; then \
	  $(DL) get $(FMRIPREP_SIF); \
	else \
	  $(DL) run -m "Build $(FMRIPREP_NAME).sif from nipreps/fmriprep@$(FMRIPREP_DIGEST)" \
	    -o $(FMRIPREP_SIF) -o logs \
	    code/build-fmriprep-image.sh $(FMRIPREP_DIGEST) $(FMRIPREP_NAME); \
	fi

run-resampling: image-fmriprep
	$(DL) run \
	  -m "fMRIPrep $(FMRIPREP_NAME) --level resampling on $(DATASET) sub-$(SUBJECT), reusing FS8" \
	  -i inputs/$(DATASET)/sub-$(SUBJECT) -i outputs/fs8/sub-$(SUBJECT) -i $(FMRIPREP_SIF) $(TEMPLATES) \
	  -o outputs/fmriprep-resampling-$(DATASET) -o outputs/fs8 -o logs \
	  code/run-fmriprep.sh $(FMRIPREP_SIF) resampling $(DATASET) $(SUBJECT) outputs/fmriprep-resampling-$(DATASET)
