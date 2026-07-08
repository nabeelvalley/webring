import gleam/dict
import gleam/option
import gleam/result
import gleam/uri
import wisp.{type Request}

pub fn referer_domain(req: Request) {
  let header =
    req.headers
    |> dict.from_list
    |> dict.get("referer")
    |> result.try(uri.parse)
    |> option.from_result
    |> option.then(fn(u) { u.host })

  let query =
    req
    |> wisp.get_query
    |> dict.from_list
    |> dict.get("referer")
    |> option.from_result

  header |> option.or(query)
}
