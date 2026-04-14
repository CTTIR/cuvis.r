#include "rcuvis.h"

/* Finalizer for measurement handles — needs to be visible from session.c */
void mesu_finalizer(SEXP xp) {
#ifndef CUVIS_STUB
    void *ptr = R_ExternalPtrAddr(xp);
    if (ptr) {
        int handle = (int)(intptr_t)ptr;
        cuvis_measurement_clear_cube(handle);
        int h = handle;
        cuvis_measurement_free(&h);
        R_ClearExternalPtr(xp);
    }
#else
    R_ClearExternalPtr(xp);
#endif
}

SEXP rcuvis_mesu_get_metadata(SEXP mesu_xp) {
#ifndef CUVIS_STUB
    int handle = (int)(intptr_t)rcuvis_get_handle(mesu_xp, cuvis_mesu_tag,
                                                   "measurement");

    cuvis_mesu_metadata_t *md = cuvis_mesu_metadata_allocate();
    if (!md) {
        Rf_error("Failed to allocate measurement metadata");
    }

    int status = cuvis_measurement_get_metadata(handle, md);
    if (status != status_ok) {
        cuvis_mesu_metadata_free(md);
        rcuvis_check_status(status, "cuvis_measurement_get_metadata");
    }

    /* Build an R list with metadata fields */
    SEXP result = PROTECT(Rf_allocVector(VECSXP, 12));
    SEXP names = PROTECT(Rf_allocVector(STRSXP, 12));

    SET_STRING_ELT(names, 0, Rf_mkChar("name"));
    SET_VECTOR_ELT(result, 0, Rf_ScalarString(Rf_mkChar(md->name ? md->name : "")));

    SET_STRING_ELT(names, 1, Rf_mkChar("path"));
    SET_VECTOR_ELT(result, 1, Rf_ScalarString(Rf_mkChar(md->path ? md->path : "")));

    SET_STRING_ELT(names, 2, Rf_mkChar("comment"));
    SET_VECTOR_ELT(result, 2, Rf_ScalarString(Rf_mkChar(md->comment ? md->comment : "")));

    SET_STRING_ELT(names, 3, Rf_mkChar("integration_time"));
    SET_VECTOR_ELT(result, 3, Rf_ScalarReal((double)md->integration_time));

    SET_STRING_ELT(names, 4, Rf_mkChar("averages"));
    SET_VECTOR_ELT(result, 4, Rf_ScalarInteger(md->averages));

    SET_STRING_ELT(names, 5, Rf_mkChar("distance"));
    SET_VECTOR_ELT(result, 5, Rf_ScalarReal(md->distance));

    SET_STRING_ELT(names, 6, Rf_mkChar("serial_number"));
    SET_VECTOR_ELT(result, 6, Rf_ScalarString(
        Rf_mkChar(md->serial_number ? md->serial_number : "")));

    SET_STRING_ELT(names, 7, Rf_mkChar("product_name"));
    SET_VECTOR_ELT(result, 7, Rf_ScalarString(
        Rf_mkChar(md->product_name ? md->product_name : "")));

    SET_STRING_ELT(names, 8, Rf_mkChar("assembly"));
    SET_VECTOR_ELT(result, 8, Rf_ScalarString(
        Rf_mkChar(md->assembly ? md->assembly : "")));

    SET_STRING_ELT(names, 9, Rf_mkChar("processing_mode"));
    SET_VECTOR_ELT(result, 9, Rf_ScalarInteger(md->processing_mode));

    SET_STRING_ELT(names, 10, Rf_mkChar("capture_time"));
    SET_VECTOR_ELT(result, 10, Rf_ScalarReal((double)md->capture_time));

    SET_STRING_ELT(names, 11, Rf_mkChar("measurement_flags"));
    SET_VECTOR_ELT(result, 11, Rf_ScalarInteger(md->measurement_flags));

    Rf_setAttrib(result, R_NamesSymbol, names);
    cuvis_mesu_metadata_free(md);

    UNPROTECT(2);
    return result;
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_mesu_get_data_count(SEXP mesu_xp) {
#ifndef CUVIS_STUB
    int handle = (int)(intptr_t)rcuvis_get_handle(mesu_xp, cuvis_mesu_tag,
                                                   "measurement");
    int count = 0;
    int status = cuvis_measurement_get_data_count(handle, &count);
    rcuvis_check_status(status, "cuvis_measurement_get_data_count");
    return Rf_ScalarInteger(count);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_mesu_get_cube(SEXP mesu_xp) {
#ifndef CUVIS_STUB
    int handle = (int)(intptr_t)rcuvis_get_handle(mesu_xp, cuvis_mesu_tag,
                                                   "measurement");

    /* Get the cube image data using the "cube" key */
    cuvis_imbuffer_t buf;
    memset(&buf, 0, sizeof(buf));
    int status = cuvis_measurement_get_data_image(handle, "cube", &buf);
    rcuvis_check_status(status, "cuvis_measurement_get_data_image(cube)");

    int nrow = buf.height;
    int ncol = buf.width;
    int nbands = buf.channels;

    if (nrow <= 0 || ncol <= 0 || nbands <= 0) {
        Rf_error("Invalid cube dimensions: %d x %d x %d", nrow, ncol, nbands);
    }

    /* Create 3D R array [rows, cols, bands] */
    SEXP dims = PROTECT(Rf_allocVector(INTSXP, 3));
    INTEGER(dims)[0] = nrow;
    INTEGER(dims)[1] = ncol;
    INTEGER(dims)[2] = nbands;

    SEXP arr = PROTECT(Rf_allocArray(REALSXP, dims));
    double *arr_data = REAL(arr);
    R_xlen_t plane_size = (R_xlen_t)nrow * ncol;

    /* Copy data based on format */
    int r, c, b;
    if (buf.format == imbuffer_format_float) {
        float *src = (float *)buf.raw;
        for (b = 0; b < nbands; b++) {
            for (r = 0; r < nrow; r++) {
                for (c = 0; c < ncol; c++) {
                    /* SDK stores [height, width, channels] in row-major */
                    arr_data[r + (R_xlen_t)nrow * c + plane_size * b] =
                        (double)src[(r * ncol + c) * nbands + b];
                }
            }
        }
    } else if (buf.format == imbuffer_format_uint16) {
        unsigned short *src = (unsigned short *)buf.raw;
        for (b = 0; b < nbands; b++) {
            for (r = 0; r < nrow; r++) {
                for (c = 0; c < ncol; c++) {
                    arr_data[r + (R_xlen_t)nrow * c + plane_size * b] =
                        (double)src[(r * ncol + c) * nbands + b];
                }
            }
        }
    } else if (buf.format == imbuffer_format_uint32) {
        unsigned int *src = (unsigned int *)buf.raw;
        for (b = 0; b < nbands; b++) {
            for (r = 0; r < nrow; r++) {
                for (c = 0; c < ncol; c++) {
                    arr_data[r + (R_xlen_t)nrow * c + plane_size * b] =
                        (double)src[(r * ncol + c) * nbands + b];
                }
            }
        }
    } else if (buf.format == imbuffer_format_uint8) {
        unsigned char *src = (unsigned char *)buf.raw;
        for (b = 0; b < nbands; b++) {
            for (r = 0; r < nrow; r++) {
                for (c = 0; c < ncol; c++) {
                    arr_data[r + (R_xlen_t)nrow * c + plane_size * b] =
                        (double)src[(r * ncol + c) * nbands + b];
                }
            }
        }
    } else {
        UNPROTECT(2);
        Rf_error("Unsupported image buffer format: %d", buf.format);
    }

    /* Attach wavelengths as attribute */
    if (buf.wavelength) {
        SEXP wavelengths = PROTECT(Rf_allocVector(REALSXP, nbands));
        for (b = 0; b < nbands; b++) {
            REAL(wavelengths)[b] = (double)buf.wavelength[b];
        }
        Rf_setAttrib(arr, Rf_install("wavelengths"), wavelengths);
        UNPROTECT(1);
    }

    /* Attach dimnames */
    SEXP dimnames = PROTECT(Rf_allocVector(VECSXP, 3));
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);  /* rows */
    SET_VECTOR_ELT(dimnames, 1, R_NilValue);  /* cols */
    SET_VECTOR_ELT(dimnames, 2, R_NilValue);  /* bands */
    Rf_setAttrib(arr, R_DimNamesSymbol, dimnames);

    UNPROTECT(3);  /* dims, arr, dimnames */
    return arr;
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_mesu_deep_copy(SEXP mesu_xp) {
#ifndef CUVIS_STUB
    int handle = (int)(intptr_t)rcuvis_get_handle(mesu_xp, cuvis_mesu_tag,
                                                   "measurement");
    int copy_handle = 0;
    int status = cuvis_measurement_deep_copy(handle, &copy_handle);
    rcuvis_check_status(status, "cuvis_measurement_deep_copy");
    return rcuvis_make_handle((void *)(intptr_t)copy_handle, cuvis_mesu_tag,
                              mesu_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}
