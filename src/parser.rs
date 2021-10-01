use std::io::{self, Bytes, Read};
use std::iter::Peekable;

use crate::bytes::ByteString;
use crate::srcloc::{ParseLoc, SrcLoc};
use crate::tree::MarkedTree;

pub type ParseTree<'a, R> = MarkedTree<SrcLoc<'a, R>, ByteString>;
type ParseRes<'a, R, V> = Result<V, ParserError<'a, R>>;

pub enum ParserError<'a, R: Read> {
    IOError(io::Error),
    ParsingError {
        location: SrcLoc<'a, R>,
        message: String,
    },
}

pub struct Parser<'a, R: Read> {
    name: &'a str,
    input: Peekable<Bytes<R>>,
    here: ParseLoc,
    lines: Vec<ByteString>,
}

impl<'a, R: Read> Parser<'a, R> {
    pub fn new(name: &'a str, input: Bytes<R>) -> Parser<'a, R> {
        Parser {
            name,
            input: input.peekable(),
            lines: Vec::new(),
            here: ParseLoc::start(),
        }
    }

    /// Returns a src loc pointing to the
    /// current location in the current input source
    pub fn here(&'a self) -> SrcLoc<'a, R> {
        SrcLoc::new(self.here, self)
    }

    /// Peeks a character from the input stream
    fn peek(&'a mut self) -> ParseRes<'a, R, Option<u8>> {
        match self.input.peek() {
            Some(Ok(c)) => Ok(Some(*c)),
            Some(Err(c)) => Err(ParserError::IOError(c)),
            None => Ok(None),
        }
    }

    fn pop(&'a mut self) -> ParseRes<'a, R, Option<u8>> {
        match self.input.next() {
            Some(Ok(c)) => Ok(Some(c)),
            Some(Err(c)) => Err(ParserError::IOError(c)),
            None => Ok(None),
        }
    }

    /// Read an S-expression
    pub fn read() -> ParseRes<'a, R, ParseTree<'a, R>> {
        todo!()
    }
}

impl<'a, R: 'a + Read> Iterator for Parser<'a, R> {
    type Item = ParseRes<'a, R, ParseTree<'a, R>>;

    fn next(&mut self) -> Option<Self::Item> {
        todo!()
    }
}
