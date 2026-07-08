# Nabeel's Webring

> Don't know what Webrings are? [Wikipedia's got you covered](https://en.wikipedia.org/wiki/Webring)

## Would You like to Join?

That's great! You need to do two things:

1. Add the following HTML to your site's footer (or some variation of it - style it however you like!)

```html
<section>
  <a href="https://webring.nabeelvalley.co.za"><em>Webring</em></a>

  <ul class="links">
    <li><a href="https://webring.nabeelvalley.co.za/previous?referer=your.domain.com">Previous</a></li>
    <li><a href="https://webring.nabeelvalley.co.za/random?referer=your.domain.com">Random</a></li>
    <li><a href="https://webring.nabeelvalley.co.za/next?referer=your.domain.com">Next</a></li>
  </ul>
</section>
```

> Make sure to replace the `your.domain.com` with your actual domain - as listed in `src/config.gleam` of course

2. Add your site to the list at `src/config.gleam` and you'll automatically be a part of the ring

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
