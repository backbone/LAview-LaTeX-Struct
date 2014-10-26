namespace LAview {

	/**
	 * Interface of any LaTeX Document.
	 */
	public interface IDoc : Object {

		/**
		 * Gets a copy of the ``IDoc``.
		 */
		public abstract IDoc copy ();

		/**
		 * Generates LaTeX string for the ``IDoc``.
		 */
		public abstract string generate ();
	}

	/**
	 * Any non-iterable LaTeX Document.
	 */
	public abstract class ADoc : Object, IDoc {

		protected ADoc () {}

		/**
		 * Gets a copy of the ``ADoc``.
		 */
		public virtual IDoc copy () {
			return Object.new (this.get_type ()) as IDoc;
		}

		/**
		 * Generates LaTeX string for the ``ADoc``.
		 */
		public virtual string generate () { return ""; }
	}

	/**
	 * Any iterable LaTeX Document.
	 */
	public abstract class ADocList : Gee.ArrayList<IDoc>, IDoc {

		protected ADocList () {}

		/**
		 * Object.new (this.get_type ()) doesn't work for me for ArrayList.
		 */
		protected abstract ADocList create_default_instance ();

		/**
		 * Gets a copy of the ``ADocList``.
		 */
		public virtual IDoc copy () {
			var clone = create_default_instance ();

			foreach (IDoc dociface in this)
				clone.add (dociface.copy () as IDoc);

			return clone;
		}

		/**
		 * Generates LaTeX string for the ``ADocList``.
		 */
		public virtual string generate () {
			var result = new StringBuilder ();

			foreach (IDoc dociface in this)
				result.append (dociface.generate ());

			return result.str;
		}
	}
}
