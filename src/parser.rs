use std::io::{self, BufRead};

use crate::{input_source::InputSrc, srcloc::SrcLoc, tree::MarkedTree};

pub struct Parser<R: BufRead> {
    src: InputSrc<R>,
}

#[derive(Clone)]
pub struct ParseError<'a, R: BufRead> {
    at: SrcLoc<'a, R>,
    msg: String,
}

type ParseTree<'a, R> = MarkedTree<SrcLoc<'a, R>, String>;
type ParseRes<'a, R, T> = Result<T, ParseError<'a, R>>;

impl<R: BufRead> Parser<R> {
    fn error<'a>(&'a self, msg: String) -> ParseError<'a, R> {
        ParseError {
            at: self.src.here(),
            msg,
        }
    }

    fn input_error<'a>(&'a self, e: io::Error) -> ParseError<'a, R> {
        self.error(format!("Input Error: {}", e.to_string()))
    }

    fn peek<'a>(&'a mut self) -> Option<ParseRes<'a, R, u8>> {
        Some(
            self.src
                .peek()?
                .map_err(move |x: io::Error| self.input_error(x)),
        )
    }

    fn pop<'a>(&'a mut self) -> Option<ParseRes<'a, R, u8>> {
        Some(
            self.src
                .pop()?
                .map_err(move |x: io::Error| self.input_error(x)),
        )
    }

    fn eat<'a>(&'a mut self, c: u8) -> ParseRes<'a, R, ()> {
        let k = self.pop().map(|v| v.map(|z| (z == c, z)));
        Err(match k {
            Some(Ok((true, _))) => return Ok(()),
            Some(Ok((false, v))) => self.error(format!(
                "Expected to see a {}, but instead saw a {}",
                c as char, v as char
            )),
            Some(Err(e)) => e,
            None => self.error(format!(
                "Expected to see a {}, but hit the end of file",
                c as char
            )),
        })
    }

    pub fn read<'a>(&'a mut self) -> ParseRes<'a, R, ParseTree<'a, R>> {
        let c = self.src.peek().ok_or(ParseError {
            at: self.src.here(),
            msg: format!("Expected to see something here, but didn't"),
        })?.map_err(|e| self.input_error(e));
        todo!()
    }
}
