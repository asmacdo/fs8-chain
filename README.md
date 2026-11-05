# fs8-chain experiments

Dev loop for FreeSurfer 8 → fMRIPrep `--level resampling` → `--level full`, run straight with singularity before it goes into babs.
Tracked in the hub as `fs8-chain`; the babs app configs live in `unity-campaign` (`bids-app-configs/fs8-chain/`).

A datalad dataset, so a later reader can check what actually ran rather than trusting notes:

- `containers/` — ReproNim/containers, pinned by commit; the image used is its `bids-freesurfer` (8.2.0-unstable).
- `inputs/ds000030/`, `inputs/ds002345/` — OpenNeuroDatasets, pinned (tags 1.0.0, 1.1.4); pick with `DATASET=`/`SUBJECT=`.
- `inputs/templateflow/` — templateflow, pinned; bound read-only, so an undeclared template fails instead of being fetched unpinned.
- `images/` — fMRIPrep images built here from a Docker Hub digest (`make image-fmriprep`), named `fmriprep-<tag>-<push date>-<digest prefix>.sif`; each build is a `datalad run` record. Drop old ones with `datalad drop`.
- `code/` — the run scripts, the pinned tool list (`requirements.txt`), and `inspect-fs-reuse.sh` (read-only: what an fMRIPrep run did to the FreeSurfer dir).
- `outputs/<dataset>/` — results per dataset: `freesurfer/` (the FS8 subjects dir), `fmriprep-resampling/`, `fmriprep-full/`. Each is written by a `datalad run` whose record (command, inputs, outputs) is in `git log`.
  The FS8 run replaces the bids-app's links into its container (`fsaverage`, `lh/rh.EC_average`; bids-apps/freesurfer#103) with copies from the same image. fMRIPrep, run with `--fs-no-resume`, adds only `lh/rh.midthickness` to `freesurfer/`.
- `logs/` — con-duct records of each run: resource usage, stdout/stderr, host.

```bash
datalad clone <url> fs8-chain && cd fs8-chain
make venv
export FS_LICENSE=~/license.txt
make run-fs8               # DATASET=ds000030 SUBJECT=10159 by default
make run-resampling        # builds or fetches the fMRIPrep image first
make run-full
make run-fs8 run-resampling run-full DATASET=ds002345 SUBJECT=265
```

`make run-fs8` installs and fetches only what the run declares (`datalad run -i`).
Replay a recorded run with `datalad rerun <commit>` (venv on `PATH`, `FS_LICENSE` set), or the whole chain with `datalad rerun --since <the branch's clean-slate commit>`.
The runs on `main` predate this layout and had the container links removed by hand outside `datalad run`; look at them there, don't rerun them.

Host dependencies, deliberately outside the dataset: python3, git, git-annex, singularity/apptainer, a FreeSurfer license (`FS_LICENSE`), and scratch for the container's `/tmp` (`TMPDIR`, default `/tmp`).
Output content lives where it was computed (typhon); what is pushed to GitHub is the record.
