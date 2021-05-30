### FMAPPER INFORMATION ###

For the default implementation, you should view ``lib/lmsensors/lm_constants.rb``.

I have included a default feature mapper for most common sensor types, largely to mimic what is included in the ``sensors`` CLI program's formatter. If it is insufficient, however, then you can feel free to use your own.

Unless heavily overriding the classes, the mapper should have an arity of 2 (name of the object, object data). I will not go into details about how to create complex format maps or heavily override the classes. However, the ``AbsFeature`` and all subclasses take the name of the feature (a symbol, such as ``:temp1``) and the feature's data, which includes all of its subfeatures.

The default mapper, however, simply generates a ``Feature::GenFeature.new(name, f_obj)`` for a case statement, based on the feature's type (``SF_FAN``, ``SF_TEMP``, ``SF_VOLTAGE``, etc.). If you create an alternative, it should do similar.
```ruby
case f_obj[:type]
when []
  ...
when []
  ...
else
  ...
end
```
For all intents and purposes, your own format-mapper can have a single clause, if you don't care about anything else. All of the ``AbsFeature`` subclasses were purely for convenience, and they should provide for the vast majority of use cases.