namespace LAview {

	/**
	 * LaTeX Parsers.
	 */
	namespace Parsers {

		/**
		 * LaTeX Parser Error Type.
		 */
		public errordomain ParseError {

			/**
			 * Undefined Error.
			 */
			UNDEFINED,

			/**
			 * Cann't find end of subdoc.
			 */
			ORPHAN_BEGIN,

			/**
			 * End tag without begin tag.
			 */
			ORPHAN_END,

			/**
			 * Error in subdoc parsing.
			 */
			SUBDOC,
		}

		abstract class Parser : Object {

			protected string err_str = "";

			/* links to group of scanners */
			protected unowned Array<Link> links = null;

			/* escaped TeX document */
			protected unowned string contents = null;

			/* standard GLib Scanner */
			protected Scanner scanner = new Scanner (null);

			/* tokens_sequence->class table */
			protected Node<uint> tokens = new Node<uint> ();
			protected Node<uint> stop_tokens = new Node<uint> ();

			/* local tokens_sequence->class table */
			protected Node<uint> local_tokens_to_class_start = new Node<uint> ();
			protected Node<uint> local_tokens_to_class_stop = new Node<uint> ();

			/* contents location in global document */
			protected size_t line = 0;
			protected long position = 0;

			/* fifo-queue of tokens */
			protected Queue<SymbPos?> symb_fifo = new Queue<SymbPos?> ();

			protected struct SymbPos {
				public TokenType token;
				public uint line;
				public long pos;
				public uint abspos;
				public uint length;
			}

			/* Last symbol position pushed to fifo */
			protected SymbPos last_symb_pos;

			/* Last symbol position pushed to fifo */
			protected SymbPos subdoc_start;

			/* child class and level */
			protected uint child_tag = 0;
			protected uint child_level = 0;
			protected bool in_child_params = false;
			protected uint child_param_branch_level = 0;

			/* back-slash counter for one-line comments */
			protected uint back_slash_counter = 0;

			public Parser (Array<Link> links) {

				/* initializing scanner links */
				this.links = links;

				/* adjust lexing behaviour to suit our needs */
				scanner.config.cset_skip_characters = "";
				scanner.config.cset_identifier_first = CharacterSet.a_2_z + CharacterSet.DIGITS + "\\";
				scanner.config.cset_identifier_nth = CharacterSet.a_2_z + CharacterSet.A_2_Z + CharacterSet.DIGITS;
				scanner.config.cpair_comment_single = "%\n";
				scanner.config.scan_float = false;
				scanner.config.symbol_2_token = true;
				scanner.config.scan_string_sq = false;  // See bug #448
				scanner.config.scan_string_dq = false;  // See bug #448

				/* set custom error message handler */
				scanner.msg_handler = null;

				/* load symbols into the self using GLib Quarks */
				load_symbols (links);

				/* generate tokens table (tree) */
				build_tree (ref tokens, links, false);

				/* generate stop_tokens table (tree) */
				build_tree (ref stop_tokens, links, true);

				/* give the error handler an idea on how the input is named */
				scanner.input_name = "TeX text";
			}

			public abstract IDoc parse (string contents, size_t line, long position) throws ParseError;

			void vprefix_error (SymbPos symb_pos, string format, va_list args) {
				err_str = "\n" + err_str;

				var line = symb_pos.line;
				long position = symb_pos.pos;


				if (line == 0)
					position += this.position;

				size_t nlines; long i;
				for (i = 0, nlines = 0; contents[i] != '\0' && nlines < line; ++i)
					if ('\n' == contents[i] || '\r' == contents[i])
						++nlines;

				var unparsed_str = contents[i:contents.length].split ("\n"); // FIXME: MacOS newline '\r' characters...
				var str = unparsed_str[0][0:position];
				var compressed = str.compress ();
				position = compressed.length + 1;
				var arrow_str = string.nfill (position - 1, ' ') + "^";
				compressed = unparsed_str[0].compress ();

				str = format.vprintf (args);
				err_str = "%s:%lu:%lu: %s\n%s\n%s\n%s".printf (get_type().name(),
				                                               this.line + line + 1,
				                                               position,
				                                               str,
				                                               compressed,
				                                               arrow_str,
				                                               err_str);
			}

			protected void prefix_error (SymbPos symb_pos, string format, ...) {
				var list = va_list ();
				vprefix_error (symb_pos, format, list);
			}

			protected void load_symbols (Array<Link> links) {
				for (var i = 1; i < links.length; ++i) {
					for (var j = 0; j < links.index (i).begin.length; ++j)
						if (links.index (i).begin[j].length > 1)
							scanner.scope_add_symbol (0, links.index (i).begin[j], (void*)(Quark.from_string (links.index (i).begin[j]) + TokenType.LAST));

					for (var j = 0; j < links.index (i).end.length; ++j)
						if (links.index (i).end[j].length > 1)
							scanner.scope_add_symbol (0, links.index (i).end[j], (void*)(Quark.from_string (links.index (i).end[j]) + TokenType.LAST));
				}
			}

