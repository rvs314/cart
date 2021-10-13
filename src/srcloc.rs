use std::io::BufRead;

use crate::input_source::InputSrc;

/// The current location in an input source
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SrcIndex {
    line: u64,
    char: u64,
}

impl SrcIndex {
    /// Returns the initial index: line 1, char 0
    pub fn start() -> SrcIndex {
        SrcIndex { line: 1, char: 0 }
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
    pub fn new(line: u64, char: u64) -> SrcIndex {
        SrcIndex { line, char }
    }
}

/// A specifc point in a specific input source
#[derive(Clone, Copy)]
pub struct SrcLoc<'a, R: BufRead> {
    loc: SrcIndex,
    src: &'a InputSrc<R>,
}

impl<'a, R: BufRead> SrcLoc<'a, R> {
    pub fn new(loc: SrcIndex, src: &'a InputSrc<R>) -> SrcLoc<'a, R> {
        SrcLoc { loc, src }
    }
}
