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

    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "defmodule Hello do"
  end

  test "renders answer choices", %{conn: conn} do
    GuessThatLang.CodeSearcher.MockSearcher
    |> expect(:search, &search_payload_elixir/1)

    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "button:nth-of-type(4)")
    # Doesn't pass because the view determines the language to search for
    # assert has_element?(view, "button", "Elixir")
  end

  test "renders another code snippet after next", %{conn: conn} do
    GuessThatLang.CodeSearcher.MockSearcher
    |> expect(:search, &search_payload_elixir/1)
    |> expect(:search, &search_payload_javascript/1)
    |> expect(:search, &search_payload_elixir/1)

    {:ok, view, _html} = live(conn, "/")

    assert render_click(view, "next") =~ "const express = require("
    assert render_click(view, "next") =~ "defmodule Hello do"
  end
end
