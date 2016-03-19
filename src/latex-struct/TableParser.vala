namespace LAview {

	namespace Parsers {

		using Table;

		abstract class TableParser : Parser {

			protected uint row_abs_pos;
			protected Row row = new Row ();
			protected Subtable subtable;

			protected Array <Link> group = new Array<Link> ();

			protected Row.LinesType lines_type;
			protected List<int> clines;
			protected int nhlines;
			protected uint cell_abs_pos;

			protected bool in_caption = false;

			public TableParser (Array<Link> links) {
				base (links);

				group.append_val (new Link ({}, {}));

				group.append_val (new Link ({"\\", "\\caption"}, {}));
				group.append_val (new Link ({"\\", "\\endfirsthead"}, {}));
				group.append_val (new Link ({"\\", "\\endhead"}, {}));
				group.append_val (new Link ({"\\", "\\endfoot"}, {}));
				group.append_val (new Link ({"\\", "\\endlastfoot"}, {}));

				group.append_val (new Link ({"\\", "\\hline"}, {}));
				group.append_val (new Link ({"\\", "\\cline"}, {}));
				group.append_val (new Link ({"\\", "\\tabularnewline"}, {}));
				group.append_val (new Link ({"\\", "\\", "\\", "\\"}, {}));
				group.append_val (new Link ({"&"}, {}));
				group.append_val (new Link ({"\\", "\\toprule"}, {}));
				group.append_val (new Link ({"\\", "\\midrule"}, {}));
				group.append_val (new Link ({"\\", "\\cmidrule"}, {}));
				group.append_val (new Link ({"\\", "\\bottomrule"}, {}));
				group.append_val (new Link ({"\\", "\\noalign"}, {}));
				group.append_val (new Link ({"\\", "\\addlinespace"}, {}));

				/* load local symbols */
				load_symbols (group);

				/* generate local tokens table (tree) */
				build_tree (ref local_tokens_to_class_start, group, false);

				/* generate local stop_tokens table (tree) */
				build_tree (ref local_tokens_to_class_stop, group, true);
			}

			public override IDoc parse (string contents, size_t line, long position) throws ParseError {
				assert (false);

				return new Text ("");
			}

			protected bool process_tabularnewline (uint tag, uint tag_left_abspos,
			                             string subcontents,
			                             uint matched_tag_abspos_right) throws ParseError {
			    // TODO: Similar ro TabularParser::process_tabularnewline (), make a template method?
				if (in_caption) {
					subtable.caption = new Text (contents[row_abs_pos:tag_left_abspos].compress ());
					in_caption = false;
				} else {
					TokenType token = add_cell (subcontents);

					if (token == TokenType.ERROR)
						return false;

					if (fifo_peek_head().token == TokenType.LEFT_BRACE) {
						local_count_branches (tag);
					} else {
						subtable.add (row, Row.OpLineStyle.DEFAULT);
						row = new Row ();
					}
				}

				lines_type = Row.LinesType.NONE;
				clines = new List<int> ();
				nhlines = 0;

				row_abs_pos = matched_tag_abspos_right;

				return true;
			}

			protected TokenType add_cell (string subcontents) throws ParseError {
				/* remove leading linebreak and \newpage tag in first cell of row */
				if (row.size == 0) {
					try {
						var regex = new Regex ("^([ \t\r]|\\\\\\\\newpage)*\\n"
					                       + "([ \t\r\n]*\\\\\\\\newpage[ \t\r\n]*)*");
						MatchInfo match_info;
						regex.match (subcontents, 0, out match_info);
						if (match_info.matches ()) {
							var word = match_info.fetch (0);
							uint stop_pos = 0;
							match_info.fetch_pos (0, null, out stop_pos);
							subcontents = subcontents.offset (stop_pos);
							row.before = word.compress ();
						}
					} catch (RegexError e) { }
				}

				var mtype = Cell.Multitype.SIMPLE;
				var before = "", align = "";
				var ncells = 0;
				var cell_contents = "";
				var after = "";

				/* check cell for multi{column|row} */
				if (Regex.match_simple ("^[ \t\r\n]*\\\\\\\\multicolumn\\{1\\}\\{[^{}]+\\}"
					                    + "\\{[ \t\r\n]*\\\\\\\\multirow\\{[0-9]+\\}"
					                    + "\\{\\*\\}\\{", subcontents)) {
					// Multitype.MULTICOLROW
					mtype = Cell.Multitype.MULTICOLROW;
					before = subcontents[0:subcontents.index_of_char('\\')];
					var pstart = subcontents.offset (subcontents.index_of_char ('{') + 1);
					pstart = pstart.offset (pstart.index_of_char ('{'));
					var len = pstart.index_of_char ('}');
					var pend = pstart.offset (len);
					align = pstart[1:len].compress ();
					pstart = pend.offset (pend.index_of_char ('{') + 1);
					pstart = pstart.offset (pstart.index_of_char ('{'));
					ncells = int.parse (pstart.offset (1));
					pstart = pstart.offset (1);
					pstart = pstart.offset (pstart.index_of_char ('{') + 1);
					pstart = pstart.offset (pstart.index_of_char ('{'));
					var lev = 1;
					len = 1;
					pend = pstart.offset (1);
					for (var max_len = pstart.length; len < max_len && lev != 0; ++len) {
						switch (pstart[len]) {
							case '{': ++lev;
									  break;
							case '}': --lev;
									  break;
							default:
									  break;
						}
						pend = pend.offset (1);
					}
					if (lev != 0) {
						prefix_error (subdoc_start, _("Error parsing subdoc."));
						throw new ParseError.SUBDOC (err_str);
					}
					cell_contents = pstart.substring (1, len - 2);
					after = pend.offset (1);
				} else if (Regex.match_simple ("^[ \t\r\n]*\\\\\\\\multi(column|row)\\{[0-9]+\\}\\{",
				                               subcontents)) {
					// Multitype.MULTICOL
					if (Regex.match_simple ("^[ \t\r\n]*\\\\\\\\multicolumn", subcontents))
						mtype = Cell.Multitype.MULTICOL;
					else if (Regex.match_simple ("^[ \t\r\n]*\\\\\\\\multirow", subcontents))
						mtype = Cell.Multitype.MULTIROW;

					before = subcontents[0:subcontents.index_of_char ('\\')];
					var pstart = subcontents.offset (subcontents.index_of_char ('{'));
					ncells = int.parse (pstart.offset (1));
					pstart = pstart.offset (1);
					pstart = pstart.offset (pstart.index_of_char ('{'));
					var lev = 1;
					var len = 1;
					for (var max_len = pstart.length; len < max_len && lev != 0; ++len) {
						switch (pstart[len]) {
							case '{': ++lev;
									  break;
							case '}': --lev;
									  break;
							default:
									  break;
						}
					}
					if (lev != 0) {
						prefix_error (subdoc_start, _("Error parsing subdoc."));
						throw new ParseError.SUBDOC (err_str);
					}

					align = pstart.substring (1, len - 2).compress ();
					pstart = pstart.offset (len);
					pstart = pstart.offset (pstart.index_of_char ('{'));

					if (pstart == "") {
						prefix_error (subdoc_start, _("Error parsing subdoc."));
						throw new ParseError.SUBDOC (err_str);
					}

					lev = 1;
					len = 1;
					for (var max_len = pstart.length; len < max_len && lev != 0; ++len) {
						switch (pstart[len]) {
							case '{': ++lev;
									  break;
							case '}': --lev;
									  break;
							default:
									  break;
						}
					}
					if (lev != 0) {
						prefix_error (subdoc_start, _("Error parsing subdoc."));
						throw new ParseError.SUBDOC (err_str);
					}

					cell_contents = pstart.substring (1, len - 2);
					after = pstart.offset (len);
				} else {
					// Multitype.SIMPLE
					ncells = 1;
					mtype = Cell.Multitype.SIMPLE;
					cell_contents = subcontents;
				}

				var nllines = 0, nrlines = 0;

				if (align != "") {
					var alen = align.length;
					nllines = nrlines = 0;

					for (nllines = 0; nllines < alen && '|' == align[nllines]; ++nllines);
					for (nrlines = alen - 1; nrlines > nllines && '|' == align[nrlines]; --nrlines);

					align = align[nllines:nrlines + 1];
					nrlines = alen - nrlines - 1;
				}

				var subparserGlobal = new GlobParser (links);
				var subdoc = subparserGlobal.parse (cell_contents, subdoc_start.line, subdoc_start.pos);

				unowned List<int> clines_p = clines.first ();
				foreach (var cell in row as Gee.ArrayList<Cell>) {
					if (clines_p == null) break;

					for (var i = 0, max_i = cell.ncells; i < max_i; ++i) {
						if (clines_p == null) break;
						clines_p = clines_p.next;
					}
				}

				var overline = nhlines + ((lines_type == Row.LinesType.CLINES && clines_p != null) ?
				                          clines_p.data : 0) ;
				var underline = 0;

				var cell = new Cell.with_params (mtype, ncells, nllines, align, nrlines, overline,
				                                 underline, subdoc as Glob, before, after);
				row.add (cell, Row.OpLineStyle.DEFAULT);

				return TokenType.NONE;
			}

			protected void lines_to_last_row () {
				bool clear_lines = false;

				switch (lines_type) {
					case Row.LinesType.HLINE:
						if (subtable.size != 0) {
							foreach (var cell in subtable.get (subtable.size - 1) as Gee.ArrayList<Cell>) {
								cell.nunderlines += nhlines;
								clear_lines = true;
							}
						}
						break;
					case Row.LinesType.CLINES:
						/* #85 Assert in LINE_CLINES case */
						if (row.size == 0 && subtable.size == 0)
							break;
						var tmp_row = row.size != 0 ? row : subtable.get (subtable.size - 1) as Row;
						unowned List<int> clines_p = clines.first ();
						foreach (var cell in tmp_row as Gee.ArrayList<Cell>) {
							if (clines_p == null) break;

							if (clines_p != null && clines_p.data != 0)
								++cell.nunderlines;

							for (var i = 0; clines_p != null && i < cell.ncells; ++i)
								clines_p = clines_p.next;

							clear_lines = true;
						}
						break;
				}

				lines_type = Row.LinesType.NONE;
				if (clear_lines) {
					nhlines = 0;
					clines = new List<int> ();
				}
			}

			protected void local_count_branches (uint tag) {
				if (group.index (tag).end.length != 0) {
					child_tag = tag + links.length;
					child_level = 1;
				} else if (fifo_peek_head().token == TokenType.LEFT_CURLY
				           || fifo_peek_head().token == TokenType.LEFT_BRACE) {
					in_child_params = true;
					child_tag = tag + links.length;
					child_level = 1;
				}
			}

			protected void process_spaces (Row.Style style, string subcontents) {
				if (style == Row.Style.DEFAULT
					&& !Regex.match_simple ("\\\\vskip", subcontents))
					return;

				var tmp = subcontents.compress ()[0:-1];
				var add_space = new AddSpace.with_params (tmp.offset (style != Row.Style.DEFAULT ? 1 : 7));

				Row last_row;
				if (subtable.size != 0)
					last_row = subtable.get(subtable.size-1) as Row;
				else
					last_row = new Row ();

				if (subtable.size != 0 && last_row.bottom.height == "" && subcontents != "") {
					last_row.bottom = add_space;
				} else if (row.top.size == 0 || subtable.size == 0) {
					row.top.add (add_space);
				} else if (row.top.size == 1 && subtable.size != 0) {
					last_row.between.add (row.top.get (0) as AddSpace);
					row.top.remove_at (0);
					row.top.add (add_space);
				}
			}

			protected void spaces_to_last_row () {
				var top = row.top;
				if (top.size == 1 && subtable.size != 0) {
					(subtable.get (subtable.size - 1) as Row).between.add (top.get (0) as AddSpace);
					top.remove_at (0);
				}
			}

			enum TagKind {
				NONE = 0, START_LOCAL, STOP_LOCAL, START_GLOBAL, STOP_GLOBAL
			}

			enum TableTagType {
				TEXT = 0, CAPTION, ENDFIRSTHEAD, ENDHEAD, ENDFOOT, ENDLASTFOOT,
				HLINE, CLINE, TABULARNEWLINE, DBLBACKSLASHES, AMPERSAND,
				TOPRULE, MIDRULE, CMIDRULE, BOTTOMRULE, NOALIGN, ADDLINESPACE
			}

			void end_subtable (Table.ATable table,
			                   TableTagType subtable_type, uint tag_left_abspos) {
				if (in_caption) {
					subtable.caption = new Text (contents[row_abs_pos:tag_left_abspos].compress ());
					in_caption = false;
				} else {
					subtable.after = contents[row_abs_pos:tag_left_abspos];
				}

				lines_to_last_row ();

				switch (subtable_type) {
					case TableTagType.ENDFIRSTHEAD:
						table.first_header = subtable;
						break;

					case TableTagType.ENDHEAD:
						table.header = subtable;
						break;

					case TableTagType.ENDFOOT:
						table.footer = subtable;
						break;

					case TableTagType.ENDLASTFOOT:
						table.last_footer = subtable;
						break;

					case TableTagType.TEXT:
						table.table = subtable;
						break;

					default:
						break;
				}

				subtable = new Subtable ();
			}

			protected TokenType scan_tex_symbol (Table.ATable table) throws ParseError {
				var tag = 0U;
				var matched_tag_length = fifo_is_tag (local_tokens_to_class_start, out tag);
				var message = "";
				TagKind tag_kind = TagKind.NONE;

				if (matched_tag_length != 0 && child_level == 0) {
					tag_kind = TagKind.START_LOCAL;
				} else {
					matched_tag_length = fifo_is_tag (local_tokens_to_class_stop, out tag);
					if (matched_tag_length != 0) {
						tag_kind = TagKind.STOP_LOCAL;
					} else {
						matched_tag_length = fifo_is_tag (tokens, out tag);

						if (matched_tag_length != 0) {
							tag_kind = TagKind.START_GLOBAL;

							if (links.index (tag).end.length != 0)
								++child_level;
							for (var i = 0; i < matched_tag_length; ++i) fifo_pop ();
						} else {
							matched_tag_length = fifo_is_tag (stop_tokens, out tag);
							if (matched_tag_length != 0) {
								if (child_level == 0) {
									message = string.joinv (null, links.index (tag).end);
									/// Translators: please leave the '%s' construction without any changes.
									prefix_error (last_symb_pos,
									              _("Unexpected end external tag sequence '%s' without begin tag pair."),
									              message);
									throw new ParseError.ORPHAN_END (err_str);
								} else {
									tag_kind = TagKind.STOP_GLOBAL;
									--child_level;
									for (var i = 0; i < matched_tag_length; ++i) fifo_pop ();
								}
							} else if (in_child_params) {
								count_branches ();
								if (!in_child_params) {
									tag_kind = TagKind.STOP_LOCAL;
									tag = child_tag - links.length;
									matched_tag_length = 1;
								}
							}
						}
					}
				}

				var subcontents = "";

				switch (tag_kind) {
				case TagKind.NONE:
					fifo_pop ();

					/* without end pair */
					if (fifo_peek_head ().token == TokenType.EOF
					    && (child_tag != 0 || child_level != 0)) {
						assert (child_tag != 0 && child_level != 0);
						if (child_tag < links.length)
							message = string.joinv (null, links.index (child_tag).begin);
						else
							message = string.joinv (null, group.index (child_tag - links.length).begin);
						/// Translators: please leave the '%s':%d:%d construction without any changes.
						prefix_error (subdoc_start,
						              _("Begin tag sequence '%s':%d:%d without end tag pair."),
						              message, subdoc_start.line + 1, subdoc_start.pos + 1);
						throw new ParseError.ORPHAN_BEGIN (err_str);
					}
					break;

				case TagKind.START_LOCAL:
					var tag_left_abspos = fifo_peek_head ().abspos;
					var matched_tag_abspos_right = fifo_peek_nth (matched_tag_length - 1).abspos
					    + fifo_peek_nth (matched_tag_length - 1).length;
					var matched_tag_line = fifo_peek_head ().line;
					var matched_tag_pos = fifo_peek_head ().pos;
					for (var i = 0; i < matched_tag_length; ++i) fifo_pop ();

					if (child_tag != 0) { // inside local tags
						assert (child_level != 0);
						++child_level;
					} else if (child_level == 0) { // outside local tags
						assert (child_tag == 0);
						subcontents = contents[subdoc_start.abspos:tag_left_abspos];

						var update_subdoc_start = true;

						switch (tag) {
							case TableTagType.CAPTION:
								in_caption = true;
								local_count_branches (tag);
								break;

							case TableTagType.ENDFIRSTHEAD:
								end_subtable (table, TableTagType.ENDFIRSTHEAD, tag_left_abspos);
								break;

							case TableTagType.ENDHEAD:
								end_subtable (table, TableTagType.ENDHEAD, tag_left_abspos);
								break;

							case TableTagType.ENDFOOT:
								end_subtable (table, TableTagType.ENDFOOT, tag_left_abspos);
								break;

							case TableTagType.ENDLASTFOOT:
								end_subtable (table, TableTagType.ENDLASTFOOT, tag_left_abspos);
								break;

							case TableTagType.TOPRULE:
							case TableTagType.MIDRULE:
							case TableTagType.BOTTOMRULE:
							case TableTagType.HLINE:
								if (tag == TableTagType.TOPRULE
								    || tag == TableTagType.MIDRULE
								    || tag == TableTagType.BOTTOMRULE)
									table.style = AddSpaces.Style.FORMAL;

								switch (lines_type) {
									case Row.LinesType.CLINES:
										clines = new List<int> ();
										break;
									case Row.LinesType.HLINE:
										lines_to_last_row ();
										break;
									default:
										break;
								}
								lines_type = Row.LinesType.HLINE;
								++nhlines;

								row_abs_pos = matched_tag_abspos_right;
								break;

							case TableTagType.DBLBACKSLASHES:
							case TableTagType.TABULARNEWLINE:
								if (tag == TableTagType.DBLBACKSLASHES) {
									var row_length = row.size;

									var col_param = "";
									if (row_length < table.params.size)
										col_param = (table.params.get (row_length) as ColParam).align;
									if (col_param != ""
									    && (col_param.index_of_char ('p') != -1
									        || col_param.index_of_char ('b') != -1
									        || col_param.index_of_char ('m') != -1)) {
										update_subdoc_start = false;
										break;
									}
								}

								if (!process_tabularnewline (tag, tag_left_abspos, subcontents,
								                             matched_tag_abspos_right)) {
									throw new ParseError.SUBDOC (err_str);
								}
								break;

							case TableTagType.AMPERSAND:
								if (add_cell (subcontents) == TokenType.ERROR)
									throw new ParseError.SUBDOC (err_str);
								break;

							default:
								/* do nothing */
								local_count_branches (tag);
								break;
						}

						if (update_subdoc_start) {
							subdoc_start.abspos = matched_tag_abspos_right;
							subdoc_start.line = matched_tag_line;
							subdoc_start.pos = matched_tag_pos;
						}
					} else { // (!child_tag && child_level) - inside global tags
						assert (tag_kind != 0 && child_level != 0);
						if ((tag < links.length && links.index (tag).end.length != 0)
						    || (tag >= links.length && group.index (tag).end.length != 0)) // do not count NULL-end-tag objects
							++child_level;
					}
					break;

				case TagKind.STOP_LOCAL:
					var tag_left_abspos = fifo_peek_head ().abspos;
					var matched_tag_abspos_right = fifo_peek_nth (matched_tag_length - 1).abspos
					                           + fifo_peek_nth (matched_tag_length - 1).length;
					var matched_tag_line = fifo_peek_head ().line;
					var matched_tag_pos = fifo_peek_head ().pos;
					if (group.index (tag).end.length == 0)
						++tag_left_abspos;  // '}' ']' is a part of NULL-end-object contents
					for (var i = 0; i < matched_tag_length; ++i) fifo_pop ();

					/* without begin pair */
					if (child_tag == 0 || child_level == 0) {
						assert (child_tag == 0 && child_level == 0);
						message = string.joinv (null, group.index (tag).end);
						/// Translators: please leave the '%s' construction without any changes.
						prefix_error (last_symb_pos,
						              _(": Unexpected end tag sequence '%s' without begin tag pair."),
						              message);
						throw new ParseError.ORPHAN_END (err_str);
					} else if (tag + links.length == child_tag) {
						assert (child_level != 0);
						--child_level;

						if (child_level == 0) {
							child_tag = 0;
							subcontents = contents[subdoc_start.abspos:tag_left_abspos];

							switch (tag) {
								case TableTagType.CMIDRULE:
								case TableTagType.CLINE:
									if (tag == TableTagType.CMIDRULE) table.style = AddSpaces.Style.FORMAL;

									/* check is \cline's subcontents match {number-number} */
									if (Regex.match_simple ("^\\{[0-9]+-[0-9]+\\}$", subcontents)) {
										if (Row.LinesType.CLINES != lines_type)
											lines_to_last_row ();
										lines_type = Row.LinesType.CLINES;
										var cline_begin = int.parse (subcontents.offset (1)) - 1;
										var cline_end = int.parse (subcontents.offset (
										        subcontents.index_of_char ('-') + 1)) - 1;
										while (clines.length () < cline_begin)
											clines.append (0);
										while (clines.length () <= cline_end)
											clines.append (1);
									} else {
										prefix_error (subdoc_start,
										              _("\\cline parameters doesn't match {number-number} regexp."));
										throw new ParseError.SUBDOC (err_str);
									}
									break;

								case TableTagType.DBLBACKSLASHES:
								case TableTagType.TABULARNEWLINE:
									if (subcontents != "") {
										var tmp = subcontents.compress ();
										row.bottom = new AddSpace.with_params (tmp[1:-1]);
									}

									subtable.add (row, Row.OpLineStyle.DEFAULT);
									row = new Row ();
									break;

								case TableTagType.NOALIGN:
									process_spaces (Row.Style.DEFAULT, subcontents);
									break;

								case TableTagType.ADDLINESPACE:
									process_spaces (Row.Style.FORMAL_REST, subcontents);
									break;

								default:
									/* do nothing */
									break;
							}

							subdoc_start.abspos = matched_tag_abspos_right;
							subdoc_start.line = matched_tag_line;
							subdoc_start.pos = matched_tag_pos;
						}
					} else { // (child_tag && child_level && tag+scanner->priv->nlinks != scanner->priv->child_tag) - global end
						assert (child_level == 0);

						--child_level;
					}

					break;

				default:
					break;
				}

				/* end of tabular */
				if (fifo_peek_head ().token == TokenType.EOF) {
					subtable.after = contents.offset (subdoc_start.abspos).compress ();

					lines_to_last_row ();

					spaces_to_last_row ();

					table.table = subtable;
					subtable = new Subtable ();
				}

				return TokenType.NONE;
			}

		}
	}
}
