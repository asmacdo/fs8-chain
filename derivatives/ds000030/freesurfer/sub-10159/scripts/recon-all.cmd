

#---------------------------------
# New invocation of recon-all Thu Nov  5 01:54:08 PM EST 2026 

 mri_convert /data/asmacdo/fs8-chain/.worktrees/v2/sourcedata/ds000030/sub-10159/anat/sub-10159_T1w.nii.gz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig/001.mgz 

#--------------------------------------------
#@# MotionCor Thu Nov  5 01:54:14 PM EST 2026

 cp /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig/001.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/rawavg.mgz 


 mri_info /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/rawavg.mgz 


 mri_convert /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/rawavg.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/transforms/talairach.xfm /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz 


 mri_info /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz 


 mri_synthstrip --threads 2 -i /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz -o /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/synthstrip.mgz 


 mri_synthseg --i /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz --o /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/synthseg.rca.mgz --threads 2 --vol /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/stats/synthseg.vol.csv --keepgeom --addctab --cpu 


 rca-talairach --s sub-10159 --threads 2 


 fs-synthmorph-reg --s sub-10159 --threads 2 --i /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/orig.mgz --test 

#--------------------------------------------
#@# Nu Intensity Correction Thu Nov  5 02:04:40 PM EST 2026

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 --ants-n4 


 mri_add_xform_to_header -c /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Thu Nov  5 02:08:10 PM EST 2026

 mri_normalize -g 1 -seed 1234 -mprage nu.mgz T1.mgz 

#--------------------------------------

#@# MCADura Segmentation Thu Nov  5 02:09:19 PM EST 2026
#--------------------------------------

#@# VSinus Segmentation Thu Nov  5 02:09:37 PM EST 2026

 mri_mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/T1.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/synthstrip.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/brainmask.mgz 

#-------------------------------------
#@# EM Registration Thu Nov  5 02:10:00 PM EST 2026

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /usr/local/freesurfer/8.2.0/average/RB_all_2020-01-02.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Thu Nov  5 02:13:42 PM EST 2026

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /usr/local/freesurfer/8.2.0/average/RB_all_2020-01-02.gca transforms/talairach.lta norm.mgz 

#--------------------------------------

#@# EntoWM Segmentation Thu Nov  5 02:14:34 PM EST 2026
#--------------------------------------
#@# CC Seg Thu Nov  5 02:14:45 PM EST 2026

 seg2cc --s sub-10159 

#--------------------------------------
#@# Merge ASeg Thu Nov  5 02:15:31 PM EST 2026

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Thu Nov  5 02:15:31 PM EST 2026

 mri_normalize -seed 1234 -mprage -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Thu Nov  5 02:17:14 PM EST 2026

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 


 mri_mask -oval 1 -invert brain.finalsurfs.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/mca-dura.mgz brain.finalsurfs.mgz 


 mri_mask -oval 1 -invert brain.finalsurfs.mgz /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/vsinus.mgz brain.finalsurfs.mgz 


 mri_edit_wm_with_aseg -sa-fix-ento-wm entowm.mgz 2 255 255 brain.finalsurfs.mgz brain.finalsurfs.mgz 


 mri_edit_wm_with_aseg -sa-fix-acj aseg.presurf.mgz 255 255 brain.finalsurfs.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Thu Nov  5 02:17:21 PM EST 2026

 AntsDenoiseImageFs -i brain.mgz -o antsdn.brain.mgz 


 mri_segment -wsizemm 13 -mprage antsdn.brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in -fix-ento-wm entowm.mgz 3 255 255 -fix-acj aseg.presurf.mgz 255 255 -fill-seg-wm -fix-scm-ha 1 wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

Fixing entowm in wm.mgz

 mri_edit_wm_with_aseg -sa-fix-ento-wm entowm.mgz 3 255 255 wm.mgz wm.mgz 

Fixing ACJ in wm.mgz

 mri_edit_wm_with_aseg -sa-fix-acj aseg.presurf.mgz 255 255 wm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Thu Nov  5 02:19:16 PM EST 2026

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.presurf.mgz -ctab /usr/local/freesurfer/8.2.0/SubCorticalMassLUT.txt wm.mgz filled.mgz 

 cp filled.mgz filled.auto.mgz
