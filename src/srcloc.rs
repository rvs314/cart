use std::io::Read;

use crate::parser::Parser;

/// The current location in an input source
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ParseLoc {
    line: u64,
    char: u64,
}

impl ParseLoc {
    /// Returns the initial FileLoc: line 1, char 0
    pub fn start() -> ParseLoc {
        ParseLoc { line: 1, char: 0 }
    }

    /// Moves the location to the next character
    pub fn next_char(&mut self) {
        self.char += 1;
    }

    /**
    Moves the location to the next line,
    resetting the character
    */
    pub fn next_line(&mut self) {
        self.line += 1;
        self.char = 0; }

    /// Creates a new file location
    pub fn new(line: u64, char: u64) -> ParseLoc {
        ParseLoc { line, char }
    }
}

/// A specifc point in a specific input source
pub struct SrcLoc<'a, R: Read> {
    loc: ParseLoc,
    src: &'a Parser<'a, R>,
}

impl<'a, R: Read> SrcLoc<'a, R> {
    pub fn new(loc: ParseLoc, src: &'a Parser<'a, R>) -> SrcLoc<'a, R> {
        SrcLoc { loc, src }
    }
}
