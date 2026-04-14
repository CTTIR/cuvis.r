#include "rcuvis.h"

static void exporter_finalizer(SEXP xp) {
#ifndef CUVIS_STUB
    void *ptr = R_ExternalPtrAddr(xp);
    if (ptr && rcuvis_sdk_alive) {
        CUVIS_EXPORTER handle = (CUVIS_EXPORTER)(intptr_t)ptr;
        cuvis_exporter_free(&handle);
    }
    R_ClearExternalPtr(xp);
#else
    R_ClearExternalPtr(xp);
#endif
}

SEXP rcuvis_exporter_create_envi(SEXP export_dir, SEXP permissive) {
#ifndef CUVIS_STUB
    const char *dir = CHAR(STRING_ELT(export_dir, 0));
    int perm = LOGICAL(permissive)[0];

    struct cuvis_export_general_settings_t ge;
    memset(&ge, 0, sizeof(ge));
    strncpy(ge.export_dir, dir, CUVIS_MAXBUF - 1);
    ge.permissive = perm ? 1 : 0;

    CUVIS_EXPORTER handle = 0;
    int status = cuvis_exporter_create_envi(&handle, ge);
    rcuvis_check_status(status, "cuvis_exporter_create_envi");
    return rcuvis_make_handle((void *)(intptr_t)handle, cuvis_exporter_tag,
                              exporter_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_exporter_create_tiff(SEXP export_dir, SEXP format_int,
                                  SEXP compression_int, SEXP permissive) {
#ifndef CUVIS_STUB
    const char *dir = CHAR(STRING_ELT(export_dir, 0));
    int fmt = INTEGER(format_int)[0];
    int comp = INTEGER(compression_int)[0];
    int perm = LOGICAL(permissive)[0];

    struct cuvis_export_general_settings_t ge;
    memset(&ge, 0, sizeof(ge));
    strncpy(ge.export_dir, dir, CUVIS_MAXBUF - 1);
    ge.permissive = perm ? 1 : 0;

    struct cuvis_export_tiff_settings_t ts;
    memset(&ts, 0, sizeof(ts));
    ts.format = (CUVIS_TIFF_FORMAT)fmt;
    ts.compression_mode = (CUVIS_TIFF_COMPRESSION_MODE)comp;

    CUVIS_EXPORTER handle = 0;
    int status = cuvis_exporter_create_tiff(&handle, ge, ts);
    rcuvis_check_status(status, "cuvis_exporter_create_tiff");
    return rcuvis_make_handle((void *)(intptr_t)handle, cuvis_exporter_tag,
                              exporter_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_exporter_create_cube(SEXP export_dir, SEXP permissive) {
#ifndef CUVIS_STUB
    const char *dir = CHAR(STRING_ELT(export_dir, 0));
    int perm = LOGICAL(permissive)[0];

    struct cuvis_export_general_settings_t ge;
    memset(&ge, 0, sizeof(ge));
    strncpy(ge.export_dir, dir, CUVIS_MAXBUF - 1);
    ge.permissive = perm ? 1 : 0;

    struct cuvis_save_args_t sa;
    memset(&sa, 0, sizeof(sa));
    sa.allow_session_file = 1;
    sa.allow_overwrite = 1;

    CUVIS_EXPORTER handle = 0;
    int status = cuvis_exporter_create_cube(&handle, ge, sa);
    rcuvis_check_status(status, "cuvis_exporter_create_cube");
    return rcuvis_make_handle((void *)(intptr_t)handle, cuvis_exporter_tag,
                              exporter_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_exporter_apply(SEXP exporter_xp, SEXP mesu_xp) {
#ifndef CUVIS_STUB
    CUVIS_EXPORTER exp_handle = (CUVIS_EXPORTER)(intptr_t)rcuvis_get_handle(
        exporter_xp, cuvis_exporter_tag, "exporter");
    CUVIS_MESU mesu_handle = (CUVIS_MESU)(intptr_t)rcuvis_get_handle(
        mesu_xp, cuvis_mesu_tag, "measurement");
    int status = cuvis_exporter_apply(exp_handle, mesu_handle);
    rcuvis_check_status(status, "cuvis_exporter_apply");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}
