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
        assign_snippet(socket)
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
    {:noreply, assign_snippet(socket)}
  end

  defp assign_snippet(socket) do
    choices =
      @languages
      |> Enum.shuffle()
      |> Enum.take(4)

    correct_answer = Enum.random(choices)

    with {:ok, %{content: content}} <- GuessThatLang.CodeSearcher.search(language: correct_answer) do
      lines = String.split(content, "\n")
      number_of_lines = Enum.random(8..14)
      start_line_number = Enum.random(0..abs(length(lines) - 1 - number_of_lines))
      end_line_number = start_line_number + number_of_lines

      snippet =
        lines
        |> Enum.slice(start_line_number..end_line_number)
        |> Enum.join("\n")

      assign(socket,
        is_correct: false,
        has_answered: false,
        choices: choices,
        correct_answer: correct_answer,
        snippet: snippet
      )
    end
  end
end
