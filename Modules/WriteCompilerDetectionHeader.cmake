#.rst:
# WriteCompilerDetectionHeader
# ----------------------------
#
# This module provides the function write_compiler_detection_header().
#
# The ``WRITE_COMPILER_DETECTION_HEADER`` function can be used to generate
# a file suitable for preprocessor inclusion which contains macros to be
# used in source code::
#
#    write_compiler_detection_header(
#              FILE <file>
#              PREFIX <prefix>
#              COMPILERS <compiler> [...]
#              FEATURES <feature> [...]
#              [VERSION <version>]
#              [PROLOG <prolog>]
#              [EPILOG <epilog>]
#    )
#
# The ``write_compiler_detection_header`` function generates the
# file ``<file>`` with macros which all have the prefix ``<prefix>``.
#
# ``VERSION`` may be used to specify a generation compatibility with older
# CMake versions.  By default, a file is generated with compatibility with
# the :variable:`CMAKE_MINIMUM_REQUIRED_VERSION`.  Newer CMake versions may
# generate additional code, and the ``VERSION`` may be used to maintain
# compatibility in the generated file while allowing the minimum CMake
# version of the project to be changed independently.
#
# ``PROLOG`` may be specified as text content to write at the start of the
# header. ``EPILOG`` may be specified as text content to write at the end
# of the header
#
# At least one ``<compiler>`` and one ``<feature>`` must be listed. Compilers
# which are known to CMake, but not specified are detected and a preprocessor
# ``#error`` is generated for them.  A preprocessor macro matching
# ``<PREFIX>_COMPILER_IS_${CompilerId}`` is generated for each compiler
# known to CMake to contain the value ``0`` or ``1``.
#
# Feature Test Macros
# ===================
#
# For each compiler, a preprocessor test of the compiler version is generated
# denoting whether the each feature is enabled.  A preprocessor macro
# matching ``<PREFIX>_COMPILER_${FEATURE_NAME_UPPER}`` is generated to
# contain the value ``0`` or ``1`` depending on whether the compiler in
# use supports the feature:
#
# .. code-block:: cmake
#
#    write_compiler_detection_header(
#      FILE climbingstats_compiler_detection.h
#      PREFIX ClimbingStats
#      COMPILERS GNU Clang MSVC
#      FEATURES cxx_variadic_templates
#    )
#
# .. code-block:: c++
#
#    #if ClimbingStats_COMPILER_CXX_VARIADIC_TEMPLATES
#    template<typename... T>
#    void someInterface(T t...) { /* ... */ }
#    #else
#    // Compatibility versions
#    template<typename T1>
#    void someInterface(T1 t1) { /* ... */ }
#    template<typename T1, typename T2>
#    void someInterface(T1 t1, T2 t2) { /* ... */ }
#    template<typename T1, typename T2, typename T3>
#    void someInterface(T1 t1, T2 t2, T3 t3) { /* ... */ }
#    #endif
#
# Symbol Macros
# =============
#
# Some additional symbol-defines are created for particular features for
# use as symbols which may be conditionally defined empty:
#
# .. code-block:: c++
#
#    class MyClass ClimbingStats_DECL_CXX_FINAL
#    {
#        ClimbingStats_DECL_CXX_CONSTEXPR int someInterface() { return 42; }
#    };
#
# The ``ClimbingStats_DECL_CXX_FINAL`` macro will expand to ``final`` if the
# compiler (and its flags) support the ``cxx_final`` feature, and the
# ``ClimbingStats_DECL_CXX_CONSTEXPR`` macro will expand to ``constexpr``
# if ``cxx_constexpr`` is supported.
#
# The following features generate corresponding symbol defines:
#
# ========================== =================================== =================
#         Feature                          Define                      Symbol
# ========================== =================================== =================
# ``cxx_constexpr``           ``<PREFIX>_CONSTEXPR``              ``constexpr``
# ``cxx_deleted_functions``   ``<PREFIX>_DELETED_FUNCTION``       ``= delete``
# ``cxx_extern_templates``    ``<PREFIX>_EXTERN_TEMPLATE``        ``extern``
# ``cxx_final``               ``<PREFIX>_FINAL``                  ``final``
# ``cxx_noexcept``            ``<PREFIX>_NOEXCEPT``               ``noexcept``
# ``cxx_noexcept``            ``<PREFIX>_NOEXCEPT_EXPR(X)``       ``noexcept(X)``
# ``cxx_override``            ``<PREFIX>_OVERRIDE``               ``override``
# ========================== =================================== =================
#
# Compatibility Implementation Macros
# ===================================
#
# Some features are suitable for wrapping in a macro with a backward
# compatibility implementation if the compiler does not support the feature.
#
# When the ``cxx_static_assert`` feature is not provided by the compiler,
# a compatibility implementation is available via the
# ``<PREFIX>}_STATIC_ASSERT`` and ``<PREFIX>_STATIC_ASSERT_MSG``
# function-like macros. The macros expand to ``static_assert`` where that
# compiler feature is available, and to a compatibility implementation
# or compiler extension otherwise.
#
# ====================== ================================ ===================
#         Feature                    Define                     Symbol
# ====================== ================================ ===================
# ``cxx_alignas``         ``<PREFIX>_ALIGNAS``             ``alignas``
# ``cxx_alignof``         ``<PREFIX>_ALIGNOF``             ``alignof``
# ``cxx_nullptr``         ``<PREFIX>_NULLPTR``             ``nullptr``
# ``cxx_static_assert``   ``<PREFIX>_STATIC_ASSERT``       ``static_assert``
# ``cxx_static_assert``   ``<PREFIX>_STATIC_ASSERT_MSG``   ``static_assert``
# ====================== ================================ ===================


