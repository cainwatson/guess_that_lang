# GuessThatLang

> View random code snippets and try to guess what programming language they're written in!

## Getting Started

### Requirements:

- Elixir 1.11.0 (Erlang OTP 23)
- Node 14.12.0
- Github Access Token (no scopes required)

### Starting the app

1. To setup your development environment, run `mix setup` in the project root to install the dependencies.
2. Once that finishes, you can run `mix s` to start the server up. The server will look for a `GITHUB_ACCESS_TOKEN` environment variable to use, so make sure to export one before starting the server: `GITHUB_ACCESS_TOKEN=xxxx mix s`

### Starting with Docker

```sh
$ GITHUB_ACCESS_TOKEN=xxxx docker compose up -d
```
