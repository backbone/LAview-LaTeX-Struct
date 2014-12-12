namespace LAview {

	namespace Table {

		/**
		 * Cell of any table.
		 */
		public class Cell : ADoc {

			/**
			 * Number of occupied cells.
			 */
			public uint ncells { get; set; default = 1; }

			/**
			 * Cell's alignment.
			 *
			 * Possible values: "c", "r", "l", ">{\centering}p{0.07\paperwidth}", etc.
			 */
			public string align { get; set; default = ""; }

			/**
			 * Number of left lines.
			 */
			public uint nllines { get; set; }

			/**
			 * Number of right lines.
			 */
			public uint nrlines { get; set; }

			/**
			 * Number of top lines.
			 */
			public uint noverlines { get; set; }

			/**
			 * Number of bottom lines.
			 */
			public uint nunderlines { get; set; }

			/**
			 * Contents of the cell.
			 */
			public Glob contents { get; set; default = new Glob (); }

			/**
			 * Any text before the cell.
			 */
			public string before { get; set; default = ""; }

			/**
			 * Any text after the cell.
			 */
			public string after { get; set; default = ""; }

			/**
			 * Type of a cell indicates how much columns/rows does it occupy.
			 */
			public enum Multitype {

				/**
				 * Standard cell.
				 */
				SIMPLE = 0,

				/**
				 * Cell occupies several columns.
				 */
				MULTICOL,

				/**
				 * Cell occupies several rows.
				 */
				MULTIROW,

				/**
				 * Cell occupies several columns and rows.
				 */
				MULTICOLROW
			}

			Multitype _multitype;

			/**
			 * Type of a cell indicates how much columns/rows does it occupy.
			 */
			public Multitype multitype {
				set {
					if (value != Multitype.MULTICOL && value != Multitype.MULTICOLROW)
						nllines = nrlines = 0;
					_multitype = value;
				}
				get {
					return _multitype;
				}
			}

			/**
			 * Constructs a new ``Cell`` based on it's properties.
			 */
			public Cell.with_params (Multitype multitype, uint ncells, uint nllines, string align,
			                         uint nrlines, uint noverlines, uint nunderlines,
			                         Glob contents, string before, string after) {
			    this.ncells = ncells;
			    this.nllines = nllines;
			    this.align = align;
			    this.nrlines = nrlines;
			    this.noverlines = noverlines;
			    this.nunderlines = nunderlines;
			    this.contents = contents.copy () as Glob;
			    this.before = before;
			    this.after = after;
			    this.multitype = multitype;
			}

			private Cell () {}

			/**
			 * Gets a copy of the ``Cell``.
			 */
			public override IDoc copy () {
				return new Cell.with_params (multitype, ncells, nllines, align, nrlines,
				                             noverlines, nunderlines, contents, before, after);
			}

			/**
			 * Generates LaTeX string for the ``Cell``.
			 */
			public override string generate () {
				var result = new StringBuilder (before),
					params = new StringBuilder (),
					contents = this.contents.generate ();

				if (align != "") {
					for (uint i = 0; i < nllines; ++i) params.append_c ('|');
					params.append (align);
					for (uint i = 0; i < nrlines; ++i) params.append_c ('|');
				}

				switch (multitype) {
					case Multitype.SIMPLE:
						result.append (contents);
						break;
					case Multitype.MULTICOL:
						result.append_printf ("\\multicolumn{%u}{%s}{%s}",
						                      ncells, params.str, contents);
						break;
					case Multitype.MULTIROW:
						result.append_printf ("\\multirow{%u}{%s}{%s}",
					                          ncells, params.str, contents);
					    break;
					case Multitype.MULTICOLROW:
						result.append_printf ("\\multicolumn{1}{%s}{\\multirow{%u}{*}{%s}}",
					                          params.str, ncells, contents);
					    break;
					default:
						assert (multitype == Multitype.SIMPLE);
						break;
				}

				result.append (after);

				return result.str;
			}
		}
	}
}
