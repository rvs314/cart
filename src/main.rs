mod parser;
mod tree;
mod bytes;
mod srcloc;

fn main() {
    println!("Hello, world!");
}

/*
Compiler Architecture:
type ParseTree = MarkedTree<SrcLoc>
parser ∷ (InputName, InputStream) → (ParseTable, ParseTree)
show_error ∷ (SrcLoc, ParseTable) → IO ()
*/
