namespace LAview {

	namespace Parsers {

		delegate Parser ParserDelegate (Array<Link> links);

		class Link {

			public string[] begin;
			public string[] end;
			public unowned ParserDelegate create;

			public Link (string[] begin, string[] end, ParserDelegate? create = null) {
				this.begin = begin; this.end = end; this.create = create;
			}
		}

		class ParserFactory {

			public Array<Link> group = new Array<Link> ();

			public virtual TextParser make_text_parser (Array<Link> links) {
				return new TextParser (links);
			}

			public virtual LongtableParser make_longtable_parser (Array<Link> links) {
				return new LongtableParser (links);
			}

			public virtual GraphicsParser make_graphics_parser (Array<Link> links) {
				return new GraphicsParser (links);
			}

			public virtual TabularParser make_tabular_parser (Array<Link> links) {
				return new TabularParser (links);
			}

			public ParserFactory () {
				group.append_val (new Link ({}, {},
				                            links => { return make_text_parser (links); }));
				group.append_val (new Link ({"\\", "\\begin", "{", "longtable",    "}"},
				                            {"\\", "\\end",   "{", "longtable",    "}"},
				                            links => { return make_longtable_parser (links); }));
				group.append_val (new Link ({"\\", "\\includegraphics"}, {},
				                            links => { return make_graphics_parser (links); }));
				group.append_val (new Link ({"\\", "\\begin", "{", "tabular",      "}"},
				                            {"\\", "\\end",   "{", "tabular",      "}"},
				                            links => { return make_tabular_parser (links); }));
				group.append_val (new Link ({"\\", "\\begin", "{", "tabular", "*", "}"},
				                            {"\\", "\\end",   "{", "tabular", "*", "}"},
				                            links => { return make_tabular_parser (links); }));
			}
		}
	}
}
