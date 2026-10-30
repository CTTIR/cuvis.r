#include "rcuvis.h"

/* Tag symbols */
SEXP cuvis_session_tag;
SEXP cuvis_mesu_tag;
SEXP cuvis_proc_tag;
SEXP cuvis_exporter_tag;

/* SDK state: 1 if initialized, 0 if shut down. Finalizers check this. */
int rcuvis_sdk_alive = 0;
#ifndef CUVIS_STUB
static int rcuvis_sdk_started = 0;
#endif

/* ---- Utility functions ---- */

void rcuvis_require_alive(void) {
    if (!rcuvis_sdk_alive) {
        Rf_error("CUVIS SDK is not initialized or has been shut down. "
                 "Initialize it once; after shutdown restart R.");
    }
}

const char *rcuvis_string(SEXP value, const char *name) {
    if (TYPEOF(value) != STRSXP || XLENGTH(value) != 1 ||
        STRING_ELT(value, 0) == NA_STRING || LENGTH(STRING_ELT(value, 0)) == 0) {
        Rf_error("%s must be one nonempty string", name);
    }
    return Rf_translateCharUTF8(STRING_ELT(value, 0));
}

int rcuvis_integer(SEXP value, const char *name) {
    if (TYPEOF(value) != INTSXP || XLENGTH(value) != 1 || INTEGER(value)[0] == NA_INTEGER) {
        Rf_error("%s must be one non-missing integer", name);
    }
    return INTEGER(value)[0];
}

int rcuvis_logical(SEXP value, const char *name) {
    if (TYPEOF(value) != LGLSXP || XLENGTH(value) != 1 || LOGICAL(value)[0] == NA_LOGICAL) {
        Rf_error("%s must be TRUE or FALSE", name);
    }
    return LOGICAL(value)[0];
}

SEXP rcuvis_make_handle(void *ptr, SEXP tag, R_CFinalizer_t finalizer) {
    if (!ptr) Rf_error("CUVIS SDK returned an empty handle");
    SEXP xp = PROTECT(R_MakeExternalPtr(ptr, tag, R_NilValue));
    if (finalizer) {
        R_RegisterCFinalizerEx(xp, finalizer, TRUE);
    }
    UNPROTECT(1);
    return xp;
}

void *rcuvis_get_handle(SEXP xp, SEXP expected_tag, const char *type_name) {
    if (TYPEOF(xp) != EXTPTRSXP) {
        Rf_error("Expected an external pointer for %s handle", type_name);
    }
    if (R_ExternalPtrTag(xp) != expected_tag) {
        Rf_error("Expected a %s handle", type_name);
    }
    rcuvis_require_alive();
    void *ptr = R_ExternalPtrAddr(xp);
    if (!ptr) {
        Rf_error("%s handle has been freed or is invalid", type_name);
    }
    return ptr;
}

void rcuvis_check_status(int status, const char *context) {
#ifndef CUVIS_STUB
    if (status != status_ok) {
        const char *msg = cuvis_get_last_error_msg();
        if (msg && strlen(msg) > 0) {
            Rf_error("CUVIS SDK error in %s: %s", context, msg);
        } else {
            Rf_error("CUVIS SDK error in %s (status code: %d)", context, status);
        }
    }
#else
    (void)status;
    (void)context;
#endif
}

/* ---- Init / shutdown / version ---- */

SEXP rcuvis_init(SEXP settings_dir) {
#ifndef CUVIS_STUB
    if (rcuvis_sdk_started) {
        Rf_error("CUVIS initialization is allowed only once per R process. Restart R.");
    }
    const char *dir = rcuvis_string(settings_dir, "settings_dir");
    int status = cuvis_init(dir, loglevel_info, NULL);
    rcuvis_check_status(status, "cuvis_init");
    rcuvis_sdk_alive = 1;
    rcuvis_sdk_started = 1;
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK. "
             "Reinstall with CUVIS_SDK set to the SDK path.");
#endif
    return R_NilValue;
}

SEXP rcuvis_shutdown(void) {
#ifndef CUVIS_STUB
    if (rcuvis_sdk_alive) {
        rcuvis_sdk_alive = 0;
        int status = cuvis_shutdown();
        rcuvis_check_status(status, "cuvis_shutdown");
    }
#endif
    return R_NilValue;
}

