
set(_compiler_id_pp_test "defined(__INTEL_COMPILER) || defined(__ICC)")

set(_compiler_id_version_compute "
  /* __INTEL_COMPILER = VRP */
# define @PREFIX@COMPILER_VERSION_MAJOR DEC(__INTEL_COMPILER/100)
# define @PREFIX@COMPILER_VERSION_MINOR DEC(__INTEL_COMPILER/10 % 10)
# if defined(__INTEL_COMPILER_UPDATE)
#  define @PREFIX@COMPILER_VERSION_PATCH DEC(__INTEL_COMPILER_UPDATE)
# else
#  define @PREFIX@COMPILER_VERSION_PATCH DEC(__INTEL_COMPILER   % 10)
# endif
# if defined(__INTEL_COMPILER_BUILD_DATE)
  /* __INTEL_COMPILER_BUILD_DATE = YYYYMMDD */
#  define @PREFIX@COMPILER_VERSION_TWEAK DEC(__INTEL_COMPILER_BUILD_DATE)
# endif
# if defined(_MSC_VER)
#  define @PREFIX@SIMULATE_ID \"MSVC\"
   /* _MSC_VER = VVRR */
#  define @PREFIX@SIMULATE_VERSION_MAJOR DEC(_MSC_VER / 100)
#  define @PREFIX@SIMULATE_VERSION_MINOR DEC(_MSC_VER % 100)
# endif")
