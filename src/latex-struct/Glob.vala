namespace LAview {

	/**
	 * List of any LaTeX documents except Glob documents.
	 */
	public class Glob : ADocList<IDoc> {

		protected override ADocList create_default_instance () { return new Glob (); }

		/**
		 * Constructs a new empty ``Glob``.
		 */
		public Glob () {}
	}
}
