namespace LAview {

	namespace Table {

		/**
		 * Subtable in the {@link ATable}.
		 */
		public class Subtable : ADocList {

			/**
			 * Caption of the table.
			 */
			public Text caption { get; set; default = new Text(""); }

			/**
			 * Any text before the ``Subtable``.
			 */
			public string before { get; set; default = ""; }

			/**
			 * Any text after the ``Subtable``.
			 */
			public string after { get; set; default = ""; }

			/**
			 * Style of the table (Default/Formal).
			 */
			public AddSpaces.Style style { get; set; }

			protected override ADocList create_default_instance () { return new Subtable (); }

			/**
			 * Constructs a new empty ``Subtable``.
			 */
			public Subtable () {}

			/**
			 * Gets a copy of the ``Subtable``.
			 */
			public override IDoc copy () {
				var clone = base.copy () as Subtable;
				clone.caption = caption;
				clone.before = before;
				clone.after = after;
				clone.style = style;
				return clone;
			}

			void process_border_lines (Row dest_row, Row src_row, bool is_first) {
				var si = 0, di = 0, max_si = src_row.size, max_di = dest_row.size;
				uint dncells = 0, sncells = 0;

				while (si < max_si && di < max_di) {
					var scell = src_row.get (si) as Cell;
					var dcell = dest_row.get (di) as Cell;

					dncells = dncells != 0 ? dncells
					        : uint.max (1, dcell.multitype == Cell.Multitype.MULTICOL ?
					                    dcell.ncells : 1);
					sncells = sncells != 0 ? sncells
					        : uint.max (1, scell.multitype == Cell.Multitype.MULTICOL ?
					                    scell.ncells : 1);

					if (is_first)
						dcell.noverlines = scell.noverlines;
					else
						dcell.nunderlines = scell.nunderlines;

					if (--dncells == 0) ++di;
					if (--sncells == 0) ++si;
				}
			}

			void process_double_lines (Row top_row, Row bottom_row) {
				var ti = 0, bi = 0, max_ti = top_row.size, max_bi = bottom_row.size;
				uint tncells = 0, bncells = 0;

				while (ti < max_ti && bi < max_bi) {
					var tcell = top_row.get (ti) as Cell;
					var bcell = bottom_row.get (bi) as Cell;

					tncells = tncells != 0 ? tncells
					        : uint.max (1, tcell.multitype == Cell.Multitype.MULTICOL ?
					                    1 : 0) != 0 ? tcell.ncells : 1;
					bncells = bncells != 0 ? bncells
					        : uint.max (1, bcell.multitype == Cell.Multitype.MULTICOL ?
					                    bcell.ncells : 1);

					bcell.noverlines = tcell.nunderlines + bcell.noverlines != 0 ? 1 : 0;
					tcell.nunderlines = 0;

					if (--tncells == 0) ++ti;
					if (--bncells == 0) ++bi;
				}
			}

			void process_opline_insert (Row row, Row? row2, Row.OpLineStyle line_style) {
				if (size == 0) return;

				if ((line_style & Row.OpLineStyle.HBORDER) != 0) {
					if (row2 == null)
						process_border_lines (row, get (size - 1) as Row, false);
					else if (index_of (row2) == 0)
						process_border_lines (row, row2, true);
				}

				if ((line_style & Row.OpLineStyle.HDBLLINES) != 0) {
					Row prev = null;

					if (row2 != null) { // next == iter
						prev = get (index_of (row2) - 1) as Row;
						process_double_lines (row, row2);
					} else {
						prev = get (size - 1) as Row;
					}

					if (prev != null)
						process_double_lines (prev, row);
				}
			}

