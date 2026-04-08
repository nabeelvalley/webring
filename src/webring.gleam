import app/ring
import app/router
import app/web.{Context}
import config
import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  wisp.set_logger_level(wisp.DebugLevel)

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(wisp_secret_key) = env.get_string("WISP_SECRET_KEY")

  let ring = ring.build_ring(config.sites)
  let ctx = Context(config.sites, ring, static_dir() |> echo)

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, wisp_secret_key)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

fn static_dir() {
  let assert Ok(priv_directory) = wisp.priv_directory("webring")
  priv_directory <> "/static"
}
