///@cond INTERNAL
#include <stdio.h>

#include <glib.h>
#include <glib/gprintf.h>

#include <locale.h>

#include "txr-texparser.h"

int main (int argc, char *argv[])
{
  GError *parse_error = NULL;
  GError *error = NULL;
  gchar *contents = NULL,
        *generated = NULL,
        *generated_etalon = NULL;
  TXRGlob *doc = NULL;
  TXRGlobIter it;

  setlocale (LC_ALL, "");

#if (!GLIB_CHECK_VERSION (2, 36, 0))
  g_type_init ();
#endif

  /* warning stub */
  g_assert (4 == argc || 5 == argc);

  /* load file contents
   */
  if (!g_file_get_contents (argv[1], &contents, NULL, &error))
    {
      g_printf ("Unable to read file: %s\n", error->message);
      goto err;
    }
  g_assert ((contents == NULL && error != NULL)
            || (contents != NULL && error == NULL));

  if (!g_file_get_contents (argv[2], &generated_etalon, NULL, &error))
    {
      g_printf ("Unable to read file: %s\n", error->message);
      goto err;
    }
  g_assert ((generated_etalon == NULL && error != NULL)
            || (generated_etalon != NULL && error == NULL));

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

  /* Perform several col/row operations  */
  g_printf ("Walk through all objects\n");
  for (it = txr_glob_first (doc); it; it = txr_glob_iter_next (it))
    {
      g_printf ("%s\n", G_OBJECT_TYPE_NAME (*it));

      if (!g_strcmp0 ("TXRLongtable", G_OBJECT_TYPE_NAME (*it)))
        {
          TXRLongtable *ltable = TXR_LONGTABLE (*it);
          guint last_row = txr_col_params_length (txr_longtable_get_col_params (ltable)) - 1;

          if (!g_strcmp0 ("rm0row", argv[3]))
            txr_longtable_remove_col (ltable, 0, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("rm1row", argv[3]))
            txr_longtable_remove_col (ltable, 1, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("rm1000row", argv[3]))
            txr_longtable_remove_col (ltable, 1000, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("rm_last_row", argv[3]))
            txr_longtable_remove_col (ltable, last_row, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_0_0", argv[3]))
            txr_longtable_clone_col (ltable, 0, 0, TRUE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_0_1", argv[3]))
            txr_longtable_clone_col (ltable, 0, 1, FALSE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_1_0", argv[3]))
            txr_longtable_clone_col (ltable, 1, 0, TRUE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_0_last", argv[3]))
            txr_longtable_clone_col (ltable, 0, last_row, FALSE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_last_0", argv[3]))
            txr_longtable_clone_col (ltable, last_row, 0, TRUE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_0_lastp1", argv[3]))
            txr_longtable_clone_col (ltable, 0, last_row + 1, FALSE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_lastp1_0", argv[3]))
            txr_longtable_clone_col (ltable, last_row + 1, 0, TRUE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_0_1000", argv[3]))
            txr_longtable_clone_col (ltable, 0, 1000, FALSE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("clone_1000_0", argv[3]))
            txr_longtable_clone_col (ltable, 1000, 0, TRUE, TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
          else if (!g_strcmp0 ("append_row0", argv[3]))
            {
              TXRSubtable *table = txr_longtable_get_table (ltable);

              if (table)
                {
                  TXRSubtableIter table_it;
                  TXRRow *row;
                  
                  table_it = txr_subtable_first (table);
                  if (table_it && NULL != (row = TXR_ROW (*table_it)))
                    txr_subtable_append (table, txr_row_clone (row),
                                         TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
                }
            }
          else
            {
              g_print ("Incorrect operation '%s' specified.\n", argv[3]);
              goto err;
            }
        }
      else if (!g_strcmp0 ("TXRTabular", G_OBJECT_TYPE_NAME (*it)))
        {
          TXRTabular *tabular = TXR_TABULAR (*it);

          if (!g_strcmp0 ("append_row0", argv[3]))
            {
              TXRSubtable *table = txr_tabular_get_table (tabular);

              if (table)
                {
                  TXRSubtableIter table_it;
                  TXRRow *row;
                  
                  table_it = txr_subtable_first (table);
                  if (table_it && NULL != (row = TXR_ROW (*table_it)))
                    txr_subtable_append (table, txr_row_clone (row),
                                         TXR_TABLE_OP_LINE_STYLE_BORDER | TXR_TABLE_OP_LINE_STYLE_DBLLINES);
                }
            }
        }
    }
  g_printf ("end of objects\n\n");


  /* generate plain-TeX document */
  generated = txr_glob_gen (doc);

  if (!g_strcmp0 (generated_etalon, generated))
    g_printf ("Etalon and generated text are EQUAL ;-)\n");
  else
    g_printf ("Etalon and generated text are NOT EQUAL ;-(\n");

  g_printf ("--- Generated plain-TeX (generated) ---\n%s", generated);

  if (argv[4])
    g_file_set_contents (argv[4], generated, -1, NULL);

err:
//end:
  g_free (contents);
  g_free (generated);
  g_free (generated_etalon);

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
