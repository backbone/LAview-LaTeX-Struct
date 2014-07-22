namespace LAview {

	/**
	 * Graphics in the LaTeX document.
	 *
	 * Specified by '\includegraphics' tag in the LaTeX code.
	 */
	public class Graphics : ADoc {

		/**
		 * All unknown parameters.
		 */
		public string rest_params = "";

		/**
		 * Path to the image on the disk.
		 */
		public string path = "";

		/**
		 * Width of the image.
		 *
		 * For ex: 3.22, 128
		 */
		public double width;

		/**
		 * Width units of the image.
		 *
		 * For ex: bp, cc, cm, dd, em, ex, in, mm, pc, pt, sp <<BR>>
		 * or \textwidth, \columnwidth, \pagewidth,
		 * \linewidth, \textwidth, \paperwidth
		 */
		public string width_unit = "";

		/**
		 * Height of the image.
		 *
		 * For ex: 3.22, 128
		 */
		public double height;

		/**
		 * Height units of the image.
		 *
		 * For ex: bp, cc, cm, dd, em, ex, in, mm, pc, pt, sp <<BR>>
		 * or \textwidth, \columnwidth, \pagewidth,
		 * \linewidth, \textwidth, \paperwidth
		 */
		public string height_unit = "";

		/**
		 * Constructs a new //Graphics// by it's properties.
		 *
		 * @param path path to the image on the disk.
		 */
		public Graphics.with_params (string path = "") {
			this.path = path;
		}

		private Graphics () {}

		/**
		 * Gets a copy of the //Graphics//.
		 */
		public override IDoc copy () {
			var clone = new Graphics.with_params (path);
			clone.width = width;
			clone.height = height;
			clone.width_unit = width_unit;
			clone.height_unit = height_unit;
			clone.rest_params = rest_params;
			return clone;
		}

		/**
		 * Generates LaTeX string for the //Graphics//.
		 */
		public override string generate () {
			var str = new StringBuilder ("\\includegraphics[");
			if (width != 0)
				str.append_printf ("width=%f%s,", width, width_unit);
			if (height != 0)
				str.append_printf ("height=%f%s,", height, height_unit);
			if (rest_params != "")
				str.append_printf ("%s,", rest_params);
			if (str.str[str.len - 1] == ',')
				str.len -= 1;
			str.append_printf ("]{%s}", path);
			return str.str;
		}
	}
}
