/**
 * LaTeX view.
 *
 * Public system of data view in the LaTeX format.
 */
namespace LAview {

	string dos2unix (string dos_string) {
		var unistring = new StringBuilder ();

		for (var i = 0; dos_string[i] != '\0'; ) {
			if ('\r' == dos_string[i]) {
				switch (dos_string[i + 1]) {
					case '\r':
						if ('\n' == dos_string[i + 2])
							i += 3;
						break;

					case '\n':
						i += 2;
						break;

					default:
						++i;
						break;
				}

				unistring.append_c ('\n');
			} else {
				unistring.append_c (dos_string[i++]);
			}
		}

		return unistring.str;
	}

	/**
	 * Parses LaTeX plain text from UTF-8 string.
	 *
	 * @throws ParseError any error when parsing.
	 */
	public Glob parse(string text) throws Parsers.ParseError {

		/* escaping TeX document */
		var escaped_text = text.escape (" \n\r\t");

		/* line breaks: dos -> unix */
		var u_escaped_text = dos2unix (escaped_text);

		/* TeX scanner initialization */
		var group = new Parsers.ParserFactory ();
		var parser = new Parsers.GlobParser (group.group);

		/* parse TeX */
		var doc = parser.parse (u_escaped_text, 0, 0);

		return doc as Glob;
	}

	/**
	 * Converts plain text string to LaTeX string.
	 */
	public string plain_to_tex(string text) {
		var str = new StringBuilder ();

		for (var i = 0; text[i] != '\0'; ++i) {
			switch (text[i]) {
				case '$':
				case '&':
				case '%':
				case '#':
				case '_':
				case '{':
				case '}':
					str.append_c ('\\');
					str.append_c (text[i]);
					break;

				case '\\':
					str.append ("\\textbackslash ");
					break;

				case '~':
					str.append ("\\~{}");
					break;

				case '^':
					str.append ("\\^{}");
					break;

				default:
					str.append_c (text[i]);
					break;
			}
		}

		return str.str;
    }
}