#--------------------------------------------
#@# Tessellate lh Thu Nov  5 02:20:05 PM EST 2026

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Thu Nov  5 02:20:08 PM EST 2026

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Thu Nov  5 02:20:11 PM EST 2026

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Thu Nov  5 02:20:13 PM EST 2026

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Thu Nov  5 02:20:14 PM EST 2026

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Thu Nov  5 02:20:24 PM EST 2026

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Thu Nov  5 02:20:34 PM EST 2026

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Thu Nov  5 02:21:32 PM EST 2026

 mris_sphere -q -p 6 -a 128 -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#@# Fix Topology lh Thu Nov  5 02:22:28 PM EST 2026

 mris_fix_topology -threads 1 -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 -threads 1 sub-10159 lh 

#@# Fix Topology rh Thu Nov  5 02:26:54 PM EST 2026

 mris_fix_topology -threads 1 -mgz -sphere qsphere.nofix -inflated inflated.nofix -orig orig.nofix -out orig.premesh -ga -seed 1234 -threads 1 sub-10159 rh 


 mris_euler_number ../surf/lh.orig.premesh 


 mris_euler_number ../surf/rh.orig.premesh 


 mris_remesh --remesh --iters 3 --input /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.orig.premesh --output /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.orig 


 mris_remesh --remesh --iters 3 --input /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.orig.premesh --output /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm -f ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm -f ../surf/rh.inflated 

#--------------------------------------------
#@# AutoDetGWStats lh Thu Nov  5 02:34:35 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.lh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/lh.orig.premesh
#--------------------------------------------
#@# AutoDetGWStats rh Thu Nov  5 02:34:38 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_autodet_gwstats --o ../surf/autodet.gw.stats.rh.dat --i brain.finalsurfs.mgz --wm wm.mgz --surf ../surf/rh.orig.premesh
#--------------------------------------------
#@# WhitePreAparc lh Thu Nov  5 02:34:41 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --wm wm.mgz --threads 2 --invol brain.finalsurfs.mgz --lh --i ../surf/lh.orig --o ../surf/lh.white.preaparc --white --seg aseg.presurf.mgz --restore-255 --nsmooth 5 --rip-bg-no-annot --rip-bg --rip-bg-lof --restore-255 --outvol mrisps.wpa.mgz
#--------------------------------------------
#@# WhitePreAparc rh Thu Nov  5 02:36:33 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --wm wm.mgz --threads 2 --invol brain.finalsurfs.mgz --rh --i ../surf/rh.orig --o ../surf/rh.white.preaparc --white --seg aseg.presurf.mgz --restore-255 --nsmooth 5 --rip-bg-no-annot --rip-bg --rip-bg-lof --restore-255 --outvol mrisps.wpa.mgz
#--------------------------------------------
#@# CortexLabel lh Thu Nov  5 02:38:22 PM EST 2026
#--------------------------------------------
#@# CortexLabel+HipAmyg lh Thu Nov  5 02:38:39 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mri_label2label --label-cortex ../surf/lh.white.preaparc aseg.presurf.mgz 1 ../label/lh.cortex+hipamyg.label
#--------------------------------------------
#@# CortexLabel rh Thu Nov  5 02:38:49 PM EST 2026
#--------------------------------------------
#@# CortexLabel+HipAmyg rh Thu Nov  5 02:39:05 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mri_label2label --label-cortex ../surf/rh.white.preaparc aseg.presurf.mgz 1 ../label/rh.cortex+hipamyg.label
#--------------------------------------------
#@# Smooth2 lh Thu Nov  5 02:39:15 PM EST 2026

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Thu Nov  5 02:39:17 PM EST 2026

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Thu Nov  5 02:39:19 PM EST 2026

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Thu Nov  5 02:39:29 PM EST 2026

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Thu Nov  5 02:39:38 PM EST 2026

 mris_curvature -w -seed 1234 lh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Thu Nov  5 02:40:12 PM EST 2026

 mris_curvature -w -seed 1234 rh.white.preaparc 


 mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 

#--------------------------------------------
#@# Sphere lh Thu Nov  5 02:40:45 PM EST 2026

 mris_sphere -threads 2 -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Thu Nov  5 02:46:01 PM EST 2026

 mris_sphere -threads 2 -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#@# Surf Reg  Thu Nov  5 02:52:49 PM EST 2026