			/**
			 * Removes {@link Cell}-s in the column by specified index.
			 *
			 * @param index index of column to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public void remove_col (uint index, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				foreach (Row row in this as Gee.ArrayList<Row>) {
					uint mindx = 0;

					foreach (var cell in row as Gee.ArrayList<Cell>) {
						uint ncells = 1;

						if (cell.multitype == Cell.Multitype.MULTICOL)
							ncells = cell.ncells;

						if (mindx + ncells > index) {
							if (ncells == 1)
								row.remove (cell, line_style);
							else
								cell.ncells--;
							break;
						}

						mindx += ncells;
					}
				}
			}

			/**
			 * Clones column of {@link Cell}-s by specified indexes.
			 *
			 * @param src_index source position of the column.
			 * @param dest_index destination to clone the column.
			 * @param multicol preserve multicolumn property or not.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public void clone_col (uint src_index, uint dest_index,
			                       bool multicol, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				foreach (var row in this as Gee.ArrayList<Row>) {
					uint mindx = 0;
					var sidx = -1;
					var didx = -1;

					foreach (var cell in row as Gee.ArrayList<Cell>) {
						uint ncells = 1;

						if (cell.multitype == Cell.Multitype.MULTICOL)
							ncells = cell.ncells;

						if (sidx == -1 && mindx + ncells > src_index)
							sidx = row.index_of (cell);

						if (didx == -1 && mindx + ncells > dest_index)
							didx = row.index_of (cell);

						if (sidx != -1 && didx != -1) {
							var cell2 = row.get (sidx).copy () as Cell;
							if (!multicol && cell2.multitype == Cell.Multitype.MULTICOL)
								cell2.ncells = 1;
							row.insert (didx, cell2, line_style);

							sidx = -1;
							break;
						}

						mindx += ncells;
					}

					if (sidx != -1 && mindx <= dest_index) {
						var empty_global_doc = new Glob ();
						Cell cell;

						while (mindx < dest_index) {
							var row_size = row.size;
							cell = row.get (row_size - 1).copy () as Cell;
							cell.contents = empty_global_doc;
							cell.ncells = 1;
							row.add (cell, line_style);
							mindx++;
						}

						cell = row.get (sidx).copy () as Cell;
						if (!multicol && cell.multitype == Cell.Multitype.MULTICOL)
							cell.ncells = 1;
						row.add (cell, line_style);
					}
				}
			}

			/**
			 * Removes {@link Row} from from ``Subtable``.
			 *
			 * @param row {@link Row} to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new bool remove (Row row, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				var index = index_of (row);
				if (index < 0 || index >= size) return false;
				remove_at (index);
				return true;
			}

			/**
			 * Removes a {@link Row} from the ``Subtable`` at specified position.
			 *
			 * @param index position of the {@link Row} to remove.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new Row remove_at (int index, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				if (size > 1 && 0 != line_style & Row.OpLineStyle.HBORDER) {
					if (index == 0)
						process_border_lines (get (1) as Row, get (index) as Row, true);
					else if (index == size - 1)
						process_border_lines (get (size - 2) as Row, get (index) as Row, false);
				}

				if ((line_style & Row.OpLineStyle.HDBLLINES) != 0)
					if (index > 0 && index + 1 < size)
						process_double_lines (get (index + 1) as Row,
						                      get (index - 1) as Row);

				return base.remove_at (index) as Row;
			}

			/**
			 * Inserts a {@link Row} to the ``Subtable`` to specified position.
			 *
			 * @param index position to insert the {@link Row}.
			 * @param row {@link Row} to insert.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new void insert (int index, Row row, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				process_opline_insert (row, get (index) as Row, line_style);
				base.insert (index, row);
			}

			/**
			 * Adds a {@link Row} to the ``Subtable``.
			 *
			 * @param row {@link Row} to add.
			 * @param line_style {@link Row.OpLineStyle} of the operation.
			 */
			public new bool add (Row row, Row.OpLineStyle line_style = Row.OpLineStyle.BORDER_DBLLINES) {
				process_opline_insert (row, null, line_style);
				return base.add (row);
			}

			enum RowPos { DEFAULT = 0, FIRST, LAST }

			Row rm_extra_lines (Row row) {
				var ret = row.copy () as Row;

				var row_pos = RowPos.DEFAULT;

				if (index_of (row) == 0)
					row_pos = RowPos.FIRST;
				else if (index_of (row) == size - 1)
					row_pos = RowPos.LAST;
				else
					row_pos = RowPos.DEFAULT;

				uint min_olines = 0, min_ulines = 0;

				foreach (var cell in row as Gee.ArrayList<Cell>) {
					min_olines = uint.min (min_olines, cell.noverlines);
					min_ulines = uint.min (min_ulines, cell.nunderlines);
				}

				foreach (var cell in row as Gee.ArrayList<Cell>) {
					switch (row_pos) {
						case RowPos.FIRST:
							cell.noverlines = uint.min (min_olines + 1, cell.noverlines);
							cell.nunderlines = uint.min (min_ulines, cell.nunderlines);
							break;
						case RowPos.LAST:
							cell.noverlines = uint.min (1, cell.noverlines);
							cell.nunderlines = uint.min (min_ulines + 1, cell.nunderlines);
							break;
						default:
							cell.noverlines = uint.min (1, cell.noverlines);
							cell.nunderlines = uint.min (min_ulines, cell.nunderlines);
							break;
					}
				}

				return ret;
			}

			/**
			 * Generates LaTeX string for the ``Subtable``.
			 */
			public override string generate () {
				var s = new StringBuilder ();

				s.append (before);

				var caption_text = caption.generate ();
				if (caption_text != "") {
					s.append (caption_text);
					if (size != 0)
						s.append ("\\tabularnewline");
				}

				foreach (var row in this as Gee.ArrayList<Row>) {
					var row_style = Row.Style.DEFAULT;

					if (style != AddSpaces.Style.DEFAULT) {
						var len = size;

						if (len > 1 && index_of (row) == 0)
							row_style = Row.Style.FORMAL_FIRST;
						else if (len > 1 && index_of (row) == size - 1)
							row_style = Row.Style.FORMAL_LAST;
						else if (len == 1)
							row_style = Row.Style.FORMAL_SINGLE;
						else
							row_style = Row.Style.FORMAL_REST;
					}

					row.style = row_style;
					var tmprow = rm_extra_lines (row);
					var tmps = tmprow.generate ();
					s.append (tmps);
				}

				s.append (after);

				return s.str;
			}
		}
	}
}
