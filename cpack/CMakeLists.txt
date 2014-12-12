SET (CONTACT "backbone@backbone.ws")
SET (DEBIAN_DEPENDENCIES "valac (>= 0.24), libglib2.0-bin (>= 2.33), libgee (>= 0.16)")
SET (DEBIAN_SECTION "Libraries")
SET (REDHAT_DEPENDENCIES "vala >= 0.24, glib >= 2.33, libgee >= 0.16")
SET (REDHAT_SECTION "Applications/Text")
SET (LICENSE "LGPLv3+")
SET (WIN32_UNINSTALL_NAME "LVLatStr") # <= 8 symbols for the name

LIST (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
INCLUDE (CPackCommon)
