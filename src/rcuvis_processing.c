#include "rcuvis.h"

/* Finalizer for processing context handles */
static void proc_finalizer(SEXP xp) {
#ifndef CUVIS_STUB
    void *ptr = R_ExternalPtrAddr(xp);
    if (ptr) {
        int handle = (int)(intptr_t)ptr;
        int h = handle;
        cuvis_proc_cont_free(&h);
        R_ClearExternalPtr(xp);
    }
#else
    R_ClearExternalPtr(xp);
#endif
}

SEXP rcuvis_proc_create_from_session(SEXP session_xp, SEXP load_refs) {
#ifndef CUVIS_STUB
    int session_handle = (int)(intptr_t)rcuvis_get_handle(
        session_xp, cuvis_session_tag, "session");
    int lrefs = LOGICAL(load_refs)[0];
    int ctx_handle = 0;
    int status = cuvis_proc_cont_create_from_session_file(
        session_handle, lrefs ? 1 : 0, &ctx_handle);
    rcuvis_check_status(status, "cuvis_proc_cont_create_from_session_file");
    return rcuvis_make_handle((void *)(intptr_t)ctx_handle, cuvis_proc_tag,
                              proc_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_proc_create_from_mesu(SEXP mesu_xp, SEXP load_refs) {
#ifndef CUVIS_STUB
    int mesu_handle = (int)(intptr_t)rcuvis_get_handle(
        mesu_xp, cuvis_mesu_tag, "measurement");
    int lrefs = LOGICAL(load_refs)[0];
    int ctx_handle = 0;
    int status = cuvis_proc_cont_create_from_mesu(
        mesu_handle, lrefs ? 1 : 0, &ctx_handle);
    rcuvis_check_status(status, "cuvis_proc_cont_create_from_mesu");
    return rcuvis_make_handle((void *)(intptr_t)ctx_handle, cuvis_proc_tag,
                              proc_finalizer);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_proc_set_reference(SEXP ctx_xp, SEXP mesu_xp, SEXP type_int) {
#ifndef CUVIS_STUB
    int ctx_handle = (int)(intptr_t)rcuvis_get_handle(
        ctx_xp, cuvis_proc_tag, "processing_context");
    int mesu_handle = (int)(intptr_t)rcuvis_get_handle(
        mesu_xp, cuvis_mesu_tag, "measurement");
    int ref_type = INTEGER(type_int)[0];
    int status = cuvis_proc_cont_set_reference(ctx_handle, mesu_handle,
                                                ref_type);
    rcuvis_check_status(status, "cuvis_proc_cont_set_reference");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}

SEXP rcuvis_proc_clear_reference(SEXP ctx_xp, SEXP type_int) {
#ifndef CUVIS_STUB
    int ctx_handle = (int)(intptr_t)rcuvis_get_handle(
        ctx_xp, cuvis_proc_tag, "processing_context");
    int ref_type = INTEGER(type_int)[0];
    int status = cuvis_proc_cont_clear_reference(ctx_handle, ref_type);
    rcuvis_check_status(status, "cuvis_proc_cont_clear_reference");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}

SEXP rcuvis_proc_has_reference(SEXP ctx_xp, SEXP type_int) {
#ifndef CUVIS_STUB
    int ctx_handle = (int)(intptr_t)rcuvis_get_handle(
        ctx_xp, cuvis_proc_tag, "processing_context");
    int ref_type = INTEGER(type_int)[0];
    int has_ref = 0;
    int status = cuvis_proc_cont_has_reference(ctx_handle, ref_type, &has_ref);
    rcuvis_check_status(status, "cuvis_proc_cont_has_reference");
    return Rf_ScalarLogical(has_ref != 0);
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
    return R_NilValue;
#endif
}

SEXP rcuvis_proc_set_args(SEXP ctx_xp, SEXP mode_int, SEXP allow_recalib) {
#ifndef CUVIS_STUB
    int ctx_handle = (int)(intptr_t)rcuvis_get_handle(
        ctx_xp, cuvis_proc_tag, "processing_context");
    cuvis_proc_args_t args;
    memset(&args, 0, sizeof(args));
    args.processing_mode = INTEGER(mode_int)[0];
    args.allow_recalib = LOGICAL(allow_recalib)[0] ? 1 : 0;
    int status = cuvis_proc_cont_set_args(ctx_handle, &args);
    rcuvis_check_status(status, "cuvis_proc_cont_set_args");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}

SEXP rcuvis_proc_apply(SEXP ctx_xp, SEXP mesu_xp) {
#ifndef CUVIS_STUB
    int ctx_handle = (int)(intptr_t)rcuvis_get_handle(
        ctx_xp, cuvis_proc_tag, "processing_context");
    int mesu_handle = (int)(intptr_t)rcuvis_get_handle(
        mesu_xp, cuvis_mesu_tag, "measurement");
    int status = cuvis_proc_cont_apply(ctx_handle, mesu_handle);
    rcuvis_check_status(status, "cuvis_proc_cont_apply");
#else
    Rf_error("cuvis.r was installed without the CUVIS SDK.");
#endif
    return R_NilValue;
}
