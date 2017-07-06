namespace LAview {

	namespace Table {

		/**
		 * List of Column Parameters.
		 */
		public class ColParams : ADocList<ColParam> {

			protected override ADocList<ColParam> create_default_instance () { return new ColParams (); }

			/**
			 * Constructs a new empty ``ColParams``.
			 */
			public ColParams () {}
		}
	}
}
