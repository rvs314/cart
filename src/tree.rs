/// An n-child tree where each leaf and branch
/// is marked with a `Mark`, and each leaf holds
/// a `Mark` and a `Payload`
#[derive(Debug)]
pub enum MarkedTree<Mark, Payload> {
    Branch(Mark, Vec<MarkedTree<Mark, Payload>>),
    Leaf(Mark, Payload)
}
