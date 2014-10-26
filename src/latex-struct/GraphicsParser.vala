namespace LAview {

	namespace Parsers {

		class GraphicsParser : Parser {

			public GraphicsParser (Array<Link> links) {
				base (links);
			}

			void remove_duplicate_params (List<string> parlist) {
				for (unowned List<string> elem1 = parlist.first (); elem1 != null; elem1 = elem1.next)
					for (unowned List<string> elem2 = elem1.next; elem2 != null; elem2 = elem2.next) {
						var eq_pos1 = elem1.data.index_of_char ('='),
							eq_pos2 = elem2.data.index_of_char ('=');
						size_t min_len = 0;

						if (-1 != eq_pos1)
							min_len = eq_pos1;

						if (-1 != eq_pos2)
							min_len = size_t.min (min_len, eq_pos2);

						if (0 != min_len && 0 == Posix.strncmp (elem1.data, elem2.data, min_len)) {
							elem2.delete_link (elem2);
							if (elem2 == null) break;
						}
					}
			}

			string param_get_nvalue (string param) {
				int i;
				for (i = 0; param[i] != '\0' && param[i] != '='; ++i);
				if (param[i] == '\0') return "";
				while (param[++i].isspace ());
				if (!param[i].isdigit ()) return "";
				return param.offset (i);
			}

			string param_get_units (string param) {
				int i;
				for (i = 0; param[i] != '\0' && param[i] != '='; ++i);
				if (param[i] == '\0') return "";
				while (param[++i].isspace ());
				if (!param[i].isdigit ()) return "";
				while (param[++i].isdigit ());
				if (param[i] == '.')
					while (param[++i].isdigit ());
				while (param[i].isspace ()) ++i;
				if (param[i] == '\0') return "";
				return param.offset (i);
			}

			List<string> split_params (string param_str) {
				var parlist = new List<string> ();
				var vstr = param_str.split (",");
				foreach (var str in vstr) {
					str = str.strip ();

					if (str != "")
						parlist.prepend (str);
				}

				parlist.reverse ();

				remove_duplicate_params (parlist);

				return parlist;
			}

			string concat_rest_params (List<string> parlist) {
				var str = new StringBuilder ();

				for (unowned List<string> elem = parlist.first (); elem != null; elem = elem.next) {
					str.append (elem.data);
					if (elem.next != null)
						str.append_c (',');
				}

				return str.str;
			}

			static int find_param_delegate (string a, string b) {
				return Posix.strncmp (a, b, int.min (a.length, b.length));
			}

			void fill_known_params (Graphics graphics, string param_str) {
				var parlist = split_params (param_str);

				unowned List<string> elem;

				if (null != (elem = parlist.find_custom ("width", find_param_delegate))) {
					string tmps1 = param_get_nvalue (elem.data);
					string tmps2 = param_get_units (elem.data);

					if (tmps1 != "" && tmps2 != "") {
						graphics.width = double.parse (tmps1);
						graphics.width_unit = tmps2;
					}

					parlist.delete_link (elem);
				}

				if (null != (elem = parlist.find_custom ("height", find_param_delegate))) {
					string tmps1 = param_get_nvalue (elem.data);
					string tmps2 = param_get_units (elem.data);

					if (tmps1 != "" && tmps2 != "") {
						graphics.height = double.parse (tmps1);
						graphics.height_unit = tmps2;
					}

					parlist.delete_link (elem);
				}

				graphics.rest_params = concat_rest_params (parlist);
			}

			public override IDoc parse (string contents, size_t line, long position) throws ParseError {
				/* set TeX graphics contents */
				this.contents = contents;
				this.line = line;
				this.position = position;

				var graphics = new Graphics.with_params ();

				try {
					var regex = new Regex ("\\[[^[\\]{}]+\\]");
					MatchInfo match_info;
					regex.match (contents, 0, out match_info);

					if (match_info.matches ()) {
						var word = match_info.fetch (0);
						fill_known_params (graphics, word[1:word.length - 1]);
					}
				} catch (RegexError e) {}

				try {
					var regex = new Regex ("\\{[^[\\]{}]+\\}");
					MatchInfo match_info;
					regex.match (contents, 0, out match_info);

						if (match_info.matches ()) {
						var word = match_info.fetch (0);
						graphics.path = word[1:word.length - 1].compress ();
					}
				} catch (RegexError e) {}

				return graphics;
			}
		}
	}
}
