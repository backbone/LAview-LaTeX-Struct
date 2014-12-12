namespace LAview {

	/**
	 * Tables and its components in the document.
	 */
	namespace Table {

		/**
		 * Any error at ``ATable`` splitting.
		 */
		public errordomain SplitError {

			/**
			 * ``ATable`` isn't a child of the {@link Glob}.
			 */
			ISNT_CHILD,

			/**
			 * Any errors in the split indexes.
			 */
			INDEX_ERROR,

			/**
			 * Any other error.
			 */
			OTHER,
		}

		/**
		 * Any Table in the LaTeX document.
		 */
		public abstract class ATable : ADoc {

			/**
			 * Align of the table.
			 *
			 * Possible values: 't', 'b'.
			 */
			public char align { get; set; }

			/**
			 * Style of the {@link AddSpace}/{@link Subtable}.
			 */
			public AddSpaces.Style style { get; set; }

			/**
			 * Parameters of columns.
			 */
			public ColParams params { get; set; default = new ColParams (); }

			/**
			 * Main sutable.
			 */
			public Subtable table { get; set; default = new Subtable (); }

			/**
			 * First Header.
			 */
			public Subtable first_header { get; set; default = new Subtable (); }

			/**
			 * Header.
			 */
			public Subtable header { get; set; default = new Subtable (); }

			/**
			 * Footer.
			 */
			public Subtable footer { get; set; default = new Subtable (); }

			/**
			 * Last Footer.
			 */
			public Subtable last_footer { get; set; default = new Subtable (); }

			protected ATable () {}

			/**
			 * Gets a copy of the ``ATable``.
			 */
			public override IDoc copy () {
				var clone = Object.new (get_type ()) as ATable;

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

			/**
			 * Bounds of the ``ATable`` to split.
			 */
			public struct SplitLimit {

				/**
				 * First column index [0; last].
				 */
				uint first;

				/**
				 * Last column index [first; ncols - 1].
				 */
				uint last;

				/**
				 * Maximum of columns per page [1; ncols].
				 */
				uint max_cols;
			}

			bool check_limits (Array<SplitLimit?> sorted_limits) {
				/* check nearby limits */
				for (var i = 1; i < sorted_limits.length; ++i)
					if (sorted_limits.index (i - 1).last >= sorted_limits.index (i).first
					    || sorted_limits.index (i).first > sorted_limits.index (i).last)
						return false;

				/* check limits of the first and last elements */
				if (sorted_limits.index (0).first > sorted_limits.index (0).last
				    || params.size <= sorted_limits.index (sorted_limits.length - 1).last)
					return false;

				return true;
			}

			uint [] get_indexes (Array<SplitLimit?> sorted_limits) {
				var lim_indexes = new uint[sorted_limits.length];
				for (var i = 0; i < sorted_limits.length; ++i)
					lim_indexes[i] = sorted_limits.index (i).first;
				return lim_indexes;
			}

			ATable? split_table (Array<SplitLimit?> sorted_limits, uint [] lim_indexes,
				Row.OpLineStyle line_style) {

				var return_table = copy () as ATable;
				bool split_finish = true;

				/* removing spare columns */
				for (uint i = sorted_limits.length - 1; i < sorted_limits.length; --i) { // group
					for (uint j = sorted_limits.index (i).last;
					     j >= lim_indexes[i] + sorted_limits.index (i).max_cols
					     && j <= sorted_limits.index (i).last; --j)
						return_table.remove_col ((int)j, line_style);

					for (uint j = lim_indexes[i] - 1; j >= sorted_limits.index (i).first && j < lim_indexes[i]; --j)
						return_table.remove_col ((int)j, line_style);

					/* count indexes */
					if (lim_indexes[i] <= sorted_limits.index (i).last) {
						split_finish = false;
						lim_indexes[i] += sorted_limits.index (i).max_cols;
					}
				}

				/* did any indexes updated */
				if (split_finish)
					return null;

				return return_table;
			}

			/**
			 * Split an ``ATable`` into several ``ATable``s by columns according to the limits.
			 *
			 * For example: table<<BR>>
			 * ``[fix1 fix2 colA1 colA2 colA3 colA4 colA5 fix3 fix4 colB1 colB2 colB3 colB4 fix5 fix6]``<<BR>>
			 * with limits { {2, 6, 2}, {9, 12, 3} }<<BR>>
			 * will be splitted into 3 tables<<BR>>
			 * [fix1 fix2 colA1 colA2 fix3 fix4 colB1 colB2 colB3 fix5 fix6]<<BR>>
			 * [fix1 fix2 colA3 colA4 fix3 fix4 colB4 fix6]<<BR>>
			 * [fix1 fix2 colA5 fix3  fix4 fix6]<<BR>>
			 * 3rd param 'limits'. For all elements following conditions should be satisfied.
			 * last[i] < first[i+1], 0 <= first[i] <= last[i] <= ncols-1, 1 <= max_cols <= ncols.
			 *
			 * @param glob {@link Glob} document with a ``ATable``.
			 * @param limits array of {@link SplitLimit}s.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 *
			 * @return number of ``ATable``s the table splitted to.
			 */
			public uint split (Glob glob, Array<SplitLimit?> limits,
			                   Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) throws SplitError {
				/* is table a child of glob */
				var glob_index = glob.index_of (this);
				if (glob_index == -1)
					throw new SplitError.ISNT_CHILD (_("2nd param (ATable) isn't a child of the 1st (Glob)."));

				/* sorting limits */
				var sorted_limits = new Array<SplitLimit?>.sized (false, false, sizeof (SplitLimit), limits.length);
				sorted_limits.append_vals (limits.data, limits.length);

				sorted_limits.sort ((ref a, ref b) => {
										if (a.first < b.first) return -1;
										if (a.first > b.first) return 1;
										return 0;
									});

				/* checking limits for intersections */
				if (!check_limits (sorted_limits))
					throw new SplitError.INDEX_ERROR (_("3rd param (limits) is incorrect. Read the manual."));

				/* split the table on several longtables inserting them before glob_index + 1 */
				var lim_indexes = get_indexes (sorted_limits);

				ATable temp_table;
				uint result = 0;
				var part_idx = glob_index + 1;
				while (null != (temp_table = split_table (sorted_limits, lim_indexes, line_style))) {
					glob.insert (part_idx++, temp_table);
					++result;
				}

				/* remove table from the doc */
				if (result != 0)
					glob.remove_at (glob_index);
				else
					throw new SplitError.OTHER (_("Cann't split the table. Read the manual."));

			    return result;
			}
		}
	}
}
