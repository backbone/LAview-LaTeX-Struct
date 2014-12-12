namespace LAview {

	namespace Parsers {

		using Table;

		class TabularParser : TableParser {

			public TabularParser (Array<Link> links) {
				base (links);
			}

			public override IDoc parse (string contents, size_t line, long position) throws ParseError {

				/* create empty tabular */
				var tabular = new Tabular ();

				/* set TeX tabular contents */
				this.contents = contents;
				this.line = line;
				this.position = position;

				/* get parameters string */
				var PAR_REG = "\\|*((>\\{[^{}*]+\\})?[^{}*]+\\{[^{}*]+\\}|[^{}*]+)\\|*";
				// Bug #94: Parse Multiple defined columns in the tabular/longtable.
				PAR_REG = "\\{((\\*\\{[0-9]+\\}\\{" + PAR_REG + "\\}|" + PAR_REG + "))*\\}";
				var param_regex = "^(\\[(t|b)])?" + PAR_REG + "(" + PAR_REG + ")?";

				string params = "";
				uint start_pos = 0, stop_pos = 0;

				try {
					var regex = new Regex (param_regex);

					MatchInfo match_info;
					regex.match (contents, 0, out match_info);

					if (match_info.matches ()) {
						match_info.fetch_pos (0, out start_pos, out stop_pos);
						params = match_info.fetch (0);
					} else {
						/// Translators: please leave the '%s' construction without any changes.
						prefix_error (subdoc_start,
						              _("Incorrect tabular parameters doesn't match '%s' regexp."),
						              param_regex);
						throw new ParseError.SUBDOC (err_str);
					}
				} catch (RegexError e) {}

				/* tabular align: [t], [b] */
				if (params[0] == '[') {
					tabular.align = params[1];
					params = params.offset (3);

				}

				/* width */
				try {
					if (Regex.match_simple ("^" + PAR_REG + PAR_REG + "$", params)) {
						var regex = new Regex (PAR_REG);
						MatchInfo match_info;
						regex.match (params, 0, out match_info);
						match_info.fetch_pos (0, out start_pos, out stop_pos);
						var tmps = match_info.fetch (0);
						tmps = tmps[1:tmps.length - 1];
						tmps = tmps.compress ();
						tabular.width = tmps;
						params = params.offset (stop_pos);
					}
				} catch (RegexError e) {}

				/* remove bound '{' '}' from params */
				params = params[1:params.length - 1];
				var col_params = new ColParams ();

				/* match reversed params so '|' will be snapped to the right column */
				try {
					var col_reg1 = "\\|*}[^{}]+{(p\\|*|m\\|*|b\\|*)(}[^{}]+{>(\\|+$|\\||)|\\|)?";
					var col_reg2 = "\\|*(r|c|l)(}[^{}]+{@(p\\|*|m\\|*|b\\|*) (r|c|l))?(\\|+$|\\||)";
					var regex = new Regex ("(" + col_reg1 + "|" + col_reg2
					                       // Bug #94: Parse Multiple defined columns...
					                       + "|\\}" + col_reg1 + "\\{\\}[0-9]+\\{\\*"
					                       + "|\\}" + col_reg2 + "\\{\\}[0-9]+\\{\\*)");
					params = params.reverse ();
					MatchInfo match_info;
					regex.match_full (params, -1, 0, 0, out match_info);
					while (match_info.matches ()) {
						var col_param = new ColParam.with_params (0, "", 0);
						var word = match_info.fetch (0).reverse ().compress ();

						// Bug #94: Parse Multiple defined columns in the tabular/longtable.
						int count = 1;
						if (word[0] == '*') {
							count = int.parse (word.offset(2));
							int start;
							for (start = 2; word[start] != '{'; ++start);
							word = word[start + 1:word.length - 1];
						}

						int nllines, nrlines;
						for (nllines = 0; '|' == word[nllines]; ++nllines);
						for (nrlines = word.length - 1; nrlines != 0 && '|' == word[nrlines]; --nrlines);
						var wlen = word.length;
						word = word[0:nrlines + 1];
						col_param.align = word.offset (nllines);
						col_param.nllines = nllines;
						col_param.nrlines = wlen - 1 - nrlines;

						// Bug #94: Parse Multiple defined columns in the tabular/longtable.
						while (count-- > 0) col_params.insert (0, col_param);

						match_info.next ();
					}
				} catch (RegexError e) {}

				/* === Parsing subtables === */
				tabular.params = col_params;

				/* set TeX document contents */
				this.contents = contents.offset (stop_pos);

				/* feed in the text */
				scanner.input_text (this.contents, this.contents.length);

				row_abs_pos = 0;
				row = new Row ();
				subtable = new Subtable ();
				clines = new List<int> ();
				cell_abs_pos = 0;

				TokenType expected_token = TokenType.NONE;

				/* scanning loop, we scan the input until it's end is reached,
				 * the self encountered a lexing err, or our sub routine came
				 * across invalid syntax
				 */
				do {
					expected_token = scan_tex_symbol (tabular);

				} while (expected_token == TokenType.NONE
				         && fifo_peek_head ().token != TokenType.EOF
				         && fifo_peek_head ().token != TokenType.ERROR);

				/* give an err message upon syntax errors */
				if (expected_token == TokenType.ERROR)
					scanner.unexp_token (expected_token, null, "symbol", null, null, true);

				return tabular;
			}
		}
	}
}
