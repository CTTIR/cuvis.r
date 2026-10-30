/* Synthetic SDK response data. This does not emulate calibration or file I/O. */
#include "cuvis.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
static int scenario = 1;
static int overwrite_setting = -1;
static int export_phase = 0;
static uint8_t data8[24];
static uint16_t data16[24];
static uint32_t data32[24];
static float datafloat[24];
static uint32_t wavelengths[4] = {450, 550, 650, 750};

CUVIS_STATUS cuvis_init(const CUVIS_CHAR *path, CUVIS_INT level, const CUVIS_CHAR *log) {
    return status_ok;
}
CUVIS_STATUS cuvis_shutdown(void) { return status_ok; }
const CUVIS_CHAR *cuvis_get_last_error_msg(void) { return "synthetic failure"; }
CUVIS_STATUS cuvis_version(CUVIS_CHAR *out) { strcpy(out, "synthetic-sdk"); return status_ok; }
CUVIS_STATUS cuvis_session_file_load(const CUVIS_CHAR *path, CUVIS_SESSION_FILE *out) {
    scenario = atoi(path); *out = 1; return status_ok;
}
CUVIS_STATUS cuvis_session_file_get_mesu(CUVIS_SESSION_FILE session, CUVIS_INT index,
                                        CUVIS_SESSION_ITEM_TYPE type, CUVIS_MESU *out) {
    if (index == 99) return status_no_measurement;
    *out = 2; return status_ok;
}
CUVIS_STATUS cuvis_session_file_get_size(CUVIS_SESSION_FILE session,
                                        CUVIS_SESSION_ITEM_TYPE type, CUVIS_INT *out) {
    *out = 1; return status_ok;
}
CUVIS_STATUS cuvis_session_file_free(CUVIS_SESSION_FILE *handle) { *handle = 0; return status_ok; }
CUVIS_STATUS cuvis_measurement_free(CUVIS_MESU *handle) { *handle = 0; return status_ok; }
CUVIS_STATUS cuvis_measurement_clear_cube(CUVIS_MESU handle) { return status_ok; }
CUVIS_STATUS cuvis_exporter_free(CUVIS_EXPORTER *handle) {
    if (export_phase != 2 && export_phase != 0) abort();
    export_phase = 0; *handle = 0; return status_ok;
}
CUVIS_STATUS cuvis_exporter_flush(CUVIS_EXPORTER handle) {
    if (export_phase != 1) abort();
    export_phase = 2;
    return scenario == 22 ? status_error : status_ok;
}
CUVIS_STATUS cuvis_exporter_create_cube(CUVIS_EXPORTER *out,
    CUVIS_EXPORT_GENERAL_SETTINGS general, CUVIS_EXPORT_CUBE_SETTINGS args) {
    if (args.hard_limit < 1 || args.allow_drop) abort();
    overwrite_setting = args.allow_overwrite; *out = 3; return status_ok;
}
CUVIS_STATUS cuvis_exporter_apply(CUVIS_EXPORTER exporter, CUVIS_MESU measurement) {
    if (scenario != 22 && overwrite_setting != scenario - 20) abort();
    export_phase = 1;
    return status_ok;
}
CUVIS_STATUS cuvis_measurement_get_data_image(CUVIS_MESU measurement,
                                             const CUVIS_CHAR *key, CUVIS_IMBUFFER *out) {
    for (int i = 0; i < 24; i++) {
        data8[i] = i; data16[i] = 1000 + i; data32[i] = 3000000000U + i;
        datafloat[i] = i / 4.0f;
    }
    datafloat[0] = NAN;
    memset(out, 0, sizeof(*out));
    out->width = 3; out->height = 2; out->channels = 4;
    out->wavelength = wavelengths;
    switch (scenario) {
        case 1: out->format = imbuffer_format_uint8; out->raw = data8; out->bytes = 1; break;
        case 2: out->format = imbuffer_format_uint16; out->raw = (uint8_t*)data16; out->bytes = 2; break;
        case 3: out->format = imbuffer_format_uint32; out->raw = (uint8_t*)data32; out->bytes = 4; break;
        default: out->format = imbuffer_format_float; out->raw = (uint8_t*)datafloat; out->bytes = 4;
    }
    out->length = 24 * out->bytes;
    if (scenario == 5) out->raw = NULL;
    if (scenario == 6) out->length--;
    if (scenario == 7) out->bytes = 1;
    if (scenario == 8) out->width = UINT32_MAX;
    if (scenario == 9) out->height = 0;
    if (scenario == 10) out->channels = 0;
    if (scenario == 11) out->format = (CUVIS_IMBUFFER_FORMAT)99;
    if (scenario == 12) { out->width = 100000; out->height = 100000; }
    return status_ok;
}
CUVIS_MESU_METADATA *cuvis_mesu_metadata_allocate(void) { abort(); }
void cuvis_mesu_metadata_free(CUVIS_MESU_METADATA *metadata) { abort(); }
