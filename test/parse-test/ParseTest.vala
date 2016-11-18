using LAview;

public class Main : Object {

	static string fname_table = "";
	static string fname_etalon = "";
	static string fname_write = "";

	const OptionEntry [] options = {
		{ "table", 't', 0, OptionArg.FILENAME, ref fname_table, "File with a table", null },
		{ "etalon", 'e', 0, OptionArg.FILENAME, ref fname_etalon, "File with etalon table", null },
		{ "write", 'w', 0, OptionArg.FILENAME, ref fname_write, "File to write", null },
		{ null }
	};

	public static int main (string[] args) {

		Intl.setlocale (LocaleCategory.ALL, "");

		/* commandline arguments processing */
		try {
			var opt_context = new OptionContext ("- tests LaTeX parser");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			stderr.printf ("error: %s\n", e.message);
			stderr.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return -1;
		}

		/* read table */
		if (fname_table == null) {
			stderr.printf ("Specify file with a table or read help (%s --help)", args[0]);
			return -1;
		}

		/* load file contents */
		string contents;
		try {
			FileUtils.get_contents (fname_table, out contents);
		} catch (FileError e) {
			stderr.printf ("error: %s\n", e.message);
			return -1;
		}

		/* parse TeX */
		Glob doc;
		try {
			doc = LAview.parse (contents);
			stdout.printf ("TeX document successfully parsed\n");

		} catch (Parsers.ParseError e) {
			stderr.printf ("Error parsing TeX document: %s\n", e.message);
			return -1;
		}

		/* list all objects */
		stdout.printf ("list all objects\n");
		foreach (var subdoc in doc) {
			stdout.printf ("%s\n", subdoc.get_type ().name ());

			if (subdoc is Table.Tabular || subdoc is Table.Longtable) {

			    unowned Table.Subtable subtable = null;

				if (subdoc is Table.Tabular)
					subtable = (subdoc as Table.Tabular).table;
				else
					subtable = (subdoc as Table.Longtable).table;

				foreach (var row in subtable) {
					foreach (var cell in row) {
						var glob = cell.contents;

						foreach (var glob_subdoc in glob) {
							if (!( glob_subdoc is LAview.Text )) {
								stdout.printf ("  %s\n", glob_subdoc.get_type ().name ());
							}
						}
					}
				}
			}
		}
		stdout.printf ("end of objects\n\n");

		/* walk through all objects */
		stdout.printf ("Walk through all objects\n");
		foreach (var subdoc in doc) {
			stdout.printf ("%s\n", subdoc.get_type ().name ());

			if (subdoc is LAview.Graphics) {
				var graphics = subdoc as Graphics;
				stdout.printf ("  width=%f%s, height=%f%s, path=%s,\n  gen()=%s\n",
				               graphics.width, graphics.width_unit, graphics.height, graphics.height_unit,
				               graphics.path, graphics.generate ());

				graphics = graphics.copy () as Graphics;
				graphics.width = 1;
				graphics.width /= 2;
				graphics.width_unit = "pt";
				graphics.height *= 2;
				graphics.height_unit = "dd";
				stdout.printf ("resized gen() = %s\n", graphics.generate ());
			}
		}
		stdout.printf ("end of objects\n\n");

		/* generate plain-TeX document */
		var generated = doc.generate ();

		/* load etalon file */
		if (fname_etalon != null) {
			try {
				FileUtils.get_contents (fname_etalon, out contents);
			} catch (FileError e) {
				stderr.printf ("error: %s\n", e.message);
				return -1;
			}
		}

		if (contents == generated)
			stdout.printf ("Original and generated text are EQUAL ;-)\n");
		else
			stdout.printf ("Original and generated text are NOT EQUAL ;-(\n");

		stdout.printf ("--- Generated plain-TeX (generated) ---\n%s", generated);

		/* write to file */
		if (fname_write != null )
			try {
				FileUtils.set_contents (fname_write, generated);
			} catch (FileError e) {
				stderr.printf ("error: %s\n", e.message);
				return -1;
			}

		return 0;
	}
}
