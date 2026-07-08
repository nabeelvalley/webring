import app/request
import app/ring
import app/web.{type Context, middleware}
import gleam/http
import gleam/list
import gleam/option.{Some}
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

  let join_link =
    html.li([], [
      html.a(
        [attribute.href("https://nabeelvalley.co.za/blog/2026/12-03/webring")],
        [html.text("Join the webring!")],
      ),
    ])

  let random_link =
    html.li([], [
      html.a([attribute.href("/random")], [html.text("Random Link")]),
    ])

  let links = [join_link] |> list.append(links) |> list.append([random_link])

  main([
    html.h1([], [html.text("Welcome to Nabeel's Webring")]),
    html.nav([attribute.title("Links")], [
      html.ul([], links),
    ]),
  ])
  |> element.to_document_string
  |> wisp.html_response(200)
}

fn redirect(req, ctx: Context, to_site) {
  request.referer_domain(req)
  |> option.then(to_site(ctx.ring, _))
  |> option.map(ring.to_href)
  |> option.map(wisp.redirect)
  |> option.unwrap(random(req, ctx))
}

fn previous(req: Request, ctx: Context) {
  redirect(req, ctx, ring.prev)
}

fn next(req: Request, ctx: Context) {
  redirect(req, ctx, ring.next)
}

fn random(req: Request, ctx: Context) {
  let ref = request.referer_domain(req)

  let sites = case ref {
    Some(domain) -> ctx.sites |> list.filter(fn(s) { s.domain != domain })
    _ -> ctx.sites
  }

  let assert Ok(random) = sites |> list.shuffle |> list.first

  random |> ring.to_href |> wisp.redirect
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _ <- middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    http.Get, [] -> index(ctx)
    http.Get, ["previous"] -> previous(req, ctx)
    http.Get, ["next"] -> next(req, ctx)
    http.Get, ["random"] -> random(req, ctx)
    http.Get, ["healthcheck"] -> wisp.ok()
    _, _ -> wisp.not_found()
  }
}
