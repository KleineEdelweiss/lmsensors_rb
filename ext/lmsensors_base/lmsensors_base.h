// ext/lmsensors_base/lmsensors_base.h
#include <ruby.h>
#include <stdbool.h>
#include <string.h>
#include <sensors/sensors.h>

#define BUFSIZE 1024

VALUE LmSensors = Qnil;
VALUE Sensors = Qnil;
VALUE LMS_OPEN = Qfalse;

/* 
 * Declare all the global mapping constants
 */
VALUE declare_globals() {
  // Map-exporting constants
  rb_define_global_const("SF_IN", INT2NUM(SENSORS_FEATURE_IN));
  rb_define_global_const("SF_FAN", INT2NUM(SENSORS_FEATURE_FAN));
  rb_define_global_const("SF_TEMP", INT2NUM(SENSORS_FEATURE_TEMP));
  rb_define_global_const("SF_POWER", INT2NUM(SENSORS_FEATURE_POWER));
  rb_define_global_const("SF_ENERGY", INT2NUM(SENSORS_FEATURE_ENERGY));
  rb_define_global_const("SF_CURR", INT2NUM(SENSORS_FEATURE_CURR));
  rb_define_global_const("SF_HUMIDITY", INT2NUM(SENSORS_FEATURE_HUMIDITY));
  rb_define_global_const("SF_MAX_MAIN", INT2NUM(SENSORS_FEATURE_MAX_MAIN));
  rb_define_global_const("SF_VID", INT2NUM(SENSORS_FEATURE_VID));
  rb_define_global_const("SF_INTRUSION", INT2NUM(SENSORS_FEATURE_INTRUSION));
  rb_define_global_const("SF_MAX_OTHER", INT2NUM(SENSORS_FEATURE_MAX_OTHER));
  rb_define_global_const("SF_BEEP_ENABLE", INT2NUM(SENSORS_FEATURE_BEEP_ENABLE));
  rb_define_global_const("SF_MAX", INT2NUM(SENSORS_FEATURE_MAX));
  rb_define_global_const("SF_UNKNOWN", INT2NUM(SENSORS_FEATURE_UNKNOWN));
  
  // Map-exporting limit types, for analysis
  // ex.: critical, critical low, input, max, min
  // Voltage
  rb_define_global_const("SSF_IN_INPUT", INT2NUM(SENSORS_SUBFEATURE_IN_INPUT));
  rb_define_global_const("SSF_IN_MIN", INT2NUM(SENSORS_SUBFEATURE_IN_MIN));
  rb_define_global_const("SSF_IN_MAX", INT2NUM(SENSORS_SUBFEATURE_IN_MAX));
  rb_define_global_const("SSF_IN_LCRIT", INT2NUM(SENSORS_SUBFEATURE_IN_LCRIT));
  rb_define_global_const("SSF_IN_CRIT", INT2NUM(SENSORS_SUBFEATURE_IN_CRIT));
  rb_define_global_const("SSF_IN_AVG", INT2NUM(SENSORS_SUBFEATURE_IN_AVERAGE));
  rb_define_global_const("SSF_IN_LOW", INT2NUM(SENSORS_SUBFEATURE_IN_LOWEST));
  rb_define_global_const("SSF_IN_HIGH", INT2NUM(SENSORS_SUBFEATURE_IN_HIGHEST));
  
  // Current
  rb_define_global_const("SSF_CURR_INPUT", INT2NUM(SENSORS_SUBFEATURE_CURR_INPUT));
  rb_define_global_const("SSF_CURR_MIN", INT2NUM(SENSORS_SUBFEATURE_CURR_MIN));
  rb_define_global_const("SSF_CURR_MAX", INT2NUM(SENSORS_SUBFEATURE_CURR_MAX));
  rb_define_global_const("SSF_CURR_LCRIT", INT2NUM(SENSORS_SUBFEATURE_CURR_LCRIT));
  rb_define_global_const("SSF_CURR_CRIT", INT2NUM(SENSORS_SUBFEATURE_CURR_CRIT));
  rb_define_global_const("SSF_CURR_AVG",INT2NUM(SENSORS_SUBFEATURE_CURR_AVERAGE));
  rb_define_global_const("SSF_CURR_LOW", INT2NUM(SENSORS_SUBFEATURE_CURR_LOWEST));
  rb_define_global_const("SSF_CURR_HIGH", INT2NUM(SENSORS_SUBFEATURE_CURR_HIGHEST));
  
  // Power
  rb_define_global_const("SSF_POWER_AVG", INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE));
  rb_define_global_const("SSF_POWER_AVG_HIGH",
    INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE_HIGHEST));
  rb_define_global_const("SSF_POWER_AVG_LOW",
    INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE_LOWEST));
  rb_define_global_const("SSF_POWER_INPUT", INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT));
  rb_define_global_const("SSF_POWER_INPUT_HIGH",
    INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT_HIGHEST));
  rb_define_global_const("SSF_POWER_INPUT_LOW",
    INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT_LOWEST));
  rb_define_global_const("SSF_POWER_CAP", INT2NUM(SENSORS_SUBFEATURE_POWER_CAP));
  rb_define_global_const("SSF_POWER_CAP_HYST",
    INT2NUM(SENSORS_SUBFEATURE_POWER_CAP_HYST));
  rb_define_global_const("SSF_POWER_MAX", INT2NUM(SENSORS_SUBFEATURE_POWER_MAX));
  rb_define_global_const("SSF_POWER_CRIT", INT2NUM(SENSORS_SUBFEATURE_POWER_CRIT));
  rb_define_global_const("SSF_POWER_MIN", INT2NUM(SENSORS_SUBFEATURE_POWER_MIN));
  rb_define_global_const("SSF_POWER_LCRIT", INT2NUM(SENSORS_SUBFEATURE_POWER_LCRIT));
  
  // Temps
  rb_define_global_const("SSF_TEMP_INPUT", INT2NUM(SENSORS_SUBFEATURE_TEMP_INPUT));
  rb_define_global_const("SSF_TEMP_MAX", INT2NUM(SENSORS_SUBFEATURE_TEMP_MAX));
  rb_define_global_const("SSF_TEMP_MAX_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_MAX_HYST));
  rb_define_global_const("SSF_TEMP_MIN", INT2NUM(SENSORS_SUBFEATURE_TEMP_MIN));
  rb_define_global_const("SSF_TEMP_CRIT", INT2NUM(SENSORS_SUBFEATURE_TEMP_CRIT));
  rb_define_global_const("SSF_TEMP_CRIT_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_CRIT_HYST));
  rb_define_global_const("SSF_TEMP_LCRIT", INT2NUM(SENSORS_SUBFEATURE_TEMP_LCRIT));
  rb_define_global_const("SSF_TEMP_EMERG", INT2NUM(SENSORS_SUBFEATURE_TEMP_EMERGENCY));
  rb_define_global_const("SSF_TEMP_EMERG_HYST",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_EMERGENCY_HYST));
  rb_define_global_const("SSF_TEMP_LOW", INT2NUM(SENSORS_SUBFEATURE_TEMP_LOWEST));
  rb_define_global_const("SSF_TEMP_HIGH", INT2NUM(SENSORS_SUBFEATURE_TEMP_HIGHEST));
  rb_define_global_const("SSF_TEMP_MIN_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_MIN_HYST));
  rb_define_global_const("SSF_TEMP_LCRIT_HYST",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_LCRIT_HYST));
  
  // Fans
  rb_define_global_const("SSF_FAN_INPUT", INT2NUM(SENSORS_SUBFEATURE_FAN_INPUT));
  rb_define_global_const("SSF_FAN_MIN", INT2NUM(SENSORS_SUBFEATURE_FAN_MIN));
  rb_define_global_const("SSF_FAN_MAX", INT2NUM(SENSORS_SUBFEATURE_FAN_MAX));
  
  // Return complete
  return Qtrue;
}