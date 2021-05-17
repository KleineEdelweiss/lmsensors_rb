// ext/lmsensors/lmsensors.c
/* Last backed-up version: < 2021-May-17 @ 02:30:11 */
#include <ruby.h>
#include <stdbool.h>
#include <string.h>
#include <sensors/sensors.h>

#define BUFSIZE 1024

#define LMSLOADER sensors_obj* sensor; TypedData_Get_Struct(self, sensors_obj, &sensors_type, sensor);

#define LMSVALIDATE if (!LMS_OPEN) {\
return rb_str_new2(\
"ERROR: Sensors were not configured! Run `LmSensors.init [filename|nil]`"); }

VALUE LmSensors = Qnil;
VALUE Sensors = Qnil;
VALUE LMS_OPEN = Qfalse;

// ---------------------------
// LMSENSORS MODULE METHODS BELOW
// ---------------------------

/*
 * sensors_init works ACROSS different sensor objects and
 * should, therefore, be handled by the module.
 */
VALUE lmsensors_init(VALUE self, VALUE filename) {
  // First, check if the sensors were already initialized
  if (LMS_OPEN) {
    return LMS_OPEN;
  } // End init check
  
  // Inheriting class should override this with either NULL of value
  FILE *input = NULL;
  // If no file is chosen, just pass NULL -- usually is NULL
  if (RB_TYPE_P(filename, T_STRING)) {
    FILE *input = fopen(StringValueCStr(filename), "r");
  } // Otherwise, don't try to open, leave NULL
  
  int err = 0; // Errors are stored here
  err = sensors_init(input);
  if (err) { return LMS_OPEN; } // There was an error -- return Qfalse
  else {
    LMS_OPEN = Qtrue;
    return LMS_OPEN;
  } // No error -- initialized
} // End module init

// Cleanup sensors
VALUE lmsensors_cleanup() {
  LMS_OPEN = Qfalse;
  sensors_cleanup();
  return LMS_OPEN;
} // End module cleanup

// ---------------------------
// SENSORS METHODS BELOW
// ---------------------------

/*
 * The sensors_obj struct stores
 * iterable constant fields to be used 
 * when accessing available chips, as well
 * as their features and subfeatures.
 * 
 * Despite being const, they are actually altered by
 * pointer to their internal structure, as per the
 * lmsensors API.
 * 
 * chip_name_str is optional and used only if you want
 * to handle a particular chip. After enumerating,
 * you should be able to find the chip name you want to use.
 */
typedef struct {
  const char *chip_name_str;
  const sensors_chip_name *chip_ptr;
  const sensors_feature *feat_ptr;
  const sensors_subfeature *subfeat_ptr;
} sensors_obj; // End sensors object struct

// Free the data in the sensors object
void sensors_free(void* data) {
  sensors_cleanup();
  free(data);
} // End sensors free

// Get the size of the sensors object
size_t sensors_size(const void* data) {
  return sizeof(data);
} // End size getter

// Encapsulate the sensors object for use with
// Ruby's side of the code
static const rb_data_type_t sensors_type = {
  .wrap_struct_name = "sensors_obj",
  .function = {
    .dmark = NULL,
    .dfree = sensors_free,
    .dsize = sensors_size,
  },
  .data = NULL,
  .flags = RUBY_TYPED_FREE_IMMEDIATELY,
}; // End encapsulation

// Allocate space for the object
VALUE sensors_obj_alloc(VALUE self) {
  // Allocate memory for object
  sensors_obj* sensor = malloc(sizeof(sensors_obj));
  // Wrap it within a sensors type struct
  return TypedData_Wrap_Struct(self, &sensors_type, sensor);
} // End memory allocation

// Constructor
VALUE method_sensors_initialize(VALUE self) {
  // Create the pointers
  sensors_chip_name *chip;
  sensors_feature *feat;
  sensors_subfeature *subfeat;
  
  // Attach them to struct
  sensors_obj s = {
    .chip_name_str = NULL, // NULL, by default -- ALL sensors
    .chip_ptr = chip,
    .feat_ptr = feat,
    .subfeat_ptr = subfeat,
  };
  
  LMSLOADER; // Shorthand load sensor
  *sensor = s; // Bind the struct
  return self;
} // End constructor

/* 
 * 
 */
VALUE method_sensors_get_features(VALUE self) {
  LMSLOADER; // Shorthand load sensor
  LMSVALIDATE; // Shorthand early return, if not loaded
  int nr = 0;
  int cnt = 0;
  VALUE features = rb_hash_new();
  
  // Loop through all the features
  while ((sensor->feat_ptr = sensors_get_features(sensor->chip_ptr, &nr))) {
    char *label = sensors_get_label(sensor->chip_ptr, sensor->feat_ptr);
    rb_hash_aset(features, rb_id2sym(rb_intern(label)),
                 rb_str_new2("SUBFEATURE"));
    free(label);
  } // End feature loop
  
  return features;
} // End features getter

/* 
 * Enumerate all the chips that can be read from.
 * 
 * If a chip name is set, only read chips of that type.
 * 
 * If show_data is true, stat each chip of that type.
 * 
 * The different way to call this should be abstracted
 * into the Ruby side wrapping this.
 */
