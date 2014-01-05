namespace LAview {
    public errordomain ParseError {
        UNEXPECTED_SYMBOL,
    }

    public void parse(string text) throws ParseError {
        print("TeX successfully parsed!\n");
        if (0 != 0)
            throw new ParseError.UNEXPECTED_SYMBOL("Parsing error!");
    }

    public string plain_to_tex(string text) {
        return "Parsed text here...";
    }
}
