CMAKE_C_KNOWN_FEATURES
----------------------

List of C features known to this version of CMake.

The features listed in this global property may be known to be available to the
C compiler.  If the feature is available with the C compiler, it will
be listed in the :variable:`CMAKE_C_COMPILE_FEATURES` variable.

The features listed here may be used with the :command:`target_compile_features`
command.

The features known to this version of CMake are:

``c_function_prototypes``
  Function prototypes, as defined in ``ISO/IEC 9899:1990``.

``c_restrict``
  ``restrict`` keyword, as defined in ``ISO/IEC 9899:1999``.

``c_static_assert``
  Static assert, as defined in ``ISO/IEC 9899:2011``.

``c_variadic_macros``
  Variadic macros, as defined in ``ISO/IEC 9899:1999``.
