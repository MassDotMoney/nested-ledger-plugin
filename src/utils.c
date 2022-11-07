#include "nested_plugin.h"
#include <stdint.h>

/* check if number in parameter fit in uint size */
static uint8_t does_number_fit(const uint8_t *parameter,
                               uint8_t parameter_length, uint8_t size) {
  for (uint8_t i = 0; i < parameter_length - size; i++) {
    if (parameter[i] != 0)
      return 1;
  }
  return 0;
}

/*
**  copy_number()
*/

uint8_t copy_number_uint32(uint32_t *target, const uint8_t *parameter,
                           uint8_t parameter_length) {
  if (does_number_fit(parameter, parameter_length, sizeof(*target)))
    return 1;
  (*target) = U4BE(parameter, parameter_length - sizeof(*target));
  return 0;
}

uint8_t copy_number_uint16(uint16_t *target, const uint8_t *parameter,
                           uint8_t parameter_length) {
  if (does_number_fit(parameter, parameter_length, sizeof(*target)))
    return 1;
  (*target) = U2BE(parameter, parameter_length - sizeof(*target));
  return 0;
}

uint8_t copy_number_uint8(uint8_t *target, const uint8_t *parameter,
                          uint8_t parameter_length) {
  if (does_number_fit(parameter, parameter_length, sizeof(*target)))
    return 1;
  (*target) = parameter[parameter_length - sizeof(*target)];
  return 0;
}

/*
**  add_numbers()
*/

uint8_t add_in_uint32(uint32_t *target, uint32_t to_add) {
  uint64_t buf = *target + to_add;
  if (buf > UINT32_MAX)
    return 1;
  *target = buf;
  return 0;
}

uint8_t add_in_uint16(uint16_t *target, uint32_t to_add) {
  uint32_t buf = *target + to_add;
  if (buf > UINT16_MAX)
    return 1;
  *target = buf;
  return 0;
}

uint8_t add_in_uint8(uint8_t *target, uint32_t to_add) {
  uint16_t buf = *target + to_add;
  if (buf > UINT8_MAX)
    return 1;
  *target = buf;
  return 0;
}
