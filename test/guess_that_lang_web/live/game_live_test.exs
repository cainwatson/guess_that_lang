defmodule GuessThatLangWeb.PageLiveTest do
  use GuessThatLangWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mox
  import GuessThatLang.Mocks.CodeSearcher

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "renders code snippet", %{conn: conn} do
    GuessThatLang.CodeSearcher.MockSearcher
    |> expect(:search, &search_payload_elixir/1)

    {:ok, view, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ "Guess That Lang!"
    assert render(view) =~ "defmodule Hello do"
  end

  test "renders another code snippet after next", %{conn: conn} do
    GuessThatLang.CodeSearcher.MockSearcher
    |> expect(:search, &search_payload_elixir/1)
    |> expect(:search, &search_payload_javascript/1)
    |> expect(:search, &search_payload_elixir/1)

    {:ok, view, _disconnected_html} = live(conn, "/")

    assert render_click(view, "next") =~ "const express = require("
    assert render_click(view, "next") =~ "defmodule Hello do"
  end
end
