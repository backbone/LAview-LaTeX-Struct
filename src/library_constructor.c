#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif

#include "gettext-config.h"

#if defined(_WIN32) || defined(_WIN64)
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
#elif defined(linux) || defined(UNIX) || defined(__unix__)
void __attribute__ ((constructor)) load_library (void)
#endif
{
#if defined(_WIN32) || defined(_WIN64)
  gchar  dllPath[FILENAME_MAX],
        *dllDir,
        *localePath;

  GetModuleFileName (hInstance, dllPath, FILENAME_MAX);
  dllDir = g_path_get_dirname (dllPath);
  localePath = g_build_filename (dllDir, "../share/locale", NULL);
  g_free (dllDir);
  bindtextdomain (GETTEXT_PACKAGE, localePath);
  g_free (localePath);
#endif

#if (!GLIB_CHECK_VERSION (2, 36, 0))
  g_type_init ();
#endif

#if defined(_WIN32) || defined(_WIN64)
  (void) dwReason;    // avoid
  (void) lpReserved;  // warngings
  return TRUE;
#endif
}
