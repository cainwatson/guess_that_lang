defmodule GuessThatLangWeb.GameLive do
  use GuessThatLangWeb, :live_view

  @languages [
    "C",
    "C#",
    "C++",
    "COBOL",
    "CSS",
    "Clojure",
    "CoffeeScript",
    "Common Lisp",
    "Dart",
    "Elixir",
    "Elm",
    "Erlang",
    "F#",
    "Fortran",
    "Go",
    "GraphQL",
    "Groovy",
    "HTML",
    "Haskell",
    "Java",
    "JavaScript",
    "Kotlin",
    "Lua",
    "Markdown",
    "OCaml",
    "Objective-C",
    "PHP",
    "Perl",
    "PowerShell",
    "Prolog",
    "Python",
    "R",
    "Ruby",
    "Rust",
    "SCSS",
    "SQL",
    "Sass",
    "Scala",
    "Scheme",
    "Shell",
    "Swift",
    "TypeScript",
    "Visual Basic .NET"
  ]
  @min_snippet_length Application.get_env(:guess_that_lang, :min_snippet_length)

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket,
      hard_mode: false,
      is_correct: false,
      has_answered: false,
      choices: [],
      correct_answer: nil,
      snippet: nil,
      # game_options_changeset:
    )
    socket = if connected?(socket) do
               assign_snippet(socket)
             else
               socket
             end

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle-hard-mode", %{"value" => "on"}, socket) do
    {:noreply, assign(socket, hard_mode: true) |> assign_snippet}
  end

  def handle_event("toggle-hard-mode", _, socket) do
    {:noreply, assign(socket, hard_mode: false)}
  end

  def handle_event("answer-hard-mode", a, socket) do
    IO.inspect a
    {:noreply, socket}
  end

  def handle_event("answer", %{"choice" => choice}, socket) do
    is_correct = choice == socket.assigns.correct_answer
    {:noreply, assign(socket, is_correct: is_correct, has_answered: true)}
  end

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
      {start_line_number, end_line_number} = calculate_file_subset(lines)

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

  defp calculate_file_subset(lines) when length(lines) < @min_snippet_length do
    {0, length(lines)}
  end

  defp calculate_file_subset(lines) do
    number_of_lines = Enum.random(@min_snippet_length..14)

    start_line_number = Enum.random(0..abs(length(lines) - 1 - number_of_lines))
    end_line_number = start_line_number + number_of_lines

    {start_line_number, end_line_number}
  end
end