#=============================================================================
# Copyright 2014 Stephen Kelly <steveire@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

include(${CMAKE_CURRENT_LIST_DIR}/CMakeParseArguments.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeCompilerIdDetection.cmake)

function(_load_compiler_variables CompilerId lang)
  include("${CMAKE_ROOT}/Modules/Compiler/${CompilerId}-${lang}-FeatureTests.cmake" OPTIONAL)
  set(_cmake_oldestSupported_${CompilerId} ${_cmake_oldestSupported} PARENT_SCOPE)
  foreach(feature ${ARGN})
    set(_cmake_feature_test_${CompilerId}_${feature} ${_cmake_feature_test_${feature}} PARENT_SCOPE)
    if (_cmake_symbol_alternative_${feature})
      set(_cmake_symbol_alternative_${CompilerId}_${feature} ${_cmake_symbol_alternative_${feature}} PARENT_SCOPE)
      set(_cmake_symbol_alternative_test_${CompilerId}_${feature} ${_cmake_symbol_alternative_test_${feature}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(write_compiler_detection_header
    file_keyword file_arg
    prefix_keyword prefix_arg
    )
  if (NOT file_keyword STREQUAL FILE)
    message(FATAL_ERROR "write_compiler_detection_header: FILE parameter missing.")
  endif()
  if (NOT prefix_keyword STREQUAL PREFIX)
    message(FATAL_ERROR "write_compiler_detection_header: PREFIX parameter missing.")
  endif()
  set(options)
  set(oneValueArgs VERSION EPILOG PROLOG)
  set(multiValueArgs COMPILERS FEATURES)
  cmake_parse_arguments(_WCD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT _WCD_COMPILERS)
    message(FATAL_ERROR "Invalid arguments.  write_compiler_detection_header requires at least one compiler.")
  endif()
  if (NOT _WCD_FEATURES)
    message(FATAL_ERROR "Invalid arguments.  write_compiler_detection_header requires at least one feature.")
  endif()

  if(_WCD_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unparsed arguments: ${_WCD_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT _WCD_VERSION)
    set(_WCD_VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})
  endif()
  if (_WCD_VERSION VERSION_LESS 3.1.0) # Version which introduced this function
    message(FATAL_ERROR "VERSION parameter too low.")
  endif()

  set(compilers
    GNU
  )
  foreach(_comp ${_WCD_COMPILERS})
    list(FIND compilers ${_comp} idx)
    if (idx EQUAL -1)
      message(FATAL_ERROR "Unsupported compiler ${_comp}.")
    endif()
  endforeach()

  file(WRITE ${file_arg} "
// This is a generated file. Do not edit!

#ifndef ${prefix_arg}_COMPILER_DETECTION_H
#define ${prefix_arg}_COMPILER_DETECTION_H
")

  if (_WCD_PROLOG)
    file(APPEND "${file_arg}" "\n${_WCD_PROLOG}\n")
  endif()

  foreach(feature ${_WCD_FEATURES})
    if (feature MATCHES "^cxx_")
      list(APPEND _langs CXX)
      list(APPEND CXX_features ${feature})
    else()
      message(FATAL_ERROR "Unsupported feature ${feature}.")
    endif()
  endforeach()
  list(REMOVE_DUPLICATES _langs)

  foreach(_lang ${_langs})

    get_property(known_features GLOBAL PROPERTY CMAKE_${_lang}_KNOWN_FEATURES)
    foreach(feature ${${_lang}_features})
      list(FIND known_features ${feature} idx)
      if (idx EQUAL -1)
        message(FATAL_ERROR "Unsupported feature ${feature}.")
      endif()
    endforeach()

    if(_lang STREQUAL CXX)
      file(APPEND "${file_arg}" "\n#ifdef __cplusplus\n")
    endif()

    compiler_id_detection(ID_CONTENT ${_lang} PREFIX ${prefix_arg}_
      ID_DEFINE
    )

    file(APPEND "${file_arg}" "${ID_CONTENT}\n")

    set(pp_if "if")
    foreach(compiler ${_WCD_COMPILERS})
      _load_compiler_variables(${compiler} ${_lang} ${${_lang}_features})
      file(APPEND "${file_arg}" "\n#  ${pp_if} ${prefix_arg}_COMPILER_IS_${compiler}\n")
      file(APPEND "${file_arg}"
          "\n#    if !(${_cmake_oldestSupported_${compiler}})\n#      error Unsupported compiler version\n#    endif\n")
      set(pp_if "elif")
      foreach(feature ${${_lang}_features})
        string(TOUPPER ${feature} feature_upper)
        set(feature_PP "COMPILER_${feature_upper}")
        set(_define_item "\n#    define ${prefix_arg}_${feature_PP} 0\n")
        if (_cmake_feature_test_${compiler}_${feature} STREQUAL "1")
          set(_define_item "\n#    define ${prefix_arg}_${feature_PP} 1\n")
        elseif (_cmake_feature_test_${compiler}_${feature})
          set(_define_item "\n#      define ${prefix_arg}_${feature_PP} 0\n")
          set(_define_item "\n#    if ${_cmake_feature_test_${compiler}_${feature}}\n#      define ${prefix_arg}_${feature_PP} 1\n#    else${_define_item}#    endif\n")
        endif()
        file(APPEND "${file_arg}" "${_define_item}")
      endforeach()
    endforeach()
    if(pp_if STREQUAL "elif")
      file(APPEND "${file_arg}" "\n#  else\n#    error Unsupported compiler\n#  endif\n\n")
    endif()
    foreach(feature ${${_lang}_features})
      string(TOUPPER ${feature} feature_upper)
      set(feature_PP "COMPILER_${feature_upper}")
      set(def_name ${prefix_arg}_${feature_PP})
      if (feature STREQUAL cxx_constexpr)
        set(def_value "${prefix_arg}_DECL_${feature_upper}")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} constexpr
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_final)
        set(def_value "${prefix_arg}_DECL_${feature_upper}")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} final
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_override)
        set(def_value "${prefix_arg}_DECL_${feature_upper}")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} override
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_static_assert)
        set(def_value "${prefix_arg}_STATIC_ASSERT(X)")
        set(def_value_msg "${prefix_arg}_STATIC_ASSERT_MSG(X, MSG)")
        set(static_assert_struct "template<bool> struct ${prefix_arg}StaticAssert;\ntemplate<> struct ${prefix_arg}StaticAssert<true>{};\n")
        set(def_standard "#    define ${def_value} static_assert(X, #X)\n#    define ${def_value_msg} static_assert(X, MSG)")
        set(def_alternative "${static_assert_struct}#    define ${def_value} sizeof(${prefix_arg}StaticAssert<X>)\n#    define ${def_value_msg} sizeof(${prefix_arg}StaticAssert<X>)")
        file(APPEND "${file_arg}" "#  if ${def_name}\n${def_standard}\n#  else\n${def_alternative}\n#  endif\n\n")
      endif()
      if (feature STREQUAL cxx_alignas)
        set(def_value "${prefix_arg}_ALIGNAS(X)")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} alignas(X)
