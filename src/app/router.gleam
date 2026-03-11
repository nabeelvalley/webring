import app/ring
import app/web.{type Context, middleware}
import gleam/dict
import gleam/list
import gleam/result
import gleam/uri
import lustre/attribute
import lustre/element
import lustre/element/html
import wisp.{type Request, type Response}

fn link_item(str) {
  let origin =
    uri.parse(str)
    |> result.map(uri.origin)
    |> result.flatten
    |> result.unwrap(or: str)

  html.li([], [
    html.a([attribute.href(str)], [
      html.text(origin),
    ]),
  ])
}

fn index(ctx: Context) {
  let links =
    ctx.links
    |> list.map(link_item)
    |> html.ul([], _)

  html.main([], [
    html.h1([], [html.text("Welcome to Nabeel's Webring")]),
    html.p([], [
      html.a([attribute.href("/random")], [html.text("Random Link")]),
    ]),
    links,
  ])
  |> element.to_document_string
  |> wisp.html_response(200)
}

fn referer(req: Request) {
  req.headers
  |> dict.from_list
  |> dict.get("referer")
}

fn previous(req: Request, ctx: Context) {
  let get_link = dict.get(ctx.ring, _)

  let ref =
    referer(req)
    |> result.map(get_link)
    |> result.flatten
    |> result.map(ring.prev)

  case ref {
    Ok(from) -> wisp.redirect(from)
    _ -> random(ctx)
  }
}

fn next(req: Request, ctx: Context) {
  let get = dict.get(ctx.ring, _)

  let ref =
    referer(req)
    |> result.map(get)
    |> result.flatten
    |> result.map(ring.next)

  case ref {
    Ok(from) -> wisp.redirect(from)
    _ -> random(ctx)
  }
}

fn random(ctx: Context) {
  let assert Ok(random) = ctx.links |> list.shuffle |> list.first
  wisp.redirect(random)
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _ <- middleware(req)

  case wisp.path_segments(req) {
    [] -> index(ctx)
    ["previous"] -> previous(req, ctx)
    ["next"] -> next(req, ctx)
    ["random"] -> random(ctx)
    _ -> wisp.not_found()
  }
}
