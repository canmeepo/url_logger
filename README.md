# UrlLogger

### Run

```bash
$ git clone https://github.com/canmeepo/url_logger.git url_logger

$ cd url_logger

$ mix deps.get

$ mix run --no-halt or (iex -S mix)
```

servering starting on port 8080

make sure you run redis on port 6379

### tesing

```bash
$ mix test
```

### endpoints

get - /visited_domains?from=%{ms}&to%{ms}
post - /visited_links
