INCLUDE (FindVala)
INCLUDE (UseVala)

FIND_PACKAGE (PkgConfig REQUIRED)

PKG_CHECK_MODULES (GEE REQUIRED gee-0.8)
INCLUDE_DIRECTORIES (${GEE_INCLUDE_DIRS})

FILE (GLOB_RECURSE LAviewSources RELATIVE ${CMAKE_SOURCE_DIR}/src *.vala)

VALA_PRECOMPILE (VALA_C ${LAviewSources}
                 PACKAGES gee-0.8 posix
                 OPTIONS --thread ${VALA_DEBUG}
                 CUSTOM_VAPIS
                 GENERATE_VAPI laview-latex-struct-${MAJOR}
                 GENERATE_HEADER laview-latex-struct-${MAJOR}
                )
INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}")
ADD_LIBRARY (laview-latex-struct SHARED ${VALA_C} ${PROJECT_SOURCE_DIR}/src/vala_unsupported.c)
TARGET_LINK_LIBRARIES (laview-latex-struct ${GEE_LIBRARIES})
SET_TARGET_PROPERTIES (laview-latex-struct PROPERTIES VERSION ${VERSION})
SET_TARGET_PROPERTIES (laview-latex-struct PROPERTIES SOVERSION ${MAJOR})
IF (WIN32)
  SET_TARGET_PROPERTIES (laview-latex-struct PROPERTIES PREFIX "" IMPORT_PREFIX "" SUFFIX "-${MAJOR}.dll")
ENDIF (WIN32)

IF (UNIX)
  INSTALL (TARGETS laview-latex-struct DESTINATION lib)
ELSEIF (WIN32)
  INSTALL (TARGETS laview-latex-struct
           RUNTIME DESTINATION bin
           LIBRARY DESTINATION lib
           ARCHIVE DESTINATION lib)
ENDIF (UNIX)

INSTALL (FILES ${CMAKE_BINARY_DIR}/src/laview-latex-struct-${MAJOR}.h DESTINATION include)
