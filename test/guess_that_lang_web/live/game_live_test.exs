defmodule GuessThatLangWeb.PageLiveTest do
  use GuessThatLangWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "renders code snippet from CodeSearcher", %{conn: conn} do
    GuessThatLang.CodeSearcher.MockSearcher
    |> expect(:search, fn _opts ->
      {:ok,
       %{
         content: "defmodule Hello do
  def world do
    IO.puts(\"Hello, world!\")
  end
end",
         language: "Elixir"
       }}
    end)

    {:ok, page_live, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ "Guess That Lang!"
    assert render(page_live) =~ "defmodule Hello do"
  end
end
