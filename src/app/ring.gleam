import gleam/dict.{type Dict}

pub type Link {
  Link(prev: String, next: String)
}

pub type Ring =
  Dict(String, Link)

pub fn build_ring_rec(first, prev, links) {
  let link = Link(prev, first)
  case links {
    [current] -> dict.from_list([#(current, link)])
    [current, ..rest] ->
      build_ring_rec(first, current, rest)
      |> dict.insert(current, link)
    _ ->
      dict.from_list([
        #(first, Link(prev, prev)),
        #(prev, Link(first, first)),
      ])
  }
}

pub fn build_ring(links) {
  case links {
    [first, second, ..rest] -> build_ring_rec(first, second, rest)
    _ -> dict.new()
  }
}

// pub fn random_link(ring: Ring) {
//   todo
// }

pub fn next(link: Link) {
  link.next
}

pub fn prev(link: Link) {
  link.prev
}
