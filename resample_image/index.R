## ----setup, include=FALSE-----------------------------------------------------
library(RNifti)
library(neurobase)
library(ANTsRCore)
library(fslr)
library(extrantsr)
library(kirby21.t1)
knitr::opts_chunk$set(echo = TRUE, cache = FALSE, comment = "")


## ----files--------------------------------------------------------------------
fname = kirby21.t1::get_t1_filenames()[1]
if (file.exists(fname)) {
  oro_img = readnii(fname)
  print(oro_img)
  rnif_img = readNifti(fname)
  print(rnif_img)
  ants_img = antsImageRead(fname)
  print(ants_img)
}


## ----asNifti_check------------------------------------------------------------
asNifti(oro_img)
all(asNifti(oro_img) == rnif_img)


## ----nii2oro_check------------------------------------------------------------
nii2oro(rnif_img)
all(oro_img == nii2oro(rnif_img))


## ----scl_slope----------------------------------------------------------------
scl_slope(oro_img)
scl_slope(nii2oro(rnif_img))


## ----ants2oro-----------------------------------------------------------------
ants2oro(ants_img)


## ----ants2oro_ref-------------------------------------------------------------
ants2oro(ants_img, reference = oro_img)


## ----ants2oro+time------------------------------------------------------------
system.time(ants2oro(ants_img))
system.time(ants2oro(ants_img, reference = oro_img))


## ----oro2ants-----------------------------------------------------------------
oro2ants(oro_img)


## ----turn_ants----------------------------------------------------------------
as.antsImage(oro_img)


## ----check_fail, error = TRUE-------------------------------------------------
as.antsImage(oro_img) == ants_img


## ----quickcheck---------------------------------------------------------------
all(as.array(as.antsImage(oro_img, reference = ants_img) == ants_img) == 1)


## ----rnifti2ants--------------------------------------------------------------
oro2ants(oro_img)


## ----ants2rnifti, error = TRUE------------------------------------------------
as.antsImage(rnif_img)


## ----show_pixdim--------------------------------------------------------------
oro_img@pixdim[2:4]


## ----fslresample, cache=TRUE--------------------------------------------------
res = fsl_resample(file = fname, voxel_size = 1)
res
oro_res = fsl_resample(oro_img, voxel_size = 1)
all.equal(res, oro_res)
res@pixdim[2:4]


## ----rescale_rnif-------------------------------------------------------------
niftiHeader(rnif_img)$pixdim[2:4]
RNiftyReg::rescale(rnif_img, c(2,1.5,1))


## ----rescale_ratio------------------------------------------------------------
RNiftyReg::rescale(rnif_img, c(1.2,1,1))


## ----pdim_to_vox--------------------------------------------------------------
pdim = niftiHeader(rnif_img)$pixdim[2:4]
RNiftyReg::rescale(rnif_img, pdim / c(2.5, 2.5, 2.5))


## ----rescale2_func------------------------------------------------------------
rescale2 = function(img, voxel_size = c(1,1,1), ...) {
  pdim = niftiHeader(rnif_img)$pixdim[2:4]
  scales = pdim / voxel_size
  RNiftyReg::rescale(img, scales = scales, ...)
}
rescale2(rnif_img, c(2.5, 2.3, 3))


## ----rescale2-----------------------------------------------------------------
rescale2(oro_img, c(2.5, 2.3, 3))


## ----niirescale2--------------------------------------------------------------
nii2oro(rescale2(oro_img, c(2.5, 2.3, 3)))


## ----diff_interp, cache=TRUE--------------------------------------------------
interp0 = nii2oro(rescale2(oro_img, c(2.5, 2.3, 3), interpolation = 0L))
interp3 = nii2oro(rescale2(oro_img, c(2.5, 2.3, 3), interpolation = 3L))
double_ortho(interp0, interp3)


## -----------------------------------------------------------------------------
resampleImage(ants_img, resampleParams = c(1, 1, 1))
resampleImage(ants_img, resampleParams = c(1, 1, 1), useVoxels = TRUE)
resampleImage(ants_img, resampleParams = c(150, 200, 200), useVoxels = TRUE)


## -----------------------------------------------------------------------------
resample_image(oro_img, parameters = c(1, 1, 1))
resample_image(ants_img, parameters = c(1, 1, 1))


## -----------------------------------------------------------------------------
resample_image(ants_img, parameters = c(2.5, 2.3, 1))


## -----------------------------------------------------------------------------
resample_image(ants_img, parameters = c(150, 200, 200), parameter_type = "voxels")


## -----------------------------------------------------------------------------
formals(resample_image)$interpolator
formals(resampleImage)$interpType


## -----------------------------------------------------------------------------
interp0 = resample_image(ants_img, parameters = c(2.5, 2.3, 3), interpolator = "nearestneighbor")
interp3 = resample_image(ants_img, parameters = c(2.5, 2.3, 3), interpolator = "bspline")
double_ortho(interp0, interp3)
ortho2(interp0, interp3 - interp0, col.y = scales::alpha(hotmetal(), 0.5))


## ---- cache = FALSE-----------------------------------------------------------
devtools::session_info()

