import app/request
import app/ring
import app/web.{type Context, middleware}
import gleam/list
import gleam/result
import lustre/attribute
import lustre/element
import lustre/element/html
import wisp.{type Request, type Response}

fn link_item(s) {
  html.li([], [
    html.a([attribute.href(s |> ring.to_href)], [
      html.text(s.title),
    ]),
    html.text(" by " <> s.author),
  ])
}

fn main(el) {
  html.html(
    [
      attribute.lang("en"),
    ],
    [
      html.head([], [
        html.title([], "Nabeel's Webring"),
        html.meta([attribute.charset("UTF-8")]),
        html.meta([
          attribute.name("viewport"),
          attribute.content("width=device-width, initial-scale=1.0"),
        ]),
        html.link([
          attribute.rel("stylesheet"),
          attribute.href("/static/main.css"),
        ]),
      ]),
      html.body([], [html.main([], el)]),
    ],
  )
}

fn index(ctx: Context) {
  let links =
    ctx.sites
    |> list.map(link_item)
    |> html.ul([], _)

  let nav = html.nav([], [links])

  main([
    html.h1([], [html.text("Welcome to Nabeel's Webring")]),
    html.p([], [
      html.a([attribute.href("/random")], [html.text("Random Link")]),
    ]),
    nav,
  ])
  |> element.to_document_string
  |> wisp.html_response(200)
}

fn previous(req: Request, ctx: Context) {
  let ref =
    request.referer_domain(req)
    |> result.try(ring.prev(ctx.ring, _))

  case ref {
    Ok(from) -> wisp.redirect(from |> ring.to_href)
    _ -> random(req, ctx)
  }
}

fn next(req: Request, ctx: Context) {
  let ref =
    request.referer_domain(req)
    |> result.try(ring.next(ctx.ring, _))

  case ref {
    Ok(from) -> wisp.redirect(from |> ring.to_href)
    _ -> random(req, ctx)
  }
}

fn random(req: Request, ctx: Context) {
  let ref = request.referer_domain(req)

  let sites = case ref {
    Ok(domain) -> ctx.sites |> list.filter(fn(s) { s.domain != domain })
    _ -> ctx.sites
  }

  let assert Ok(random) = sites |> list.shuffle |> list.first

  wisp.redirect(random |> ring.to_href)
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _ <- middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> index(ctx)
    ["previous"] -> previous(req, ctx)
    ["next"] -> next(req, ctx)
    ["random"] -> random(req, ctx)
    ["healthcheck"] -> wisp.ok()
    _ -> wisp.not_found()
  }
}
