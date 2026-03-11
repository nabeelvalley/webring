import app/ring
import app/router
import app/web.{Context}
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn sites() {
  [
    "https://nabeelvalley.co.za",
    "https://zahrahmohamed.co.za",
    "https://link-book.nabeelvalley.co.za",
    "https://all-the-greens.netlify.app",
  ]
}

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(wisp_secret_key) = env.get_string("WISP_SECRET_KEY")

  let links = sites()
  let ring = ring.build_ring(links)
  let ctx = Context(links, ring)

  echo ctx

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, wisp_secret_key)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
