#include "rcuvis.h"

/* Store handle as intptr_t in external pointer.
   CUVIS_HANDLE is int32_t, so we cast through intptr_t for pointer storage. */

static void session_finalizer(SEXP xp) {
#ifndef CUVIS_STUB
    void *ptr = R_ExternalPtrAddr(xp);
    if (ptr && rcuvis_sdk_alive) {
        CUVIS_SESSION_FILE handle = (CUVIS_SESSION_FILE)(intptr_t)ptr;
        cuvis_session_file_free(&handle);
    }
    R_ClearExternalPtr(xp);
#else
    R_ClearExternalPtr(xp);
#endif
}

SEXP rcuvis_session_load(SEXP path) {
#ifndef CUVIS_STUB
    const char *filepath = CHAR(STRING_ELT(path, 0));
    CUVIS_SESSION_FILE handle = 0;
    int status = cuvis_session_file_load(filepath, &handle);
    rcuvis_check_status(status, "cuvis_session_file_load");
    return rcuvis_make_handle((void *)(intptr_t)handle, cuvis_session_tag,
                              session_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_session_get_size(SEXP session_xp, SEXP item_type) {
#ifndef CUVIS_STUB
    CUVIS_SESSION_FILE handle = (CUVIS_SESSION_FILE)(intptr_t)rcuvis_get_handle(
        session_xp, cuvis_session_tag, "session");
    CUVIS_INT itype = INTEGER(item_type)[0];
    CUVIS_INT size = 0;
    int status = cuvis_session_file_get_size(handle, itype, &size);
    rcuvis_check_status(status, "cuvis_session_file_get_size");
    return Rf_ScalarInteger(size);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_session_get_mesu(SEXP session_xp, SEXP index, SEXP item_type) {
#ifndef CUVIS_STUB
    CUVIS_SESSION_FILE session_handle = (CUVIS_SESSION_FILE)(intptr_t)rcuvis_get_handle(
        session_xp, cuvis_session_tag, "session");
    CUVIS_INT idx = INTEGER(index)[0];  /* Already 0-based from R side */
    CUVIS_INT itype = INTEGER(item_type)[0];
    CUVIS_MESU mesu_handle = 0;
    int status = cuvis_session_file_get_mesu(session_handle, idx, itype,
                                             &mesu_handle);
    if (status == status_no_measurement) {
        return R_NilValue;
    }
    rcuvis_check_status(status, "cuvis_session_file_get_mesu");

    extern void mesu_finalizer(SEXP xp);
    return rcuvis_make_handle((void *)(intptr_t)mesu_handle, cuvis_mesu_tag,
                              mesu_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_session_get_fps(SEXP session_xp) {
#ifndef CUVIS_STUB
    CUVIS_SESSION_FILE handle = (CUVIS_SESSION_FILE)(intptr_t)rcuvis_get_handle(
        session_xp, cuvis_session_tag, "session");
    double fps = 0.0;
    int status = cuvis_session_file_get_fps(handle, &fps);
    rcuvis_check_status(status, "cuvis_session_file_get_fps");
    return Rf_ScalarReal(fps);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_session_get_hash(SEXP session_xp) {
#ifndef CUVIS_STUB
    CUVIS_SESSION_FILE handle = (CUVIS_SESSION_FILE)(intptr_t)rcuvis_get_handle(
        session_xp, cuvis_session_tag, "session");
    char hash[CUVIS_MAXBUF];
    memset(hash, 0, sizeof(hash));
    int status = cuvis_session_file_get_hash(handle, hash);
    rcuvis_check_status(status, "cuvis_session_file_get_hash");
    return Rf_ScalarString(Rf_mkChar(hash));
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}