VALUE method_sensors_enumerate_chips(VALUE self, VALUE show_data) {
  LMSLOADER; // Shorthand load sensor
  int chip_nr = 0;
  int cnt = 0;
  int err = 0;
  int success = 0;
  
  // Create temporary buffer for data
  char buffer[BUFSIZE];
  size_t size = BUFSIZE;
  
  LMSVALIDATE; // Shorthand early return, if not loaded
  
  // Intermediary chip item
  sensors_chip_name chip_raw;
  sensors_chip_name *chip = NULL;
  if (sensor->chip_name_str != NULL) {
    err = sensors_parse_chip_name(sensor->chip_name_str, &chip_raw);
    if (err) { return rb_str_new2("Failed to load requested chip"); }
    else { chip = &chip_raw; }
  }
  
  // If not early return, sensors are valid
  VALUE data = rb_hash_new();
  while ((sensor->chip_ptr = sensors_get_detected_chips(chip, &chip_nr))) {
    // Make sure the chip data can be collected
    err = sensors_do_chip_sets(sensor->chip_ptr);
    if (err) { // If anything but 0, it can't load
      rb_hash_aset(data, rb_id2sym(rb_intern("fatal_err")), rb_str_new2(
        "Cannot load chip sets. Have you already done 'sensors-detect?'"));
      break;
    } else {
      VALUE idx = rb_sprintf("item%d", cnt);
      const char *adapter = sensors_get_adapter_name(&sensor->chip_ptr->bus);
      success = sensors_snprintf_chip_name(buffer, size, sensor->chip_ptr);
      if (success > 0) {
        // Create a new chip entry
        VALUE curr_chip = rb_hash_new();
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("adapter")),
                     rb_str_new2(adapter)); // Attach the adapter
        // Attach the name of the chip
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("name")), rb_str_new2(buffer));
        // Get the chip path
        VALUE path = rb_str_new2(sensor->chip_ptr->path);
        rb_hash_aset(curr_chip, rb_id2sym(rb_intern("path")), path);
        
        /* 
         * Stat the features for the card, if set
         * Had to double-check against NIL, b/c doesn't
         * fail the same way as in Ruby.
         */
        if (show_data && !NIL_P(show_data)) {
          rb_hash_aset(curr_chip, rb_id2sym(rb_intern("stat")),
                       method_sensors_get_features(self)); }
                       
                       // Add the chip entry to the list
                       rb_hash_aset(data, path, curr_chip);
      } else {
        rb_hash_aset(data, rb_id2sym(rb_intern("chip_error")), idx);
        break;
      }
    }
    cnt++; // Update the count of available chips
  }
  
  // Add the total count, before returning the data
  rb_hash_aset(data, rb_id2sym(rb_intern("total_sensors")), INT2NUM(cnt));
  return data;
} // End enumerate method

/*
 * Set the chip name -- this should be which chip you
 * would like to use to get data from.
 */
VALUE method_sensors_set_chip_name(VALUE self, VALUE name) {
  Check_Type(name, T_STRING);
  LMSLOADER; // Shorthand load sensor
  LMSVALIDATE; // Shorthand early return, if not loaded
  sensor->chip_name_str = StringValueCStr(name);
  return self;
} // End set chip name

// Get the set chip name
VALUE method_sensors_get_chip_name(VALUE self) {
  LMSLOADER; // Shorthand load sensor
  LMSVALIDATE; // Shorthand early return, if not loaded
  if (sensor->chip_name_str != NULL) {
    return rb_str_new2(sensor->chip_name_str);
  } else { return Qnil; }
} // End chip name checker

/*
 * Unset the chip name, so data will now come from
 * all available chips (probably most people's use case).
 */
VALUE method_sensors_unset_chip_name(VALUE self) {
  LMSLOADER; // Shorthand load sensor
  LMSVALIDATE; // Shorthand early return, if not loaded
  sensor->chip_name_str = NULL;
  return self;
} // End unset chip name

/*
 * Initialize the LmSensors wrapper
 */
void Init_lmsensors() {
  LmSensors = rb_define_module("LmSensors"); // Module
  Sensors = rb_define_class_under(LmSensors, "Sensors", rb_cData); // Main class
  
  // Define the global
  rb_global_variable(&LMS_OPEN);
  
  // Module methods
  rb_define_module_function(LmSensors, "init", lmsensors_init, 1);
  rb_define_module_function(LmSensors, "cleanup", lmsensors_cleanup, 0);
  
  // Sensors methods
  rb_define_alloc_func(Sensors, sensors_obj_alloc);
  rb_define_method(Sensors, "initialize", method_sensors_initialize, 0);
  rb_define_method(Sensors, "enum", method_sensors_enumerate_chips, 1);
  rb_define_method(Sensors, "set_name", method_sensors_set_chip_name, 1);
  rb_define_method(Sensors, "unset_name", method_sensors_unset_chip_name, 0);
  rb_define_method(Sensors, "get_name", method_sensors_get_chip_name, 0);
  rb_define_method(Sensors, "features", method_sensors_get_features, 0);
} // End module and class initialization