			protected void build_tree (ref Node<uint> tokens, Array<Link> links, bool stop_tree) {

				/* generate tokens table (tree) */
				tokens = new Node<uint> ();

				for (var i = 1; i < links.length; ++i) {

					/* if current class has no begin tags */
					if (!stop_tree && links.index (i).begin.length == 0
					    || stop_tree && links.index (i).end.length == 0)
						continue;

					unowned Node<uint> parent_node = tokens;

					unowned string[] symb_seq = stop_tree ? links.index (i).end: links.index (i).begin;

					Quark symb_quark;
					unowned Node child_node;

					/* insert begin tags of all links into tree */
					for (var j = 0; j < symb_seq.length; ++j) {
						assert (symb_seq[j] != null && symb_seq.length != 0);

						if (symb_seq[j].length > 1)
							symb_quark = Quark.from_string(symb_seq[j]) + TokenType.LAST;
						else
							symb_quark = symb_seq[j][0];

						child_node = parent_node.find_child (TraverseFlags.NON_LEAVES, symb_quark);

						/* append node with symb_quark token */
						if (child_node == null)
							child_node = parent_node.append_data (symb_quark);

						parent_node = child_node;
					}

					/* check for identical tokens lists and be shure that we create leaf for class id */
					assert (parent_node.first_child () == null);

					/* append leaf with class id */
					parent_node.append_data (i);
				}
			}

			protected void count_branches () {
				if (in_child_params) {
					switch (fifo_peek_head ().token) {
						case TokenType.LEFT_CURLY:
						case TokenType.LEFT_BRACE:
							++child_param_branch_level;
							break;

						case TokenType.RIGHT_CURLY:
						case TokenType.RIGHT_BRACE:
							--child_param_branch_level;
							break;

						default:
							break;
					}

					if (child_param_branch_level == 0
					    && TokenType.LEFT_CURLY != fifo_peek_nth(1).token
					    && TokenType.LEFT_BRACE != fifo_peek_nth(1).token)
						in_child_params = false;
				}
			}

			protected uint fifo_is_tag (Node<uint> tokens, out uint tag) {
				uint match_length;

				tag = 0;

				/* search for tokens subsequence in tokens tree */
				for (match_length = 0; ; ++match_length) {
					if (tokens == null
					    || TokenType.ERROR == fifo_peek_nth (match_length).token
					    || TokenType.EOF == fifo_peek_nth (match_length).token) {
						match_length = 0;
						break;
					}

					tokens = tokens.find_child (TraverseFlags.NON_LEAVES,
					                            fifo_peek_nth (match_length).token);

					if (tokens != null && tokens.first_child().is_leaf()) {
						tag = tokens.first_child().data;
						++match_length;
						break;
					}
				}

				return match_length;
			}

			protected void fifo_pop () {
				var ret = fifo_peek_head ();

				if (ret.token != TokenType.ERROR && ret.token != TokenType.EOF)
					symb_fifo.pop_head ();
			}

			protected SymbPos fifo_peek_head () {
				if (symb_fifo.length == 0)
					fifo_push ();
				return symb_fifo.peek_head();
			}

			protected SymbPos fifo_peek_nth (uint n) {
				unowned SymbPos ret;

				while (n >= symb_fifo.length && fifo_push ());

				if (n < symb_fifo.length)
					ret = symb_fifo.peek_nth (n);
				else
					ret = symb_fifo.peek_tail ();

				return ret;
			}

			bool fifo_push () {
				var p = contents.offset (last_symb_pos.abspos);

				scanner.get_next_token ();

				if ('\\' == scanner.token) {
					++back_slash_counter;

					if (back_slash_counter % 4 == 0)
						scanner.config.cpair_comment_single = "%\n";
					else if (back_slash_counter % 2 == 0)
						scanner.config.cpair_comment_single = null;

				} else {
					back_slash_counter = 0;
				}

				scanner.peek_next_token ();

				if (scanner.token == TokenType.ERROR
				    || scanner.token == TokenType.EOF) {
						if (symb_fifo.length == 0) {
							var sp = SymbPos ();
							sp.token = scanner.token;
							symb_fifo.push_tail (sp);
						}

					return false;
				}

				var sp = SymbPos ();

				sp.token = scanner.token;
				last_symb_pos.token = scanner.token;
				sp.line = scanner.cur_line () - 1;
				sp.pos = scanner.cur_position ();
				sp.length = 1;

				if (scanner.token > 255 && ((Quark)(scanner.token - TokenType.LAST)).to_string() != null) {
					sp.length = ((Quark)(scanner.token - TokenType.LAST)).to_string().length;
					sp.pos -= sp.length;
				} else if (sp.pos != 0) {
					--sp.pos;
				}

				last_symb_pos.length = sp.length;

				/* current scanner's abspos evaluation */
				while (last_symb_pos.line < sp.line
				       || last_symb_pos.line == sp.line && last_symb_pos.pos < sp.pos) {
					if ('\n' == p[0] || '\r' == p[0]) {
						++last_symb_pos.line;
						last_symb_pos.pos = 0;
					} else {
						++last_symb_pos.pos;
					}

					++last_symb_pos.abspos;
					p = p.offset (1);
				}

				sp.abspos = last_symb_pos.abspos;

				symb_fifo.push_tail (sp);

				return true;
			}
		}
	}
}
