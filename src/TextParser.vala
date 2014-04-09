namespace LAview {

	namespace Parsers {

		class TextParser : Parser {

			public TextParser (Array<Link> links) {
				base (links);
			}

			public override IDoc parse (string contents, size_t line, long position) throws ParseError {

				this.contents = contents;
				this.line = line;
				this.position = position;

				return new Text (contents.compress ());
			}
		}
	}
}
