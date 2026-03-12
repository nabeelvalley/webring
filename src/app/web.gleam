import app/request
import app/ring
import gleam/result
import wisp

pub type Context {
  Context(sites: List(ring.Site), ring: ring.Ring)
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) {
  let req = wisp.method_override(req)

  log_referer(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}

fn log_referer(req: wisp.Request) {
  let referer = request.referer_domain(req) |> result.unwrap("unknown")
  wisp.log_info("Referer domain: " <> referer)
}