SEXP rcuvis_version(void) {
#ifndef CUVIS_STUB
    rcuvis_require_alive();
    char ver[CUVIS_MAXBUF];
    memset(ver, 0, sizeof(ver));
    int status = cuvis_version(ver);
    rcuvis_check_status(status, "cuvis_version");
    return Rf_ScalarString(Rf_mkChar(ver));
#else
    return Rf_ScalarString(Rf_mkChar("stub-0.0.0"));
#endif
}

SEXP rcuvis_available(void) {
#ifndef CUVIS_STUB
    return Rf_ScalarLogical(TRUE);
#else
    return Rf_ScalarLogical(FALSE);
#endif
}

/* ---- .Call registration ---- */

static const R_CallMethodDef CallEntries[] = {
    /* init */
    {"rcuvis_init",                    (DL_FUNC) &rcuvis_init,                    1},
    {"rcuvis_shutdown",                (DL_FUNC) &rcuvis_shutdown,                0},
    {"rcuvis_version",                 (DL_FUNC) &rcuvis_version,                 0},
    {"rcuvis_available",               (DL_FUNC) &rcuvis_available,               0},
    /* session */
    {"rcuvis_session_load",            (DL_FUNC) &rcuvis_session_load,            1},
    {"rcuvis_session_get_size",        (DL_FUNC) &rcuvis_session_get_size,        2},
    {"rcuvis_session_get_mesu",        (DL_FUNC) &rcuvis_session_get_mesu,        3},
    {"rcuvis_session_get_fps",         (DL_FUNC) &rcuvis_session_get_fps,         1},
    {"rcuvis_session_get_hash",        (DL_FUNC) &rcuvis_session_get_hash,        1},
    /* measurement */
    {"rcuvis_mesu_get_metadata",       (DL_FUNC) &rcuvis_mesu_get_metadata,       1},
    {"rcuvis_mesu_get_data_count",     (DL_FUNC) &rcuvis_mesu_get_data_count,     1},
    {"rcuvis_mesu_get_cube",           (DL_FUNC) &rcuvis_mesu_get_cube,           1},
    {"rcuvis_mesu_deep_copy",          (DL_FUNC) &rcuvis_mesu_deep_copy,          1},
    /* processing context */
    {"rcuvis_proc_create_from_session",(DL_FUNC) &rcuvis_proc_create_from_session,2},
    {"rcuvis_proc_create_from_mesu",   (DL_FUNC) &rcuvis_proc_create_from_mesu,   2},
    {"rcuvis_proc_set_reference",      (DL_FUNC) &rcuvis_proc_set_reference,      3},
    {"rcuvis_proc_clear_reference",    (DL_FUNC) &rcuvis_proc_clear_reference,    2},
    {"rcuvis_proc_has_reference",      (DL_FUNC) &rcuvis_proc_has_reference,      2},
    {"rcuvis_proc_set_args",           (DL_FUNC) &rcuvis_proc_set_args,           3},
    {"rcuvis_proc_apply",              (DL_FUNC) &rcuvis_proc_apply,              2},
    /* exporters */
    {"rcuvis_exporter_create_envi",    (DL_FUNC) &rcuvis_exporter_create_envi,    2},
    {"rcuvis_exporter_create_tiff",    (DL_FUNC) &rcuvis_exporter_create_tiff,    4},
    {"rcuvis_exporter_create_cube",    (DL_FUNC) &rcuvis_exporter_create_cube,    3},
    {"rcuvis_exporter_apply",          (DL_FUNC) &rcuvis_exporter_apply,          2},
    {"rcuvis_exporter_close", (DL_FUNC) &rcuvis_exporter_close, 1},
    {NULL, NULL, 0}
};

void R_init_cuvis_r(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);

    cuvis_session_tag  = Rf_install("cuvis_session");
    cuvis_mesu_tag     = Rf_install("cuvis_measurement");
    cuvis_proc_tag     = Rf_install("cuvis_processing_context");
    cuvis_exporter_tag = Rf_install("cuvis_exporter");
}
