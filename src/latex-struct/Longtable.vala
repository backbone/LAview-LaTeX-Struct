namespace LAview {

	namespace Table {

		/**
		 * Longtable in the LaTeX document.
		 *
		 * Specified by '\begin{longtable}' tag in the LaTeX code.
		 */
		public class Longtable : ATable {

			/**
			 * Constructs a new ``Longtable`` with default parameters.
			 */
			public Longtable () {}

			/**
			 * Gets a copy of the ``Longtable``.
			 */
			public override IDoc copy () {
				return base.copy ();
			}

			/**
			 * Generates LaTeX string for the ``Longtable``.
			 */
			public override string generate () {
				var s = new StringBuilder ();

				if (params.size == 0) return "";

				s.append ("\\begin{longtable}");

				if (align != '\0')
					s.append_printf ("[%c]", align);

				s.append_c ('{');
				s.append (params.generate ());
				s.append_c ('}');

				first_header.style = style;
				header.style = style;
				footer.style = style;
				last_footer.style = style;
				table.style = style;

				string tmps;
				tmps = first_header.generate ();
				if (tmps != "") s.append (tmps + "\\endfirsthead");
				tmps = header.generate ();
				if (tmps != "") s.append (tmps + "\\endhead");
				tmps = footer.generate ();
				if (tmps != "") s.append (tmps + "\\endfoot");
				tmps = last_footer.generate ();
				if (tmps != "") s.append (tmps + "\\endlastfoot");
				s.append (table.generate ());

				s.append ("\\end{longtable}");

				return s.str;
			}
		}
	}
}
