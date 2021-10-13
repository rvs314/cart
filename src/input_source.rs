use std::io::{self, BufRead, Lines};

use crate::{bytes::ByteString, srcloc::{SrcIndex, SrcLoc}};

pub struct InputSrc<R: BufRead> {
    source: Lines<R>,
    lines: Vec<ByteString>,
    pos: SrcIndex,
    this_line: ByteString,
}

impl<R: BufRead> InputSrc<R> {
    pub fn new(r: R) -> InputSrc<R> {
        InputSrc {
            source: r.lines(),
            lines: vec![],
            pos: SrcIndex::start(),
            this_line: vec![],
        }
    }

    fn force_line(&mut self) -> Option<io::Result<()>> {
        Some(self.source.next()?.map(|l| {
            self.this_line = l.bytes().collect();
            self.lines.push(self.this_line.clone());
            self.this_line.reverse();
            self.pos.next_line();
        }))
    }

    /// Peeks the next character from the input stream,
    /// reading another line if needed
    pub fn peek(&mut self) -> Option<io::Result<u8>> {
        Some(match self.this_line.last() {
            Some(c) => Ok(*c),
            None => match self.force_line()? {
                Ok(()) => self.peek()?,
                Err(e) => Err(e),
            },
        })
    }

    /// Pops the next character from the input stream,
    /// reading another line if needed
    pub fn pop(&mut self) -> Option<io::Result<u8>> {
        Some(match self.this_line.pop() {
            Some(c) => {
                self.pos.next_char();
                Ok(c)
            }
            None => match self.force_line()? {
                Ok(()) => self.pop()?,
                Err(e) => Err(e),
            },
        })
    }

    /// Returns the current source location
    pub fn here<'a>(&'a self) -> SrcLoc<'a, R> {
        SrcLoc::new(self.pos, self)
    }
}
