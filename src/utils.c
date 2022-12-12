#include "nested_plugin.h"
#include <stdint.h>

/*
**  copy_number()
*/

bool copy_number_uint8(const uint8_t *parameter, uint8_t *target) {
    if (!allzeroes(parameter, PARAMETER_LENGTH - sizeof(*target))) return false;
    (*target) = parameter[PARAMETER_LENGTH - sizeof(*target)];
    return true;
}

bool copy_type_error(__attribute__((unused)) const uint8_t *parameter,
                     __attribute__((unused)) void *target) {
    return false;
}

/*
**  add_numbers()
*/

bool add_in_uint32(uint32_t *target, uint32_t to_add) {
    uint64_t buf = *target + to_add;
    if (buf > UINT32_MAX) return false;
    *target = buf;
    return true;
}

bool add_in_uint16(uint16_t *target, uint32_t to_add) {
    uint32_t buf = *target + to_add;
    if (buf > UINT16_MAX) return false;
    *target = buf;
    return true;
}

bool add_in_uint8(uint8_t *target, uint32_t to_add) {
    uint16_t buf = *target + to_add;
    if (buf > UINT8_MAX) return false;
    *target = buf;
    return true;
}

bool add_type_error(__attribute__((unused)) void *target, __attribute__((unused)) uint32_t to_add) {
    return false;
}
