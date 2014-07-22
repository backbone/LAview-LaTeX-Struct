namespace LAview {

	namespace Parsers {

		class GlobParser : Parser {

			public GlobParser (Array<Link> links) {
				base (links);
			}

			enum TagKind {
				NONE = 0,
				START,
				STOP
			}

			TokenType scan_tex_symbol (Glob document) throws ParseError {

				uint tag;
				var matched_tag_length = fifo_is_tag (tokens, out tag);
				TagKind tag_kind = TagKind.NONE;

				if (matched_tag_length != 0) {
					tag_kind = TagKind.START;
				} else {
					matched_tag_length = fifo_is_tag (stop_tokens, out tag);

					if (matched_tag_length != 0) {
						tag_kind = TagKind.STOP;
					} else if (in_child_params) {
						count_branches ();

						if (!in_child_params) {
							tag_kind = TagKind.STOP;
							tag = child_tag;
							matched_tag_length = 1;
						}
					}
				}

				var token = TokenType.NONE;

				uint matched_tag_abspos_left;
				uint matched_tag_abspos_right;
				uint matched_tag_line;
				long matched_tag_pos;

				switch (tag_kind) {
					case TagKind.NONE:
						fifo_pop ();

						if (fifo_peek_head().token == TokenType.EOF) {
							/* without end pair */
							if (child_tag != 0 || child_level != 0) {
								assert (child_tag != 0 && child_level != 0);
								string message = string.joinv (null, links.index (child_tag).begin);
								/// Translators: please leave the '%s' construction without any changes.
								prefix_error (subdoc_start, _("Begin tag sequence '%s' without end tag pair."), message);
								token = TokenType.ERROR;
								throw new ParseError.ORPHAN_BEGIN (err_str);

							} else {
								var subcontents = contents.offset (subdoc_start.abspos);
								var subparser = links.index (0).create (links);
								var subdoc = subparser.parse (subcontents, subdoc_start.line, subdoc_start.pos);
								document.add (subdoc);
								token = TokenType.EOF;
							}
						}
						break;

					case TagKind.START:
						matched_tag_abspos_left = fifo_peek_head ().abspos;
						matched_tag_abspos_right = fifo_peek_nth (matched_tag_length - 1).abspos
						                           + fifo_peek_nth (matched_tag_length - 1).length;
						matched_tag_line = fifo_peek_head ().line;
						matched_tag_pos = fifo_peek_head ().pos;

						for (var i = 0; i < matched_tag_length; ++i)
							fifo_pop ();

						if (child_tag != 0 || child_level != 0) {
							assert (child_tag != 0 && child_level != 0);
							if (links.index (tag).end.length != 0)
								++child_level;
						} else {
							assert (child_tag == 0 && child_level == 0);
							var subcontents = contents[subdoc_start.abspos:matched_tag_abspos_left];
							var subparser = links.index (0).create (links);
							var subdoc = subparser.parse (subcontents, subdoc_start.line, subdoc_start.pos);
							document.add (subdoc);

							if (links.index (tag).end.length != 0) {
								child_tag = tag;
								child_level = 1;
							} else if (fifo_peek_head ().token == TokenType.LEFT_CURLY
							           || fifo_peek_head ().token == TokenType.LEFT_BRACE) {
							    in_child_params = true;
							    child_tag = tag;
							    child_level = 1;
							}
							subdoc_start.abspos = matched_tag_abspos_right;
							subdoc_start.line = matched_tag_line;
							subdoc_start.pos = matched_tag_pos;
						}
						break;

					case TagKind.STOP:
						matched_tag_abspos_left = fifo_peek_head ().abspos;
						matched_tag_abspos_right = fifo_peek_nth (matched_tag_length - 1).abspos
						                           + fifo_peek_nth (matched_tag_length - 1).length;
						matched_tag_line = fifo_peek_head ().line;
						matched_tag_pos = fifo_peek_head ().pos;

						if (links.index (tag).end.length == 0)
							++matched_tag_abspos_left;

						for (var i = 0; i < matched_tag_length; ++i)
							fifo_pop ();

						/* without begin pair */
						if (child_tag == 0 || child_level == 0) {
							assert (child_tag == 0 && child_level == 0);
							var message = string.joinv (null, links.index (tag).end);
							/// Translators: please leave the '%s' construction without any changes.
							prefix_error (last_symb_pos,
							              _(": Unexpected end tag sequence '%s' without begin tag pair."),
							              message);
							token = TokenType.ERROR;
							throw new ParseError.ORPHAN_END (err_str);
						} else {
							assert (child_level != 0);
							--child_level;

							if (tag == child_tag) {
								if (child_level == 0) {
									child_tag = 0;
									var subcontents = contents[subdoc_start.abspos:matched_tag_abspos_left];
									var subparser = links.index (tag).create (links);
									/* parse subdoc */
									var subdoc = subparser.parse (subcontents, subdoc_start.line,
									                              subdoc_start.pos);

									if (subdoc != null) {
										document.add (subdoc);
									} else {
										prefix_error (subdoc_start,
										              _("Error parsing subdoc."));
										token = TokenType.ERROR;
									}

									subdoc_start.abspos = matched_tag_abspos_right;
									subdoc_start.line = matched_tag_line;
									subdoc_start.pos = matched_tag_pos;
								}
							}
						}
						break;
				}

				return token;
			}


			public override IDoc parse (string contents, size_t line, long position) throws ParseError {

				this.contents = contents;
				this.line = line;
				this.position = position;

				scanner.input_text (contents, contents.length);

				TokenType expected_token = 0;
				var doc = new Glob ();

				do {
					expected_token = scan_tex_symbol (doc);

				} while (expected_token == TokenType.NONE
				         && fifo_peek_head().token != TokenType.EOF
				         && fifo_peek_head().token != TokenType.ERROR);

				if (expected_token == TokenType.ERROR)
					scanner.unexp_token (expected_token, null, "symbol", null, null, true);

				return doc;
			}
		}
	}
}

