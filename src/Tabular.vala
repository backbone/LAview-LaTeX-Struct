namespace LAview {

	namespace Table {

		/**
		 * Tabular in the LaTeX document.
		 *
		 * Specified by '\begin{tabular}' tag in the LaTeX code.
		 */
		public class Tabular : ATable {

			/**
			 * Constructs a new //Tabular// with default parameters.
			 */
			public Tabular () {}

			/**
			 * Width of the table.
			 *
			 * Possible values: [0-9]+(\.[0-9]+)?{bp,cc,cm,dd,em,ex,in,mm,pc,pt,sp,
			 * \textwidth,\columnwidth,\pagewidth,\linewidth,
			 * \textheight,\columnheight,\pageheight,\lineheight}.
			 */
			public string width = "";

			/**
			 * Gets a copy of the //Tabular//.
			 */
			public override IDoc copy () {
				var clone = base.copy () as Tabular;
				clone.width = width;
				return clone;
			}

			/**
			 * Generates LaTeX string for the //Tabular//.
			 */
			public override string generate () {
				var s  = new StringBuilder ();

				if (params.size != 0) {
					s.append_printf ("\\begin{tabular%s}", width != "" ? "*" : "");
					if (width != "")
						s.append_printf ("{%s}", width);
					else if (align != '\0')
						s.append_printf ("[%c]", align);

					s.append_c ('{');
					s.append (params.generate ());
					s.append_c ('}');

					table.style = style;

					s.append (table.generate ());

					s.append_printf ("\\end{tabular%s}", width != "" ? "*" : "");
				}

				return s.str;
			}
		}
	}
}
