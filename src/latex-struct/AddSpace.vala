namespace LAview {

	namespace Table {

		/**
		 * Vertical Space in any {@link ATable}
		 */
		public class AddSpace : ADoc {

			/**
			 * Value of the vertical space.
			 *
			 * Possible values: [0-9]+{bp,cc,cm,dd,em,ex,in,mm,pc,pt,sp} <<BR>>
			 * or [0-9]+.[0-9][0-9]{\textwidth,columnwidth,paperwidth,linewidth,textheight,paperheight}
			 */
			public string height { get; set; default = ""; }

			/**
			 * Constructs a new ``AddSpace`` based on value.
			 *
			 * @param height [0-9]+{bp,cc,cm,dd,em,ex,in,mm,pc,pt,sp} <<BR>>
			 * or [0-9]+.[0-9][0-9]{\textwidth,columnwidth,paperwidth,linewidth,textheight,paperheight}
			 */
			public AddSpace.with_params (string height) {
				this.height = height;
			}

			private AddSpace () {}

			/**
			 * Gets a copy of the ``AddSpace``.
			 */
			public override IDoc copy () {
				return new AddSpace.with_params (height);
			}

			/**
			 * Generates LaTeX string for the ``AddSpace``.
			 */
			public override string generate () {
				return height;
			}
		}
	}
}
