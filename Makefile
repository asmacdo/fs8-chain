# Dev loop for FreeSurfer 8 -> fMRIPrep resampling -> full, run straight (no babs).
#   make venv            pinned tools (code/requirements.txt) in .venv
#   make run-fs8         FS8 on $(SUBJECT), as a datalad run record
# Host needs: python3, git, git-annex, singularity/apptainer, FS_LICENSE set.

SUBJECT ?= 10159
VENV := .venv
SIF := containers/images/bids/bids-freesurfer--8.2.0-unstable.sif

.PHONY: venv run-fs8

venv: $(VENV)/.done

$(VENV)/.done: code/requirements.txt
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -q --upgrade pip
	$(VENV)/bin/pip install -q -r code/requirements.txt
	touch $@

run-fs8: venv
	PATH=$(CURDIR)/$(VENV)/bin:$$PATH datalad run \
	  -m "FreeSurfer 8 on sub-$(SUBJECT)" \
	  -i inputs/ds000030/sub-$(SUBJECT)/anat -i $(SIF) \
	  -o outputs/fs8 -o logs \
	  code/run-fs8.sh $(SUBJECT)
