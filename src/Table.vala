namespace LAview {

	/**
	 * Tables and its components in the document.
	 */
	namespace Table {

		/**
		 * Any Table in the LaTeX document.
		 */
		public abstract class ATable : ADoc {

			/**
			 * Align of the table.
			 *
			 * Possible values: 't', 'b'.
			 */
			public char align;

			/**
			 * Style of the {@link AddSpace}/{@link Subtable}.
			 */
			public AddSpaces.Style style;

			/**
			 * Parameters of columns.
			 */
			public ColParams params = new ColParams ();

			/**
			 * Main sutable.
			 */
			public Subtable table = new Subtable ();

			/**
			 * First Header.
			 */
			public Subtable first_header = new Subtable ();

			/**
			 * Header.
			 */
			public Subtable header = new Subtable ();

			/**
			 * Footer.
			 */
			public Subtable footer = new Subtable ();

			/**
			 * Last Footer.
			 */
			public Subtable last_footer = new Subtable ();

			protected ATable () {}

			/**
			 * Gets a copy of the ``ATable``.
			 */
			public override IDoc copy () {
				var clone = Object.new (this.get_type ()) as ATable;

				clone.align = align;
				clone.style = style;
				clone.params = params.copy () as ColParams;
				clone.table = table.copy () as Subtable;
				clone.first_header = first_header.copy () as Subtable;
				clone.header = header.copy () as Subtable;
				clone.footer = footer.copy () as Subtable;
				clone.last_footer = last_footer.copy () as Subtable;

				return clone;
			}

			/**
			 * Generates LaTeX string for the ``ATable``.
			 */
			public override string generate () {
				assert (false);
				return "";
			}

			/**
			 * Removes {@link Cell}-s in the column by specified index.
			 *
			 * @param index index of column to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public void remove_col (int index, Row.OpLineStyle line_style
			                            = Row.OpLineStyle.BORDER_DBLLINES) {
				if (index >= params.size) return;

				var param = params.get (index) as ColParam;

				if ((line_style & Row.OpLineStyle.VBORDER) != 0 && param.align != "") {
					if (params.size > 1) {
						if (index == 0)
							(params.get (1) as ColParam).nllines = param.nllines;
						else if (index == params.size - 1)
							(params.get (params.size - 2) as ColParam).nrlines = param.nrlines;
					}
				}

				if ((line_style & Row.OpLineStyle.VDBLLINES) != 0) {
					if (index > 0 && index < params.size - 1) {
						var prev = params.get (index - 1) as ColParam,
						    next = params.get (index + 1) as ColParam;
					    next.nllines = prev.nrlines != 0 || next.nllines != 0 ? 1 : 0;
					    prev.nrlines = 0;
					}
				}

				params.remove_at (index);

				first_header.remove_col (index, line_style);
				header.remove_col (index, line_style);
				footer.remove_col (index, line_style);
				last_footer.remove_col (index, line_style);
				table.remove_col (index, line_style);
			}

			/**
			 * Clones column of {@link Cell}-s by specified indexes.
			 *
			 * @param src_index source position of the column.
			 * @param dest_index destination to clone the column.
			 * @param multicol preserve multicolumn property or not.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public void clone_col (int src_index, int dest_index, bool multicol,
			                           Row.OpLineStyle line_style
			                           = Row.OpLineStyle.BORDER_DBLLINES) {
				if (src_index >= params.size || dest_index > params.size) return;

				var param = params.get (src_index).copy () as ColParam;

				if ((Row.OpLineStyle.VBORDER & line_style) != 0) {
					if (dest_index >= params.size) {
						var last_param = params.get (params.size - 1) as ColParam;
						if (last_param.align != "")
							param.nrlines = last_param.nrlines;
					} else {
						var first_param = params.get (0) as ColParam;
						if (dest_index == 0 && first_param.align != "")
							param.nllines = first_param.nllines;
					}
				}

				if ((Row.OpLineStyle.VDBLLINES & line_style) != 0) {
					int prev_index;
					bool prev_edit = false;

					if (dest_index < params.size) {
						prev_index = dest_index > 0 ? dest_index - 1 : 0;
						if (prev_index > 0) prev_edit = true;
						var dest_param = params.get (dest_index) as ColParam;
						dest_param.nllines = param.nrlines != 0 || dest_param.nllines != 0 ? 1 : 0;
						param.nrlines = 0;
					} else {
						prev_edit = true;
						prev_index = params.size - 1;
					}

					if (prev_edit) {
						var prev_param = params.get (prev_index) as ColParam;
						param.nllines = prev_param.nrlines != 0 || param.nllines != 0 ? 1 : 0;
						prev_param.nrlines = 0;
					}
				}

				params.insert (dest_index, param);

				first_header.clone_col (src_index, dest_index, multicol, line_style);
				header.clone_col (src_index, dest_index, multicol, line_style);
				footer.clone_col (src_index, dest_index, multicol, line_style);
				last_footer.clone_col (src_index, dest_index, multicol, line_style);
				table.clone_col (src_index, dest_index, multicol, line_style);
			}
		}
	}
}