#--------------------------------------------
#@# Jacobian white lh Thu Nov  5 03:01:53 PM EST 2026

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Thu Nov  5 03:01:54 PM EST 2026

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Thu Nov  5 03:01:54 PM EST 2026

 mrisp_paint -a 5 /usr/local/freesurfer/8.2.0/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Thu Nov  5 03:01:55 PM EST 2026

 mrisp_paint -a 5 /usr/local/freesurfer/8.2.0/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Thu Nov  5 03:01:55 PM EST 2026

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 lh ../surf/lh.sphere.reg /usr/local/freesurfer/8.2.0/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Thu Nov  5 03:02:02 PM EST 2026

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 rh ../surf/rh.sphere.reg /usr/local/freesurfer/8.2.0/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# WhiteSurfs lh Thu Nov  5 03:02:08 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 2 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white.preaparc --o ../surf/lh.white --white --nsmooth 0 --rip-label ../label/lh.cortex.label --rip-bg --rip-surf ../surf/lh.white.preaparc --aparc ../label/lh.aparc.annot --restore-255 --restore-255 --outvol mrisps.white.mgz --rip-bg-lof
#--------------------------------------------
#@# WhiteSurfs rh Thu Nov  5 03:03:48 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 2 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white.preaparc --o ../surf/rh.white --white --nsmooth 0 --rip-label ../label/rh.cortex.label --rip-bg --rip-surf ../surf/rh.white.preaparc --aparc ../label/rh.aparc.annot --restore-255 --restore-255 --outvol mrisps.white.mgz --rip-bg-lof
#--------------------------------------------
#@# T1PialSurf lh Thu Nov  5 03:05:24 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.lh.dat --seg aseg.presurf.mgz --threads 2 --wm wm.mgz --invol brain.finalsurfs.mgz --lh --i ../surf/lh.white --o ../surf/lh.pial.T1 --pial --nsmooth 0 --rip-label ../label/lh.cortex+hipamyg.label --pin-medial-wall ../label/lh.cortex.label --aparc ../label/lh.aparc.annot --repulse-surf ../surf/lh.white --white-surf ../surf/lh.white --restore-255
#--------------------------------------------
#@# T1PialSurf rh Thu Nov  5 03:08:06 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --adgws-in ../surf/autodet.gw.stats.rh.dat --seg aseg.presurf.mgz --threads 2 --wm wm.mgz --invol brain.finalsurfs.mgz --rh --i ../surf/rh.white --o ../surf/rh.pial.T1 --pial --nsmooth 0 --rip-label ../label/rh.cortex+hipamyg.label --pin-medial-wall ../label/rh.cortex.label --aparc ../label/rh.aparc.annot --repulse-surf ../surf/rh.white --white-surf ../surf/rh.white --restore-255
#@# white curv lh Thu Nov  5 03:10:45 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --curv-map ../surf/lh.white 2 10 ../surf/lh.curv
#@# white area lh Thu Nov  5 03:10:46 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --area-map ../surf/lh.white ../surf/lh.area
#@# pial curv lh Thu Nov  5 03:10:47 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --curv-map ../surf/lh.pial 2 10 ../surf/lh.curv.pial
#@# pial area lh Thu Nov  5 03:10:48 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --area-map ../surf/lh.pial ../surf/lh.area.pial
#@# thickness lh Thu Nov  5 03:10:49 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --thickness ../surf/lh.white ../surf/lh.pial 20 5 ../surf/lh.thickness
#@# area and vertex vol lh Thu Nov  5 03:11:09 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
#@# white curv rh Thu Nov  5 03:11:11 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --curv-map ../surf/rh.white 2 10 ../surf/rh.curv
#@# white area rh Thu Nov  5 03:11:12 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --area-map ../surf/rh.white ../surf/rh.area
#@# pial curv rh Thu Nov  5 03:11:13 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --curv-map ../surf/rh.pial 2 10 ../surf/rh.curv.pial
#@# pial area rh Thu Nov  5 03:11:14 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --area-map ../surf/rh.pial ../surf/rh.area.pial
#@# thickness rh Thu Nov  5 03:11:15 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri
mris_place_surface --thickness ../surf/rh.white ../surf/rh.pial 20 5 ../surf/rh.thickness
#@# area and vertex vol rh Thu Nov  5 03:11:34 PM EST 2026
cd /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri

