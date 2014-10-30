namespace LAview {

	namespace Table {

		/**
		 * Parameter of the table's column.
		 */
		public class ColParam : ADoc {

			/**
			 * Column's alignment.
			 *
			 * Possible values: "c", "r", "l", ">{\centering}p{0.07\paperwidth}", etc.
			 */
			public string align { get; set; default = "c"; }

			/**
			 * Number of left lines.
			 */
			public uint nllines { get; set; default = 1; }

			/**
			 * Number of right lines.
			 */
			public uint nrlines { get; set; }

			/**
			 * Constructs a new ``ColParam`` by it's properties.
			 */
			public ColParam.with_params (uint nllines = 1,
			                             string align = "c",
			                             uint nrlines = 0) {
			    this.nllines = nllines;
			    this.align = align;
			    this.nrlines = nrlines;
			}

			private ColParam () {}

			/**
			 * Gets a copy of the ``ColParam``.
			 */
			public override IDoc copy () {
				return new ColParam.with_params (nllines, align, nrlines);
			}

			/**
			 * Generates LaTeX string for the ``ColParam``.
			 */
			public override string generate () {
				var result = new StringBuilder ();

				for (uint i = 0; i < nllines; ++i)
					result.append_c ('|');

				result.append (align);

				for (uint i = 0; i < nrlines; ++i)
					result.append_c ('|');

				return result.str;
			}
		}
	}
}
