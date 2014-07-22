using LAview;

public class Main : Object {
	public static int main (string[] args) {

		Intl.setlocale (LocaleCategory.ALL, "");

		assert (args.length == 4 || args.length == 5);

		/* load file contents */
		string contents;
		try {
			FileUtils.get_contents (args[1], out contents);
		} catch (FileError e) {
			stderr.printf ("error: %s\n", e.message);
			return -1;
		}
		assert (contents != null && contents != "");

		/* load etalon */
		string generated_etalon;
		try {
			FileUtils.get_contents (args[2], out generated_etalon);
		} catch (FileError e) {
			stderr.printf ("error: %s\n", e.message);
			return -1;
		}
		assert (generated_etalon != null && generated_etalon != "");

		/* parse TeX */
		Glob doc;
		try {
			doc = LAview.parse (contents);
			stdout.printf ("TeX document successfully parsed\n");

		} catch (Parsers.ParseError e) {
			stderr.printf ("error: %s\n", e.message);
			return -1;
		}

		/* Perform several col/row operations  */
		stdout.printf ("Walk through all objects\n");

		foreach (var subdoc in doc) {
			stdout.printf ("%s\n", subdoc.get_type ().name ());

			if (subdoc.get_type ().name () == "LAviewTableLongtable") {
				var ltable = subdoc as Table.Longtable;

				if (args[3] == "rm0row") {
					ltable.remove_col (0);
				} else if (args[3] == "rm1row") {
					ltable.remove_col (1);
				} else if (args[3] == "rm1000row") {
					ltable.remove_col (1000);
				} else if (args[3] == "rm_last_row") {
					ltable.remove_col (ltable.params.size - 1);
				} else if (args[3] == "clone_0_0") {
					ltable.clone_col (0, 0, true);
				} else if (args[3] == "clone_0_1") {
					ltable.clone_col (0, 0, false);
				} else if (args[3] == "clone_1_0") {
					ltable.clone_col (1, 0, true);
				} else if (args[3] == "clone_0_last") {
					ltable.clone_col (0, ltable.params.size - 1, false);
				} else if (args[3] == "clone_last_0") {
					ltable.clone_col (ltable.params.size - 1, 0, true);
				} else if (args[3] == "clone_0_lastp1") {
					ltable.clone_col (0, ltable.params.size, false);
				} else if (args[3] == "clone_lastp1_0") {
					ltable.clone_col (ltable.params.size, 0, true);
				} else if (args[3] == "clone_0_1000") {
					ltable.clone_col (0, 1000, false);
				} else if (args[3] == "clone_1000_0") {
					ltable.clone_col (1000, 0, true);
				} else if (args[3] == "append_row0") {
					var table = ltable.table;
					table.add (table.get (0).copy () as Table.Row);
				} else {
					stdout.printf ("Incorrect operation '%s' specified.\n", args[3]);
					return -1;
				}
			} else if (subdoc.get_type ().name () == "LAviewTableTabular") {
				if (args[3] == "append_row0") {
					var tabular = subdoc as Table.Tabular;
					var table = tabular.table;
					table.add (table.get (0).copy () as Table.Row);
				}
			}
		}

		/* generate plain-TeX document */
		var generated = doc.generate ();

		if (args[2] != null) {
			try {
				FileUtils.get_contents (args[2], out contents);
			} catch (FileError e) {
				stderr.printf ("error: %s\n", e.message);
				return -1;
			}
		}

		if (contents == generated)
			stdout.printf ("Etalon and generated text are EQUAL ;-)\n");
		else
			stdout.printf ("Etalon and generated text are NOT EQUAL ;-(\n");

		stdout.printf ("--- Generated plain-TeX (generated) ---\n%s", generated);

		if (args[4] != null ) {
			try {
				FileUtils.set_contents (args[4], generated);
			} catch (FileError e) {
				stderr.printf ("error: %s\n", e.message);
				return -1;
			}
		}

		return 0;
	}
}