#-----------------------------------------
#@# Curvature Stats lh Thu Nov  5 03:11:36 PM EST 2026

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm sub-10159 lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Thu Nov  5 03:11:37 PM EST 2026

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm sub-10159 rh curv sulc 

#--------------------------------------------
#@# Cortical ribbon mask Thu Nov  5 03:11:39 PM EST 2026

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon --parallel sub-10159 

#-----------------------------------------
#@# Cortical Parc 2 lh Thu Nov  5 03:13:04 PM EST 2026

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 lh ../surf/lh.sphere.reg /usr/local/freesurfer/8.2.0/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Thu Nov  5 03:13:13 PM EST 2026

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 rh ../surf/rh.sphere.reg /usr/local/freesurfer/8.2.0/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 3 lh Thu Nov  5 03:13:22 PM EST 2026

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 lh ../surf/lh.sphere.reg /usr/local/freesurfer/8.2.0/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Thu Nov  5 03:13:28 PM EST 2026

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 sub-10159 rh ../surf/rh.sphere.reg /usr/local/freesurfer/8.2.0/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# WM/GM Contrast lh Thu Nov  5 03:13:35 PM EST 2026

 pctsurfcon --s sub-10159 --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Thu Nov  5 03:13:37 PM EST 2026

 pctsurfcon --s sub-10159 --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Thu Nov  5 03:13:39 PM EST 2026

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# APas-to-ASeg Thu Nov  5 03:13:51 PM EST 2026

 mri_surf2volseg --o aseg.mgz --i aseg.presurf.hypos.mgz --fix-presurf-with-ribbon /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/mri/ribbon.mgz --threads 2 --lh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.cortex.label --lh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.white --lh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.pial --rh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.cortex.label --rh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.white --rh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.pial 


 mri_brainvol_stats --subject sub-10159 

#-----------------------------------------
#@# AParc-to-ASeg aparc Thu Nov  5 03:13:59 PM EST 2026

 mri_surf2volseg --o aparc+aseg.mgz --label-cortex --i aseg.mgz --threads 2 --lh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.aparc.annot 1000 --lh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.cortex.label --lh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.white --lh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.pial --rh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.aparc.annot 2000 --rh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.cortex.label --rh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.white --rh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.a2009s Thu Nov  5 03:15:05 PM EST 2026

 mri_surf2volseg --o aparc.a2009s+aseg.mgz --label-cortex --i aseg.mgz --threads 2 --lh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.aparc.a2009s.annot 11100 --lh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.cortex.label --lh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.white --lh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.pial --rh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.aparc.a2009s.annot 12100 --rh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.cortex.label --rh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.white --rh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.pial 

#-----------------------------------------
#@# AParc-to-ASeg aparc.DKTatlas Thu Nov  5 03:16:11 PM EST 2026

 mri_surf2volseg --o aparc.DKTatlas+aseg.mgz --label-cortex --i aseg.mgz --threads 2 --lh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.aparc.DKTatlas.annot 1000 --lh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.cortex.label --lh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.white --lh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.pial --rh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.aparc.DKTatlas.annot 2000 --rh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.cortex.label --rh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.white --rh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.pial 

#-----------------------------------------
#@# WMParc Thu Nov  5 03:17:19 PM EST 2026

 mri_surf2volseg --o wmparc.mgz --label-wm --i aparc+aseg.mgz --threads 2 --lh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.aparc.annot 3000 --lh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/lh.cortex.label --lh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.white --lh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/lh.pial --rh-annot /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.aparc.annot 4000 --rh-cortex-mask /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/label/rh.cortex.label --rh-white /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.white --rh-pial /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/surf/rh.pial 


 mri_segstats --seed 1234 --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject sub-10159 --surf-wm-vol --ctab /usr/local/freesurfer/8.2.0/WMParcStatsLUT.txt --etiv --stiv /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/stats/synthseg.tiv.dat 

#-----------------------------------------
#@# Parcellation Stats lh Thu Nov  5 03:19:55 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab sub-10159 lh white 


 mris_anatomical_stats -no-th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab sub-10159 lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Thu Nov  5 03:19:58 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab sub-10159 rh white 


 mris_anatomical_stats -no-th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab sub-10159 rh pial 

#-----------------------------------------
#@# Parcellation Stats 2 lh Thu Nov  5 03:20:02 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab sub-10159 lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Thu Nov  5 03:20:04 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab sub-10159 rh white 

