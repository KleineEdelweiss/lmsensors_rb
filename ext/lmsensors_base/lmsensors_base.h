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
VALUE declare_globals(VALUE mod) {
  // Map-exporting constants
  /*  Voltage input */
  rb_define_const(mod, "SF_IN", INT2NUM(SENSORS_FEATURE_IN));
  /* Fan speeds in RPM */
  rb_define_const(mod, "SF_FAN", INT2NUM(SENSORS_FEATURE_FAN));
  /* Temperature in degrees Celsius */
  rb_define_const(mod, "SF_TEMP", INT2NUM(SENSORS_FEATURE_TEMP));
  /* Power (Watts) */
  rb_define_const(mod, "SF_POWER", INT2NUM(SENSORS_FEATURE_POWER));
  /* Energy (Joules) */
  rb_define_const(mod, "SF_ENERGY", INT2NUM(SENSORS_FEATURE_ENERGY));
  /* Current (Amps) */
  rb_define_const(mod, "SF_CURR", INT2NUM(SENSORS_FEATURE_CURR));
  /* Relative humidity (% RH) */
  rb_define_const(mod, "SF_HUMIDITY", INT2NUM(SENSORS_FEATURE_HUMIDITY));
  /* Video type (also measured in Volts) */
  rb_define_const(mod, "SF_VID", INT2NUM(SENSORS_FEATURE_VID));
  /* Intrusion alarm for the case */
  rb_define_const(mod, "SF_INTRUSION", INT2NUM(SENSORS_FEATURE_INTRUSION));
  /* Whether case beeper / pcspkr is enabled */
  rb_define_const(mod, "SF_BEEP_ENABLE", INT2NUM(SENSORS_FEATURE_BEEP_ENABLE));
  /* Unknown feature placeholder */
  rb_define_const(mod, "SF_UNKNOWN", INT2NUM(SENSORS_FEATURE_UNKNOWN));
  
  // Unclear features
  /* SENSORS_FEATURE_MAX_MAIN */
  rb_define_const(mod, "SF_MAX_MAIN", INT2NUM(SENSORS_FEATURE_MAX_MAIN));
  /* SENSORS_FEATURE_MAX_OTHER */
  rb_define_const(mod, "SF_MAX_OTHER", INT2NUM(SENSORS_FEATURE_MAX_OTHER));
  /* SENSORS_FEATURE_MAX */
  rb_define_const(mod, "SF_MAX", INT2NUM(SENSORS_FEATURE_MAX));
  
  // Map-exporting limit types, for analysis
  // ex.: critical, critical low, input, max, min
  // Voltage
  /* Present voltage */
  rb_define_const(mod, "SSF_IN_INPUT", INT2NUM(SENSORS_SUBFEATURE_IN_INPUT));
  /* Minimum allowed voltage */
  rb_define_const(mod, "SSF_IN_MIN", INT2NUM(SENSORS_SUBFEATURE_IN_MIN));
  /* Maximum allowed voltage */
  rb_define_const(mod, "SSF_IN_MAX", INT2NUM(SENSORS_SUBFEATURE_IN_MAX));
  /* Critical low voltage */
  rb_define_const(mod, "SSF_IN_LCRIT", INT2NUM(SENSORS_SUBFEATURE_IN_LCRIT));
  /* Critical high voltage */
  rb_define_const(mod, "SSF_IN_CRIT", INT2NUM(SENSORS_SUBFEATURE_IN_CRIT));
  /* Average voltage */
  rb_define_const(mod, "SSF_IN_AVG", INT2NUM(SENSORS_SUBFEATURE_IN_AVERAGE));
  /* Lowest detected voltage input */
  rb_define_const(mod, "SSF_IN_LOW", INT2NUM(SENSORS_SUBFEATURE_IN_LOWEST));
  /* Highest detected voltage input */
  rb_define_const(mod, "SSF_IN_HIGH", INT2NUM(SENSORS_SUBFEATURE_IN_HIGHEST));
  
  // Voltage alarms
  /* Voltage alarm */
  rb_define_const(mod, "SSF_IN_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_ALARM));
  /* Voltage alarm for minimum voltage */
  rb_define_const(mod, "SSF_IN_MIN_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_MIN_ALARM));
  /* Voltage alarm for max voltage */
  rb_define_const(mod, "SSF_IN_MAX_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_MAX_ALARM));
  /* Beep for voltage alarms */
  rb_define_const(mod, "SSF_IN_BEEP", INT2NUM(SENSORS_SUBFEATURE_IN_BEEP));
  /* Critical low voltage alarm */
  rb_define_const(mod, "SSF_IN_LCRIT_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_LCRIT_ALARM));
  /* Critical high voltage alarm */
  rb_define_const(mod, "SSF_IN_CRIT_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_CRIT_ALARM));
  
  // Current
  /* Present current input */
  rb_define_const(mod, "SSF_CURR_INPUT", INT2NUM(SENSORS_SUBFEATURE_CURR_INPUT));
  /* Minimum allowed current */
  rb_define_const(mod, "SSF_CURR_MIN", INT2NUM(SENSORS_SUBFEATURE_CURR_MIN));
  /* Maximum allowed current */
  rb_define_const(mod, "SSF_CURR_MAX", INT2NUM(SENSORS_SUBFEATURE_CURR_MAX));
  /* Critical low current */
  rb_define_const(mod, "SSF_CURR_LCRIT", INT2NUM(SENSORS_SUBFEATURE_CURR_LCRIT));
  /* Critical high current */
  rb_define_const(mod, "SSF_CURR_CRIT", INT2NUM(SENSORS_SUBFEATURE_CURR_CRIT));
  /* Average current */
  rb_define_const(mod, "SSF_CURR_AVG",INT2NUM(SENSORS_SUBFEATURE_CURR_AVERAGE));
  /* Lowest current detected */
  rb_define_const(mod, "SSF_CURR_LOW", INT2NUM(SENSORS_SUBFEATURE_CURR_LOWEST));
  /* Highest current detected */
  rb_define_const(mod, "SSF_CURR_HIGH", INT2NUM(SENSORS_SUBFEATURE_CURR_HIGHEST));
  
  // Current alarms
  /* Current alarm */
  rb_define_const(mod, "SSF_CURR_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_ALARM));
  /* Current alarm for minimum current */
  rb_define_const(mod, "SSF_CURR_MIN_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_MIN_ALARM));
  /* Current alarm for max current */
  rb_define_const(mod, "SSF_CURR_MAX_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_MAX_ALARM));
  /* Beep for current alarms */
  rb_define_const(mod, "SSF_CURR_BEEP", INT2NUM(SENSORS_SUBFEATURE_IN_BEEP));
  /* Critical low current alarm */
  rb_define_const(mod, "SSF_CURR_LCRIT_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_LCRIT_ALARM));
  /* Critical high current alarm */
  rb_define_const(mod, "SSF_CURR_CRIT_ALARM", INT2NUM(SENSORS_SUBFEATURE_IN_CRIT_ALARM));
  
  // Power
  /* Average power */
  rb_define_const(mod, "SSF_POWER_AVG", INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE));
  rb_define_const(mod, "SSF_POWER_AVG_HIGH",
    INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE_HIGHEST));
  rb_define_const(mod, "SSF_POWER_AVG_LOW",
    INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE_LOWEST));
  /* 
   * Present power input, but this seems to be usually handled by
   * SSF_POWER_AVG, at least for my devices.
   */
  rb_define_const(mod, "SSF_POWER_INPUT", INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT));
  /* Highest detected power input */
  rb_define_const(mod, "SSF_POWER_INPUT_HIGH",
    INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT_HIGHEST));
  /* Lowest detected power input */
  rb_define_const(mod, "SSF_POWER_INPUT_LOW",
    INT2NUM(SENSORS_SUBFEATURE_POWER_INPUT_LOWEST));
  /* User- or system- defined limit on power consumption */
  rb_define_const(mod, "SSF_POWER_CAP", INT2NUM(SENSORS_SUBFEATURE_POWER_CAP));
  rb_define_const(mod, "SSF_POWER_CAP_HYST",
    INT2NUM(SENSORS_SUBFEATURE_POWER_CAP_HYST));
  /* Power maximum usage level */
  rb_define_const(mod, "SSF_POWER_MAX", INT2NUM(SENSORS_SUBFEATURE_POWER_MAX));
  /* Power critical usage level */
  rb_define_const(mod, "SSF_POWER_CRIT", INT2NUM(SENSORS_SUBFEATURE_POWER_CRIT));
  /* Power minimum usage level */
  rb_define_const(mod, "SSF_POWER_MIN", INT2NUM(SENSORS_SUBFEATURE_POWER_MIN));
  /* Power critical low level */
  rb_define_const(mod, "SSF_POWER_LCRIT", INT2NUM(SENSORS_SUBFEATURE_POWER_LCRIT));
  /* Interval used by this power sensor to generate averages */
  rb_define_const(mod, "SSF_POWER_AVG_INTERVAL",
    INT2NUM(SENSORS_SUBFEATURE_POWER_AVERAGE_INTERVAL));
  
  // Power alarms
  /* Alarm for power */
  rb_define_const(mod, "SSF_POWER_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_ALARM));
  /* Alarm if power is approaching the defined cap */
  rb_define_const(mod, "SSF_POWER_CAP_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_CAP_ALARM));
  /* Alarm if power usage is nearing max */
  rb_define_const(mod, "SSF_POWER_MAX_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_MAX_ALARM));
  /* Alarm if power usage is critical */
  rb_define_const(mod, "SSF_POWER_CRIT_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_CRIT_ALARM));
  /* Alarm if power usage is too low */
  rb_define_const(mod, "SSF_POWER_MIN_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_MIN_ALARM));
  /* Alarm if power usage is nearing critical low */
  rb_define_const(mod, "SSF_POWER_LCRIT_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_POWER_LCRIT_ALARM));
  
  // Temps
  /* Present temperature input */
  rb_define_const(mod, "SSF_TEMP_INPUT", INT2NUM(SENSORS_SUBFEATURE_TEMP_INPUT));
  /* Maximum temperature allowed */
  rb_define_const(mod, "SSF_TEMP_MAX", INT2NUM(SENSORS_SUBFEATURE_TEMP_MAX));
  rb_define_const(mod, "SSF_TEMP_MAX_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_MAX_HYST));
  /* Minimum temperature allowed */
  rb_define_const(mod, "SSF_TEMP_MIN", INT2NUM(SENSORS_SUBFEATURE_TEMP_MIN));
  /* Critical high temperature */
  rb_define_const(mod, "SSF_TEMP_CRIT", INT2NUM(SENSORS_SUBFEATURE_TEMP_CRIT));
  rb_define_const(mod, "SSF_TEMP_CRIT_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_CRIT_HYST));
  /* Critical low temperature */
  rb_define_const(mod, "SSF_TEMP_LCRIT", INT2NUM(SENSORS_SUBFEATURE_TEMP_LCRIT));
  /* Emergency-level high temperature */
  rb_define_const(mod, "SSF_TEMP_EMERG", INT2NUM(SENSORS_SUBFEATURE_TEMP_EMERGENCY));
  rb_define_const(mod, "SSF_TEMP_EMERG_HYST",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_EMERGENCY_HYST));
  /* Lowest detected temperature */
  rb_define_const(mod, "SSF_TEMP_LOW", INT2NUM(SENSORS_SUBFEATURE_TEMP_LOWEST));
  /* Highest detected temperature */
  rb_define_const(mod, "SSF_TEMP_HIGH", INT2NUM(SENSORS_SUBFEATURE_TEMP_HIGHEST));
  rb_define_const(mod, "SSF_TEMP_MIN_HYST", INT2NUM(SENSORS_SUBFEATURE_TEMP_MIN_HYST));
  rb_define_const(mod, "SSF_TEMP_LCRIT_HYST",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_LCRIT_HYST));
  
  // Other temp subfeatures
  /* Type of the temperature feature */
  rb_define_const(mod, "SSF_TEMP_TYPE", INT2NUM(SENSORS_SUBFEATURE_TEMP_TYPE));
  /* Temperature feature reading offset */
  rb_define_const(mod, "SSF_TEMP_OFFSET", INT2NUM(SENSORS_SUBFEATURE_TEMP_OFFSET));
  
  // Temperature alarm and error subfeatures
  /* Temperature alarm */
  rb_define_const(mod, "SSF_TEMP_ALARM", INT2NUM(SENSORS_SUBFEATURE_TEMP_ALARM));
  /* Alarm when temperature is nearing max */
  rb_define_const(mod, "SSF_TEMP_MAX_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_MAX_ALARM));
  /* Alarm when temperature is nearing min */
  rb_define_const(mod, "SSF_TEMP_MIN_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_MIN_ALARM));
  /* Alarm when temperature is critical */
  rb_define_const(mod, "SSF_TEMP_CRIT_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_CRIT_ALARM));
  /* Beep for temperature alarms */
  rb_define_const(mod, "SSF_TEMP_BEEP", INT2NUM(SENSORS_SUBFEATURE_TEMP_BEEP));
  /* If the temperature sensors has faulted or detected fault */
  rb_define_const(mod, "SSF_TEMP_FAULT", INT2NUM(SENSORS_SUBFEATURE_TEMP_FAULT));
  /* Alarm for when temperature is at emergency-level */
  rb_define_const(mod, "SSF_TEMP_EMERGENCY_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_EMERGENCY_ALARM));
  /* Alarm for when temperature approaches critical low */
  rb_define_const(mod, "SSF_TEMP_LCRIT_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_TEMP_LCRIT_ALARM));
  
  // Fans
  /* Present fan input speed */
  rb_define_const(mod, "SSF_FAN_INPUT", INT2NUM(SENSORS_SUBFEATURE_FAN_INPUT));
  /* Minimum fan speed */
  rb_define_const(mod, "SSF_FAN_MIN", INT2NUM(SENSORS_SUBFEATURE_FAN_MIN));
  /* Maximum fan speed */
  rb_define_const(mod, "SSF_FAN_MAX", INT2NUM(SENSORS_SUBFEATURE_FAN_MAX));
  
  // Additional fan feature exports
  /* Alarm for fan */
  rb_define_const(mod, "SSF_FAN_ALARM", INT2NUM(SENSORS_SUBFEATURE_FAN_ALARM));
  /* Whether fan sensor has detected fault */
  rb_define_const(mod, "SSF_FAN_FAULT", INT2NUM(SENSORS_SUBFEATURE_FAN_FAULT));
  rb_define_const(mod, "SSF_FAN_DIV", INT2NUM(SENSORS_SUBFEATURE_FAN_DIV));
  /* Beep for fan alarms */
  rb_define_const(mod, "SSF_FAN_BEEP", INT2NUM(SENSORS_SUBFEATURE_FAN_BEEP));
  /* PWM / pulse settings for fan */
  rb_define_const(mod, "SSF_FAN_PULSES", INT2NUM(SENSORS_SUBFEATURE_FAN_PULSES));
  /* Alarm if fans approach minimum-allowed speed */
  rb_define_const(mod, "SSF_FAN_MIN_ALARM", INT2NUM(SENSORS_SUBFEATURE_FAN_MIN_ALARM));
  /* Alarm if fans approach maximum-allowed speed */
  rb_define_const(mod, "SSF_FAN_MAX_ALARM", INT2NUM(SENSORS_SUBFEATURE_FAN_MAX_ALARM));
  
  // Alarms
  /* Intrusion alarm subtype */
  rb_define_const(mod, "SSF_INTRUDE_ALARM",
    INT2NUM(SENSORS_SUBFEATURE_INTRUSION_ALARM));
  /* Intrusion beep subtype */
  rb_define_const(mod, "SSF_INTRUDE_BEEP",
    INT2NUM(SENSORS_SUBFEATURE_INTRUSION_BEEP));
  
  // Other exports, which only have 1 subtype, exported for convenience ONLY
  /* Energy input subtype */
  rb_define_const(mod, "SSF_ENERGY_INPUT",
    INT2NUM(SENSORS_SUBFEATURE_ENERGY_INPUT));
  /* Beep enable subtype */
  rb_define_const(mod, "SSF_BEEP_ENABLE",
    INT2NUM(SENSORS_SUBFEATURE_BEEP_ENABLE));
  /* Video input subfeature */
  rb_define_const(mod, "SSF_VID", INT2NUM(SENSORS_SUBFEATURE_VID));
  /* Humidity input subfeature */
  rb_define_const(mod, "SSF_HUMIDITY_INPUT",
    INT2NUM(SENSORS_SUBFEATURE_HUMIDITY_INPUT));
  /* Currently-unknown subfeature */
  rb_define_const(mod, "SSF_UNKNOWN", INT2NUM(SENSORS_SUBFEATURE_UNKNOWN));
  
  // Return complete
  return Qtrue;
}