#  elif ${prefix_arg}_COMPILER_IS_GNU
#    define ${def_value} __attribute__ ((__aligned__(X)))
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_alignof)
        set(def_value "${prefix_arg}_ALIGNOF(X)")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} alignof(X)
#  elif ${prefix_arg}_COMPILER_IS_GNU
#    define ${def_value} __alignof__(X)
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_deleted_functions)
        set(def_value "${prefix_arg}_DELETED_FUNCTION")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} = delete
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_extern_templates)
        set(def_value "${prefix_arg}_EXTERN_TEMPLATE")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} extern
#  else
#    define ${def_value}
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_noexcept)
        set(def_value "${prefix_arg}_NOEXCEPT")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} noexcept
#    define ${def_value}_EXPR(X) noexcept(X)
#  else
#    define ${def_value}
#    define ${def_value}_EXPR(X)
#  endif
\n")
      endif()
      if (feature STREQUAL cxx_nullptr)
        set(def_value "${prefix_arg}_NULLPTR")
        file(APPEND "${file_arg}" "
#  if ${def_name}
#    define ${def_value} nullptr
#  else
#    define ${def_value} static_cast<void*>(0)
#  endif
\n")
      endif()
    endforeach()
    if(_lang STREQUAL CXX)
      file(APPEND "${file_arg}" "#endif\n")
    endif()

  endforeach()

  if (_WCD_EPILOG)
    file(APPEND "${file_arg}" "\n${_WCD_EPILOG}\n")
  endif()

  file(APPEND ${file_arg} "\n#endif\n")
endfunction()
