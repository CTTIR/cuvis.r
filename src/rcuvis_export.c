#include "rcuvis.h"

#ifndef CUVIS_STUB
static const char *export_directory(SEXP value) {
    rcuvis_require_alive();
    const char *dir = rcuvis_string(value, "export_dir");
    if (strlen(dir) >= CUVIS_MAXBUF) {
        Rf_error("Export directory exceeds the SDK path limit; it will not be truncated");
    }
    return dir;
}
#endif

/* Only referenced by SDK builds; omitted from stub builds to avoid an
   unused-function warning. */
#ifndef CUVIS_STUB
static void exporter_finalizer(SEXP xp) {
    void *ptr = R_ExternalPtrAddr(xp);
    if (ptr && rcuvis_sdk_alive) {
        CUVIS_EXPORTER handle = (CUVIS_EXPORTER)(intptr_t)ptr;
        cuvis_exporter_free(&handle);
    }
    R_ClearExternalPtr(xp);
}
#endif

SEXP rcuvis_exporter_create_envi(SEXP export_dir, SEXP permissive) {
#ifndef CUVIS_STUB
    const char *dir = export_directory(export_dir);
    int perm = rcuvis_logical(permissive, "permissive");

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
    const char *dir = export_directory(export_dir);
    int fmt = rcuvis_integer(format_int, "format");
    int comp = rcuvis_integer(compression_int, "compression");
    int perm = rcuvis_logical(permissive, "permissive");

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

SEXP rcuvis_exporter_create_cube(SEXP export_dir, SEXP permissive, SEXP overwrite) {
#ifndef CUVIS_STUB
    const char *dir = export_directory(export_dir);
    int perm = rcuvis_logical(permissive, "permissive");
    int replace = rcuvis_logical(overwrite, "overwrite");

    struct cuvis_export_general_settings_t ge;
    memset(&ge, 0, sizeof(ge));
    strncpy(ge.export_dir, dir, CUVIS_MAXBUF - 1);
    ge.permissive = perm ? 1 : 0;

    struct cuvis_save_args_t sa;
    memset(&sa, 0, sizeof(sa));
    /* Each public export submits one measurement. A zero-capacity SDK queue
       can block with dropping disabled; reserve one slot and flush it. */
    sa.hard_limit = 1;
    sa.soft_limit = 1;
    sa.allow_drop = 0;
    sa.allow_session_file = 1;
    sa.allow_overwrite = replace;

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
    status = cuvis_exporter_flush(exp_handle);
    rcuvis_check_status(status, "cuvis_exporter_flush");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}

SEXP rcuvis_exporter_close(SEXP exporter_xp) {
#ifndef CUVIS_STUB
    if (TYPEOF(exporter_xp) != EXTPTRSXP ||
        R_ExternalPtrTag(exporter_xp) != cuvis_exporter_tag) {
        Rf_error("Expected an exporter handle");
    }
    if (!R_ExternalPtrAddr(exporter_xp)) return R_NilValue;
    CUVIS_EXPORTER handle = (CUVIS_EXPORTER)(intptr_t)rcuvis_get_handle(
        exporter_xp, cuvis_exporter_tag, "exporter");
    int status = cuvis_exporter_free(&handle);
    if (status == status_ok) R_ClearExternalPtr(exporter_xp);
    rcuvis_check_status(status, "cuvis_exporter_free");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}
