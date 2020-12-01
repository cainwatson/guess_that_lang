defmodule GuessThatLangWeb.GameLive do
  use GuessThatLangWeb, :live_view

  @languages [
    "clojure",
    "cobol",
    "cpp",
    "csharp",
    "css",
    "elixir",
    "elm",
    "erlang",
    "fortran",
    "fsharp",
    "go",
    "java",
    "javascript",
    "kotlin",
    "lua",
    "perl",
    "php",
    "python",
    "ruby",
    "rust",
    "scala",
    "scheme",
    "scss",
    "swift",
    "typescript"
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        fetch_snippet(socket)
      else
        assign(socket,
          is_correct: false,
          has_answered: false,
          choices: [],
          correct_answer: nil,
          snippet: nil
        )
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("answer", %{"choice" => choice}, socket) do
    is_correct = choice == socket.assigns.correct_answer
    {:noreply, assign(socket, is_correct: is_correct, has_answered: true)}
  end

  @impl true
  def handle_event("next", _value, socket) do
    {:noreply, fetch_snippet(socket)}
  end

  defp fetch_snippet(socket) do
    choices =
      @languages
      |> Enum.shuffle()
      |> Enum.take(4)

    correct_answer = Enum.random(choices)

    case GuessThatLang.CodeSearcher.search(language: correct_answer) do
      {:ok, %{content: snippet}} ->
        assign(socket,
          is_correct: false,
          has_answered: false,
          choices: choices,
          correct_answer: correct_answer,
          snippet: snippet
        )

      _ ->
        Process.sleep(1000)

        assign(socket,
          is_correct: false,
          has_answered: false,
          choices: ["javascript", "python", "java", "haskell"],
          correct_answer: "javascript",
          snippet: "const a = 2;
    let b = 2;"
        )
    end
  end
end
