// ext/lmsensors/lmsensors.c
/* Last backed-up version: < 2021-May-14 @ 06:34:37*/
#include <ruby.h>
#include <stdbool.h>
#include <string.h>
#include <sensors/sensors.h>

#define BUFSIZE 1024

VALUE LmSensors = Qnil;
VALUE Sensors = Qnil;

VALUE method_sensor_get_subfeatures() {
  return Qnil;
}

/*
 * Get the features for a specific chip
 */
VALUE method_sensor_get_features() {
  return Qnil;
}

/* 
 * Enumerate all the chips that can be read from
 */
VALUE method_lmsensors_enumerate_chips() {
  const sensors_chip_name *chip;
  int chip_nr = 0;
  int cnt = 0;
  int err = 0;
  int success = 0;
  
  char buffer[BUFSIZE];
  size_t size = BUFSIZE;
  
  FILE *input = NULL;
  err = sensors_init(input);
  
  VALUE data = rb_hash_new();
  while ((chip = sensors_get_detected_chips(NULL, &chip_nr))) {
    err = sensors_do_chip_sets(chip);
    if (err) { // If anything but 0, it can't load
      rb_hash_aset(data, rb_id2sym(rb_intern("fatal_err")), rb_str_new2(
        "Cannot load chip sets. Have you already done 'sensors-detect?'"));
      break;
    } else {
      VALUE idx = rb_sprintf("item%d", cnt);
      const char *adapter = sensors_get_adapter_name(&chip->bus);
      success = sensors_snprintf_chip_name(buffer, size, chip);
      if (success > 0) {
        // Create a new chip entry
        VALUE curr_chip = rb_hash_new();
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("adapter")),
          rb_str_new2(adapter)); // Attach the adapter
        // Attach the name of the chip
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("name")), rb_str_new2(buffer));
        // Get the chip path
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("path")), 
          rb_str_new2(chip->path));
        
        // Add the chip entry to the list
        rb_hash_aset(data, rb_id2sym(rb_intern(StringValueCStr(idx))),
          curr_chip);
      } else {
        rb_hash_aset(data, rb_id2sym(rb_intern("chip_error")), idx);
        break;
      }
    }
    cnt++;
  }
  // Perform the cleanup operations
  sensors_cleanup();
  
  // Add the total count, before returning the data
  rb_hash_aset(data, rb_id2sym(rb_intern("total_sensors")), INT2NUM(cnt));
  return data;
}

/*
 * Initialize the LmSensors wrapper
 */
void Init_lmsensors() {
  LmSensors = rb_define_module("LmSensors");
  Sensors = rb_define_class_under(LmSensors, "Sensors", rb_cData);

  rb_define_module_function(LmSensors, "chips", method_lmsensors_enumerate_chips, 0);
}
