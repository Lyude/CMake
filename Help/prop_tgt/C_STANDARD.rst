C_STANDARD
----------

The C standard whose features are requested to build this target.

This property specifies the C standard whose features are requested
to build this target.  For some compilers, this results in adding a
flag such as ``-std=c11`` to the compile line.

Supported values are ``90``, ``99`` and ``11``.

If the value requested does not result in a compile flag being added for
the compiler in use, a previous standard flag will be added instead.  This
means that using:

.. code-block:: cmake

  set_property(TARGET tgt PROPERTY C_STANDARD 11)

with a compiler which does not support ``-std=c11`` or an equivalent
flag will not result in an error or warning, but will instead add the
``-std=c99`` or ``-std=c90`` flag if supported.  This "decay" behavior may
be controlled with the :prop_tgt:`C_STANDARD_REQUIRED` target property.

This property is initialized by the value of
the :variable:`CMAKE_C_STANDARD` variable if it is set when a target
is created.
