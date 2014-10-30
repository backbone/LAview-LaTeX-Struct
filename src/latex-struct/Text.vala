namespace LAview {

	/**
	 * Text in the LaTeX document.
	 */
	public class Text : ADoc {

		/**
		 * Plain text in UTF-8 string.
		 */
		public string text { get; set; default = ""; }

		/**
		 * Constructs a new ``Text``.
		 *
		 * @param text UTF-8 string.
		 */
		public Text (string text) {
			this.text = text;
		}

		/**
		 * Gets a copy of the ``Text``.
		 */
		public override IDoc copy () {
			return new Text (text);
		}

		/**
		 * Generates LaTeX string for the ``Text``.
		 */
		public override string generate () {
			return text;
		}
	}
}
