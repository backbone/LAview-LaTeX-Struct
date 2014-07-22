#if defined(_WIN32)
#include <windows.h>
#endif

#include "gettext-config.h"

#if defined(_WIN32)
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
#elif defined (__GNUC__)
void __attribute__ ((constructor)) laview_latex_struct_load (void)
#endif
{
#if defined(_WIN32)
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

  (void) dwReason;
  (void) lpReserved;
  return TRUE;
#endif
}

