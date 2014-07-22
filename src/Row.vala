namespace LAview {

	namespace Table {

		/**
		 * Row in the {@link Subtable}.
		 */
		public class Row : ADocList {

			/**
			 * Expands {@link AddSpaces.Style}.
			 */
			public enum Style {

				/**
				 * Default style.
				 */
				DEFAULT = 0,

				/**
				 * Formal style for the first //Row// in the {@link Subtable}.
				 */
				FORMAL_FIRST,

				/**
				 * Formal style for the middle //Row// in the {@link Subtable}.
				 */
				FORMAL_REST,

				/**
				 * Formal style for the last //Row// in the {@link Subtable}.
				 */
				FORMAL_LAST,

				/**
				 * Formal style for a single //Row// in the {@link Subtable}.
				 */
				FORMAL_SINGLE
			}

			/**
			 * Style of any operation on {@link ATable}/{@link Subtable} or //Row//
			 * for lines preserving/creation.
			 */
			public enum OpLineStyle {

				/**
				 * Do not anything with lines, "store as is".
				 */
				DEFAULT = 0,

				/**
				 * Preserve vertical border.
				 */
				HBORDER = 1,

				/**
				 * Preserve horizontal border.
				 */
				VBORDER = 2,

				/**
				 * Preserve both vertical and horizontal borders.
				 */
				BORDER = 3,

				/**
				 * Remove horizontal double lines.
				 */
				HDBLLINES = 4,

				/**
				 * Remove vertical double lines.
				 */
				VDBLLINES = 8,

				/**
				 * Remove both horizontal and vertical double lines.
				 */
				DBLLINES = 12,

				/**
				 * Preserve any borders and remove any double lines.
				 */
				BORDER_DBLLINES = 15,
			}

			/**
			 * Any text before the //Row//.
			 */
			public string before = "";

			/**
			 * Style of any operation on {@link ATable}/{@link Subtable} or //Row//
			 * for lines preserving/creation.
			 */
			public Style style;

			/**
			 * Top vertical spaces.
			 */
			public AddSpaces top = new AddSpaces ();

			/**
			 * Bottom vertical spaces.
			 */
			public AddSpace bottom = new AddSpace.with_params ("");

			/**
			 * Vertical spaces inside the {@link Subtable}
			 */
			public AddSpaces between = new AddSpaces ();

			/**
			 * Type of horizontal lines for the //Row//.
			 */
			public enum LinesType {

				/**
				 * //Row// has no horizontal lines.
				 */
				NONE = 0,

				/**
				 * //Row// has continuous horizontal line on the top.
				 */
				HLINE,

				/**
				 * //Row// has noncontinuous horizontal line on the top.
				 */
				CLINES
			}

			/**
			 * Constructs a new empty //Row//.
			 */
			public Row () {}

			protected override ADocList create_default_instance () { return new Row (); }

			/**
			 * Gets a copy of the //Row//.
			 */
			public override IDoc copy () {
				var clone = base.copy () as Row;
				clone.before = before;
				clone.style = style;
				clone.top = top;
				clone.bottom = bottom.copy () as AddSpace;
				clone.between = between.copy () as AddSpaces;
				return clone;
			}

			enum Where { SEARCH_BEGIN = 0, SEARCH_END = 1 }

			string row_to_lines (bool overline) {
				var s = new StringBuilder ();
				var lcount_row = copy () as Row;
				LinesType lines_type = LinesType.HLINE;

				while (lines_type != LinesType.NONE) {
					lines_type = LinesType.NONE;

					foreach (var cell in lcount_row as Gee.ArrayList<Cell>) {
						if (overline && cell.noverlines != 0
						    || !overline && cell.nunderlines != 0) {
							if (lines_type == LinesType.NONE) {
								if (lcount_row.index_of (cell) == 0)
									lines_type = LinesType.HLINE;
								else
									lines_type = LinesType.CLINES;
							}
						} else {
							if (lines_type == LinesType.HLINE)
								lines_type = LinesType.CLINES;
						}
					}

					if (lines_type != LinesType.NONE)
						s.append_c ('\n');

					if (lines_type == LinesType.HLINE) {
						string line_style = "";

						switch (lcount_row.style) {
							case Style.FORMAL_FIRST:
								line_style = overline ? "\\toprule" : "\\midrule";
								break;
							case Style.FORMAL_LAST:
								line_style = overline ? "\\midrule" : "\\bottomrule";
								break;
							case Style.FORMAL_SINGLE:
								line_style = overline ? "\\toprule" : "\\bottomrule";
								break;
							case Style.FORMAL_REST:
								line_style = "\\midrule";
								break;
							default:
								line_style = "\\hline";
								break;
						}

						s.append (line_style);
					} else if (lines_type == LinesType.CLINES) {
						var clines_added = false;

						uint cline_begin = 0, cline_end = 0;
						var where = Where.SEARCH_BEGIN;
						for (var idx = 0, max_idx = lcount_row.size; idx < max_idx; ++idx) {
							var cell = lcount_row[idx] as Cell;

							switch (where) {
								case Where.SEARCH_BEGIN:
									if (overline && cell.noverlines != 0
									    || !overline && cell.nunderlines != 0) {

										if (idx + 1 < max_idx
										    && (overline && (lcount_row[idx + 1] as Cell).noverlines != 0
										        || !overline && (lcount_row[idx + 1] as Cell).nunderlines != 0)) {
											cline_end = cline_begin + cell.ncells;
											where = Where.SEARCH_END;
										} else {
											if (clines_added)
												s.append_c (' ');
											s.append_printf (lcount_row.style != Style.DEFAULT ?
											                 "\\cmidrule{%d-%d}" : "\\cline{%d-%d}",
											                 cline_begin + 1,
											                 cline_begin + cell.ncells);
											cline_begin += cell.ncells;
											clines_added = true;
										}
									} else {
										cline_begin += cell.ncells;
									}
									break;
								case Where.SEARCH_END:
									if (idx + 1 >= max_idx
									    || overline && (lcount_row[idx + 1] as Cell).noverlines == 0
									    || !overline && (lcount_row[idx + 1] as Cell).nunderlines == 0) {
										if (clines_added)
											s.append_c (' ');
											s.append_printf (lcount_row.style != Style.DEFAULT ?
											                 "\\cmidrule{%d-%d}" : "\\cline{%d-%d}",
											                 cline_begin + 1,
											                 cline_end + cell.ncells);
											cline_begin = cline_end + cell.ncells;
											clines_added = true;
											where = Where.SEARCH_BEGIN;
									} else {
										cline_end += cell.ncells;
									}
									break;
								default:
									assert (where == Where.SEARCH_BEGIN);
									break;
							}
						}
					}

					foreach (var cell in lcount_row as Gee.ArrayList<Cell>) {
						if (overline && cell.noverlines != 0
						    || !overline && cell.nunderlines != 0) {
							if (overline)
								--cell.noverlines;
							else
								--cell.nunderlines;
						}
					}
				}

				return s.str;
			}

			void process_opline_insert (Cell        cell,
			                            int         index,
			                            OpLineStyle line_style) {
				if (size == 0) return;

				if ((line_style & OpLineStyle.VBORDER) != 0) {
					if (index < 0 || index >= size) {
						var last_cell = get (size - 1) as Cell;
						if (last_cell.multitype == Cell.Multitype.MULTICOL
						    || last_cell.multitype == Cell.Multitype.MULTICOLROW)
							cell.nrlines = last_cell.nrlines;
					} else if (index == 0) {
						if ((get (index) as Cell).multitype == Cell.Multitype.MULTICOL
						    || (get (index) as Cell).multitype == Cell.Multitype.MULTICOLROW)
							cell.nllines = (get (index) as Cell).nllines;
					}
				}

				if ((line_style & OpLineStyle.VDBLLINES) != 0) {
					var prev_index = index - 1;

					if (index >= 0 && index < size) { // next == [index]
						var idx_cell = get (index) as Cell;
						if (idx_cell.multitype == Cell.Multitype.MULTICOL
						    || idx_cell.multitype == Cell.Multitype.MULTICOLROW ) {
							idx_cell.nllines = cell.nrlines != 0 || idx_cell.nllines != 0 ? 1 : 0;
							cell.nrlines = 0;
						}
					} else {
						prev_index = size - 1;
					}

					if (prev_index >= 0 && prev_index < size
					    && (cell.multitype == Cell.Multitype.MULTICOL
					                   || cell.multitype == Cell.Multitype.MULTICOLROW)) {
					    var idx_cell = get (prev_index) as Cell;
						cell.nllines = idx_cell.nrlines != 0 || cell.nllines != 0 ? 1 : 0;
						idx_cell.nrlines = 0;
					}
				}
			}

			/**
			 * Removes a {@link Cell} from the //Row//.
			 *
			 * @param cell {@link Cell} to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new bool remove (Cell cell, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				var index = index_of (cell);
				if (index < 0 || index >= size) return false;
				remove_at (index);
				return true;
			}

			/**
			 * Removes a {@link Cell} from the //Row// at specified position.
			 *
			 * @param index position of the {@link Cell} to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new Cell remove_at (int index, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
			    var cell = get (index) as Cell;
				if ((line_style & OpLineStyle.VBORDER) != 0
				    && (cell.multitype == Cell.Multitype.MULTICOL
				        || cell.multitype == Cell.Multitype.MULTICOLROW)) {
					if (size > 1) {
						if (index == 0)
							(get (1) as Cell).nllines = cell.nllines;
						else if (index == size - 1)
							(get (size - 2) as Cell).nrlines = cell.nrlines;
					}

					if ((line_style & OpLineStyle.VDBLLINES) != 0) {
						if (index > 0 && index + 1 < size) {
							var prev = get (index - 1) as Cell,
							    next = get (index + 1) as Cell;
							    if (next.multitype == Cell.Multitype.MULTICOL
							        || next.multitype == Cell.Multitype.MULTICOLROW) {
								next.nllines = prev.nrlines != 0 || next.nllines != 0 ? 1 : 0;
								prev.nrlines = 0;
							}
						}
					}
				}

				return base.remove_at (index) as Cell;
			}

			/**
			 * Inserts a {@link Cell} to the //Row// to specified position.
			 *
			 * @param index position to insert the {@link Cell}.
			 * @param cell {@link Cell} to insert.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new void insert (int index, Cell cell, OpLineStyle line_style = OpLineStyle.BORDER_DBLLINES) {
				process_opline_insert (cell, index, line_style);
				base.insert (index, cell);
			}

			/**
			 * Adds a {@link Cell} to the //Row//.
			 *
			 * @param cell {@link Cell} to add.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new bool add (Cell cell, OpLineStyle line_style = OpLineStyle.BORDER_DBLLINES) {
				process_opline_insert (cell, -1, line_style);
				return base.add (cell);
			}

			/**
			 * Generates LaTeX string for the //Row//.
			 */
			public override string generate () {
				var s = new StringBuilder ();

				/* {c,h}lines */
				string tmps = row_to_lines (true);
				s.append (tmps);

				/* "top" additional space */
				if (top.size != 0) {
					top.style = style == Style.DEFAULT ? AddSpaces.Style.DEFAULT
					                                   : AddSpaces.Style.FORMAL;
					s.append (top.generate ());
				}

				/* spaces before self */
				if (before != "")
					s.append (before);

				/* rows contents */
				foreach (var cell in this) {
					if (this.index_of (cell) != 0) s.append_c ('&');
					s.append (cell.generate ());
				}

				s.append ("\\tabularnewline");

				/* "bottom" additional space */
				if ((tmps = bottom.generate ()) != "") {
					if (style == Style.DEFAULT)
						s.append_printf ("[%s]", tmps);
					else
						s.append_printf ("\\addlinespace[%s]", tmps);
				}

				/* "between" additional space */
				if (between.size != 0) {
					between.style = style == Style.DEFAULT ? AddSpaces.Style.DEFAULT
					                                       : AddSpaces.Style.FORMAL;
					s.append (between.generate ());
				}

				/* {c,h}lines */
				tmps = row_to_lines (false);
				s.append (tmps);

				return s.str;
			}
		}
	}
}
