namespace LAview {

	namespace Table {

		/**
		 * List of {@link AddSpace}-s.
		 */
		public class AddSpaces : ADocList<AddSpace> {

			/**
			 * Style of the {@link AddSpace}/{@link Subtable}.
			 */
			public enum Style {

				/**
				 * Default style.
				 */
				DEFAULT = 0,

				/**
				 * Formal style.
				 */
				FORMAL
			}

			/**
			 * Style of the {@link AddSpace}/{@link Subtable}.
			 */
			public Style style { get; set; default = Style.DEFAULT; }

			/**
			 * Constructs a new empty ``AddSpaces``.
			 */
			public AddSpaces () {}

			protected override ADocList<AddSpace> create_default_instance () { return new AddSpaces (); }

			/**
			 * Gets a copy of the ``AddSpaces``.
			 */
			public override IDoc copy () {
				var clone = base.copy () as AddSpaces;
				clone.style = style;
				return clone;
			}

			/**
			 * Generates LaTeX string for the ``AddSpaces``.
			 */
			public override string generate () {
				var result = new StringBuilder ();

				foreach (IDoc dociface in this)
					result.append_printf (style == Style.FORMAL ? "\n\\addlinespace[%s]"
					                                            : "\n\\noalign{\\vskip%s}", dociface.generate ());

				return result.str;
			}
		}
	}
}
