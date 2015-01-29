using LAview;

public class Main : Object {
	static string fname_limits = "";
	static string fname_table = "";
	static string fname_etalon = "";
	static string fname_write = "";

	const OptionEntry [] options = {
		{ "limits", 'l', 0, OptionArg.FILENAME, ref fname_limits, "File with limits", null },
		{ "table", 't', 0, OptionArg.FILENAME, ref fname_table, "File with a table", null },
		{ "etalon", 'e', 0, OptionArg.FILENAME, ref fname_etalon, "File with etalon table", null },
		{ "write", 'w', 0, OptionArg.FILENAME, ref fname_write, "File to write", null },
		{ null }
	};

	public static int main (string [] args) {

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

		/* read limits */
		if (fname_limits == null) {
			stderr.printf ("Specify file with limits\n");
			return -1;
		}

		var stream = FileStream.open (fname_limits, "r");
		if (stream == null) {
			stdout.puts ("Cann't open limits file\n");
			return -1;
		}

		uint lim[3] = { 0, 0, 0};
		var limits = new List<Table.ATable.SplitLimit?> ();

		while (3 == stream.scanf ("%u %u %u", out lim[0], out lim[1], out lim[2])) {
			var split_lim = Table.ATable.SplitLimit ();
			split_lim.first = lim[0];
			split_lim.last = lim[1];
			split_lim.max_cols = lim[2];
			limits.append (split_lim);
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

		/* find a longtable object */
		Table.Longtable table = null;
		foreach (var subdoc in doc) {
			if (subdoc is Table.Longtable) {
				table = subdoc as Table.Longtable;
				break;
			}
		}

		if (table == null) {
			stderr.puts ("longtable object not found\n");
			return -1;
		}

		/* split the table */
		try {
			table.split (doc, limits);
		} catch (Table.SplitError e) {
			stderr.puts (e.message);
			return -1;
		}

		/* load etalon file */
		if (fname_etalon != null) {
			try {
				FileUtils.get_contents (fname_etalon, out contents);
			} catch (FileError e) {
				stderr.printf ("error: %s\n", e.message);
				return -1;
			}
		}

		/* generate */
		var generated = doc.generate ();

		/* compare with an etalon */
		if (contents == generated)
			stdout.puts ("Etalon and generated text are EQUAL ;-)\n");
		else
			stdout.puts ("Etalon and generated text are NOT EQUAL ;-(\n");

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
