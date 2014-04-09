///@cond INTERNAL
#include <stdio.h>
#include <stdlib.h>

#include <glib.h>
#include <glib/gprintf.h>

#include <locale.h>

#include "txr-texparser.h"

static gchar *fnameTable = NULL;
static gchar *fnameEtalon = NULL;
static gchar *fnameWrite = NULL;

static GOptionEntry entries[] =
{
  { "table", 't', 0, G_OPTION_ARG_FILENAME, &fnameTable, "File with a table", NULL },
  { "etalon", 'e', 0, G_OPTION_ARG_FILENAME, &fnameEtalon, "File with etalon table", NULL },
  { "write", 'w', 0, G_OPTION_ARG_FILENAME, &fnameWrite, "File to write", NULL },
  { NULL, 0, 0, 0, NULL, NULL, NULL }
};

int main (int argc, char *argv[])
{
  GOptionContext *context;
  GError *error = NULL;

  GError *parse_error = NULL;
  gchar *contents = NULL,
        *generated = NULL,
        *gentext;
  TXRGlob *doc = NULL;
  TXRGlobIter it;

  //MamanBar *bar;
  //MamanBar *bar1;
  
//#if (!GLIB_CHECK_VERSION (2, 36, 0))
//  g_type_init ();
//#endif

  //bar = g_object_new (MAMAN_BAR_TYPE, NULL);
  //g_printf ("type = %s\n", G_OBJECT_TYPE_NAME (bar));
  //g_object_unref (bar);
  //bar1 = g_object_new (MAMAN_BAR_TYPE, NULL);
  //g_object_unref (bar1);
  //(void) bar1;
  //return 0;

  setlocale (LC_ALL, "");

#if (!GLIB_CHECK_VERSION (2, 36, 0))
  g_type_init ();
#endif

  /* commandline arguments processing */
  context = g_option_context_new ("- tests LaTeX parser");
  g_option_context_add_main_entries (context, entries, NULL);//GETTEXT_PACKAGE);
  // g_option_context_add_group (context, gtk_get_option_group (TRUE));
  if (!g_option_context_parse (context, &argc, &argv, &error))
    {
      fprintf (stderr, "option parsing failed: %s\n", error->message);
      exit (1);
    }
  g_option_context_free (context);

  /* read table */
  if (!fnameTable)
    {
      fprintf (stderr, "Specify file with a table");
      goto err;
    }
  /* load file contents
   */
  if (!g_file_get_contents (fnameTable, &contents, NULL, &error))
    {
      g_printf ("Unable to read file: %s\n", error->message);
      goto err;
    }
  g_free (fnameTable);

  g_assert ((contents == NULL && error != NULL)
            || (contents != NULL && error == NULL));

  /* parse TeX */
  doc = txr_parse (contents, &parse_error);

  if (parse_error)
    {
      g_print ("Error parsing TeX document: %s\n", parse_error->message);
      goto err;
    }

  else
    {
      puts ("TeX document successfully parsed\n");
    }

  /* list all objects */
  g_printf ("list all objects\n");
  for (it = txr_glob_first (doc); it; it = txr_glob_iter_next (it))
    {
      g_printf ("%s\n", G_OBJECT_TYPE_NAME (*it));

      if (   !g_strcmp0 ("TXRTabular", G_OBJECT_TYPE_NAME (*it))
          || !g_strcmp0 ("TXRLongtable", G_OBJECT_TYPE_NAME (*it)))
        {
          TXRSubtable *subtable;
          TXRSubtableIter st_it;

          if (!g_strcmp0 ("TXRTabular", G_OBJECT_TYPE_NAME (*it)))
            subtable = txr_tabular_get_table (TXR_TABULAR (*it));
          else
            subtable = txr_longtable_get_table (TXR_LONGTABLE (*it));

          for (st_it = txr_subtable_first (subtable); st_it; st_it = txr_subtable_iter_next (st_it))
            {
              TXRRow *row = TXR_ROW (*st_it);
              TXRRowIter row_it;

              for (row_it = txr_row_first (row); row_it; row_it = txr_row_iter_next (row_it))
                {
                  TXRCell *cell = TXR_CELL (*row_it);
                  TXRGlob *glob = txr_cell_get_contents (cell);
                  TXRGlobIter glob_it;

                  for (glob_it = txr_glob_first (glob); glob_it; glob_it = txr_glob_iter_next (glob_it))
                    {
                      if (g_strcmp0 ("TXRText", G_OBJECT_TYPE_NAME (*glob_it)))
                        g_printf ("  %s\n", G_OBJECT_TYPE_NAME (*glob_it));
                    }
                }
            }
        }
    }

  g_printf ("end of objects\n\n");

  /* walk through all objects */
  g_printf ("Walk through all objects\n");
  for (it = txr_glob_first (doc); it; it = txr_glob_iter_next (it))
    {
      g_printf ("%s\n", G_OBJECT_TYPE_NAME (*it));

      if (!g_strcmp0 ("TXRGraphics", G_OBJECT_TYPE_NAME (*it)))
        {
          gdouble width = 0,
                  height = 0;
          gchar *w_unit = NULL,
                *h_unit = NULL;
          TXRGraphics *graphics = txr_graphics_clone (TXR_GRAPHICS (*it));
          txr_graphics_get_size (graphics, &width, &w_unit, &height, &h_unit);
          gentext = txr_glob_gen ((TXRGlob *) graphics);
          g_printf ("  width=%f%s, height=%f%s, path=%s,\n  gen()=%s\n",
                    width, w_unit, height, h_unit,
                    txr_graphics_get_path (graphics),
                    gentext);
          g_free (gentext);
          /* test txr_graphics_set_size () */
          txr_graphics_set_size (graphics, width / 2, "pt", height * 2, "dd");
          gentext = txr_glob_gen ((TXRGlob *) graphics);
          g_printf ("resized gen() = %s\n", gentext);
          g_free (gentext);
          txr_graphics_unref (graphics);
          g_free (w_unit);
          g_free (h_unit);
        }
    }
  g_printf ("end of objects\n\n");

  /* generate plain-TeX document */
  generated = txr_glob_gen (doc);

  /* load etalon file
   */
  if (fnameEtalon)
    {
      g_free (contents);
      if (!g_file_get_contents (fnameEtalon, &contents, NULL, &error))
        {
          g_printf ("Unable to read file: %s\n", error->message);
          goto err;
        }
    }
  g_free (fnameEtalon);

  if (!g_strcmp0 (contents, generated))
    g_printf ("Original and generated text are EQUAL ;-)\n");
  else
    g_printf ("Original and generated text are NOT EQUAL ;-(\n");

  g_printf ("--- Generated plain-TeX (generated) ---\n%s", generated);

  /* write to file */
  if (fnameWrite)
    g_file_set_contents (fnameWrite, generated, -1, NULL);
  g_free (fnameWrite);

err:
//end:
  g_free (contents);
  g_free (generated);

  if (parse_error)
    {
      g_error_free (parse_error);
    }

  if (error)
    {
      g_error_free (error);
    }

  txr_glob_unref (doc);

  return 0;
}
///@endcond
