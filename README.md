# fs8-chain experiments

Dev loop for FreeSurfer 8 → fMRIPrep `--level resampling` → `--level full`, run straight with singularity before it goes into babs.
Tracked in the hub as `fs8-chain`; the babs app configs live in `unity-campaign` (`bids-app-configs/fs8-chain/`).

A datalad dataset, so a later reader can check what actually ran rather than trusting notes:

- `containers/` — ReproNim/containers, pinned by commit; the image used is its `bids-freesurfer` (8.2.0-unstable).
- `inputs/ds000030/` — OpenNeuroDatasets/ds000030, pinned (tag 1.0.0).
- `inputs/templateflow/` — templateflow, pinned; bound read-only, so an undeclared template fails instead of being fetched unpinned.
- `images/` — fMRIPrep images built here from a Docker Hub digest (`make image-fmriprep`), named `fmriprep-<tag>-<push date>-<digest prefix>.sif`; each build is a `datalad run` record. Drop old ones with `datalad drop`.
- `code/` — the run scripts and the pinned tool list (`requirements.txt`).
- `outputs/` — results, each written by a `datalad run` whose record (command, inputs, outputs) is in `git log`.
- `logs/` — con-duct records of each run: resource usage, stdout/stderr, host.

```bash
datalad clone <url> fs8-chain && cd fs8-chain
make venv
export FS_LICENSE=~/license.txt
make run-fs8               # SUBJECT=10159 by default
make run-resampling        # builds or fetches the fMRIPrep image first
```

`make run-fs8` installs and fetches only what the run declares (`datalad run -i`).
Replay a recorded run with `datalad rerun <commit>` (venv on `PATH`, `FS_LICENSE` set).

Host dependencies, deliberately outside the dataset: python3, git, git-annex, singularity/apptainer, a FreeSurfer license (`FS_LICENSE`), and scratch for the container's `/tmp` (`TMPDIR`, default `/tmp`).
Output content lives where it was computed (typhon); what is pushed to GitHub is the record.
