#ifndef RCUVIS_H
#define RCUVIS_H

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <string.h>

#ifndef CUVIS_STUB
#include "cuvis.h"
#endif

/* SDK alive flag — finalizers skip if 0 */
extern int rcuvis_sdk_alive;

/* Tag symbols for external pointer type checking */
extern SEXP cuvis_session_tag;
extern SEXP cuvis_mesu_tag;
extern SEXP cuvis_proc_tag;
extern SEXP cuvis_exporter_tag;

/* Utility functions */
SEXP rcuvis_make_handle(void *ptr, SEXP tag, R_CFinalizer_t finalizer);
void *rcuvis_get_handle(SEXP xp, SEXP expected_tag, const char *type_name);
void rcuvis_check_status(int status, const char *context);

/* Init functions */
SEXP rcuvis_init(SEXP settings_dir);
SEXP rcuvis_shutdown(void);
SEXP rcuvis_version(void);
SEXP rcuvis_available(void);

/* Session functions */
SEXP rcuvis_session_load(SEXP path);
SEXP rcuvis_session_get_size(SEXP session_xp, SEXP item_type);
SEXP rcuvis_session_get_mesu(SEXP session_xp, SEXP index, SEXP item_type);
SEXP rcuvis_session_get_fps(SEXP session_xp);
SEXP rcuvis_session_get_hash(SEXP session_xp);

/* Measurement functions */
SEXP rcuvis_mesu_get_metadata(SEXP mesu_xp);
SEXP rcuvis_mesu_get_data_count(SEXP mesu_xp);
SEXP rcuvis_mesu_get_cube(SEXP mesu_xp);
SEXP rcuvis_mesu_deep_copy(SEXP mesu_xp);

/* Processing context functions */
SEXP rcuvis_proc_create_from_session(SEXP session_xp, SEXP load_refs);
SEXP rcuvis_proc_create_from_mesu(SEXP mesu_xp, SEXP load_refs);
SEXP rcuvis_proc_set_reference(SEXP ctx_xp, SEXP mesu_xp, SEXP type_int);
SEXP rcuvis_proc_clear_reference(SEXP ctx_xp, SEXP type_int);
SEXP rcuvis_proc_has_reference(SEXP ctx_xp, SEXP type_int);
SEXP rcuvis_proc_set_args(SEXP ctx_xp, SEXP mode_int, SEXP allow_recalib);
SEXP rcuvis_proc_apply(SEXP ctx_xp, SEXP mesu_xp);

/* Exporter functions */
SEXP rcuvis_exporter_create_envi(SEXP export_dir, SEXP permissive);
SEXP rcuvis_exporter_create_tiff(SEXP export_dir, SEXP format_int,
                                  SEXP compression_int, SEXP permissive);
SEXP rcuvis_exporter_create_cube(SEXP export_dir, SEXP permissive);
SEXP rcuvis_exporter_apply(SEXP exporter_xp, SEXP mesu_xp);

#endif /* RCUVIS_H */