#-----------------------------------------
#@# Parcellation Stats 3 lh Thu Nov  5 03:20:05 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab sub-10159 lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Thu Nov  5 03:20:07 PM EST 2026

 mris_anatomical_stats -no-th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab sub-10159 rh white 

#--------------------------------------------
#@# ASeg Stats Thu Nov  5 03:20:09 PM EST 2026

 mri_segstats --seed 1234 --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --stiv /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/sub-10159/stats/synthseg.tiv.dat --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/8.2.0/ASegStatsLUT.txt --subject sub-10159 

#--------------------------------------------
#@# BA_exvivo Labels lh Thu Nov  5 03:21:01 PM EST 2026

 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA1_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA2_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA3a_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA3b_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA4a_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA4p_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA6_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA44_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA45_exvivo.label --trgsubject sub-10159 --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.V1_exvivo.label --trgsubject sub-10159 --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.V2_exvivo.label --trgsubject sub-10159 --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.MT_exvivo.label --trgsubject sub-10159 --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject sub-10159 --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject sub-10159 --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.FG1.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.FG1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.FG2.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.FG2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.FG3.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.FG3.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.FG4.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.FG4.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.hOc1.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.hOc1.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.hOc2.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.hOc2.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.hOc3v.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.hOc3v.mpm.vpnl.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.hOc4v.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./lh.hOc4v.mpm.vpnl.label --hemi lh --regmethod surface 


 mris_label2annot --s sub-10159 --ctab /usr/local/freesurfer/8.2.0/average/colortable_vpnl.txt --hemi lh --a mpm.vpnl --maxstatwinner --noverbose --l lh.FG1.mpm.vpnl.label --l lh.FG2.mpm.vpnl.label --l lh.FG3.mpm.vpnl.label --l lh.FG4.mpm.vpnl.label --l lh.hOc1.mpm.vpnl.label --l lh.hOc2.mpm.vpnl.label --l lh.hOc3v.mpm.vpnl.label --l lh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s sub-10159 --hemi lh --ctab /usr/local/freesurfer/8.2.0/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.perirhinal_exvivo.label --l lh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s sub-10159 --hemi lh --ctab /usr/local/freesurfer/8.2.0/average/colortable_BA_thresh.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -no-th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab sub-10159 lh white 


 mris_anatomical_stats -no-th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab sub-10159 lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Thu Nov  5 03:23:00 PM EST 2026

 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA1_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA2_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA3a_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA3b_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA4a_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA4p_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA6_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA44_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA45_exvivo.label --trgsubject sub-10159 --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.V1_exvivo.label --trgsubject sub-10159 --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.V2_exvivo.label --trgsubject sub-10159 --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.MT_exvivo.label --trgsubject sub-10159 --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject sub-10159 --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject sub-10159 --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.FG1.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.FG1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.FG2.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.FG2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.FG3.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.FG3.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.FG4.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.FG4.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.hOc1.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.hOc1.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.hOc2.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.hOc2.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.hOc3v.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.hOc3v.mpm.vpnl.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.hOc4v.mpm.vpnl.label --trgsubject sub-10159 --trglabel ./rh.hOc4v.mpm.vpnl.label --hemi rh --regmethod surface 


 mris_label2annot --s sub-10159 --ctab /usr/local/freesurfer/8.2.0/average/colortable_vpnl.txt --hemi rh --a mpm.vpnl --maxstatwinner --noverbose --l rh.FG1.mpm.vpnl.label --l rh.FG2.mpm.vpnl.label --l rh.FG3.mpm.vpnl.label --l rh.FG4.mpm.vpnl.label --l rh.hOc1.mpm.vpnl.label --l rh.hOc2.mpm.vpnl.label --l rh.hOc3v.mpm.vpnl.label --l rh.hOc4v.mpm.vpnl.label 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/asmacdo/fs8-chain/.worktrees/v2/derivatives/ds000030/freesurfer/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject sub-10159 --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s sub-10159 --hemi rh --ctab /usr/local/freesurfer/8.2.0/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.perirhinal_exvivo.label --l rh.entorhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s sub-10159 --hemi rh --ctab /usr/local/freesurfer/8.2.0/average/colortable_BA_thresh.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -no-th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab sub-10159 rh white 


 mris_anatomical_stats -no-th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab sub-10159 rh white 

