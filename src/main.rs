mod parser;
mod tree;
mod bytes;
mod srcloc;
mod input_source;

fn main() {
    println!("Hello, world!");
}

/*
Compiler Architecture:
type ParseTree = MarkedTree<SrcLoc>
parser ∷ (InputName, InputStream) → (ParseTable, ParseTree)
show_error ∷ (SrcLoc, ParseTable) → IO ()
*/
