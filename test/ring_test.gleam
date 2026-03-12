import app/ring
import gleam/dict

pub fn ring_build_test() {
  let a = ring.Site("a", "a", "a")
  let b = ring.Site("b", "b", "b")
  let c = ring.Site("c", "c", "c")
  let d = ring.Site("d", "d", "d")

  let sites = [a, b, c, d]
  let expected =
    dict.from_list([
      #("a", ring.Link(d, b)),
      #("b", ring.Link(a, c)),
      #("c", ring.Link(b, d)),
      #("d", ring.Link(c, a)),
    ])

  let result = ring.build_ring(sites)

  assert result == expected
}
