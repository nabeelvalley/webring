import app/request
import app/ring
import gleam/option
import wisp

pub type Context {
  Context(sites: List(ring.Site), ring: ring.Ring, static_dir: String)
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) {
  let req = wisp.method_override(req)

  use <- wisp.log_request(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_dir)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  log_referer(req)

  handle_request(req)
}

fn log_referer(req: wisp.Request) {
  let referer = request.referer_domain(req) |> option.unwrap("unknown")
  wisp.log_info("Referer domain: " <> referer)
}
