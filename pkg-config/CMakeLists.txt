# configure pkg-config file
IF (WIN32)
  SET (PkgConfigPrefix "")
ELSE ()
  SET (PkgConfigPrefix ${CMAKE_INSTALL_PREFIX})
ENDIF ()
SET (PkgConfigExecPrefix "\${prefix}")
SET (PkgConfigLibDir "\${exec_prefix}/lib")
SET (PkgConfigIncludeDir "\${prefix}/include")

SET (PkgConfigName "${CMAKE_PROJECT_NAME}")
SET (PkgConfigDescription "${PROJECT_DESCRIPTION}")
SET (PkgConfigVersion "${MAJOR}.${MINOR}.${PATCH}")
SET (PkgConfigLibs "-L\${libdir}")
SET (PkgConfigLibs "${PkgConfigLibs} -l${PROJECT_LOWERCASE_NAME}.so.${MAJOR}")
SET (PkgConfigLibsPrivate "")
SET (PkgConfigCflags "")

CONFIGURE_FILE (
  "${CMAKE_CURRENT_SOURCE_DIR}/pkg-config.pc.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_LOWERCASE_NAME}-${MAJOR}.pc"
)
