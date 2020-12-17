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
  @show_more_lines Application.get_env(:guess_that_lang, :show_more_lines)

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
          file_lines: nil,
          snippet: %{
            content: nil,
            start_line_number: nil,
            end_line_number: nil
          }
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

  @impl true
  def handle_event("show_more", %{"direction" => "above"}, socket) do
    %{snippet: snippet, file_lines: file_lines} = socket.assigns
    start_line_number = Enum.max([0, snippet.start_line_number - @show_more_lines])
    end_line_number = snippet.end_line_number

    {:noreply,
     assign(socket, :snippet, %{
       start_line_number: start_line_number,
       end_line_number: end_line_number,
       content: file_subset(file_lines, start_line_number..end_line_number)
     })}
  end

  @impl true
  def handle_event("show_more", %{"direction" => "below"}, socket) do
    %{snippet: snippet, file_lines: file_lines} = socket.assigns
    start_line_number = snippet.start_line_number
    end_line_number = Enum.min([length(file_lines), snippet.end_line_number + @show_more_lines])

    {:noreply,
     assign(socket, :snippet, %{
       start_line_number: start_line_number,
       end_line_number: end_line_number,
       content: file_subset(file_lines, start_line_number..end_line_number)
     })}
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
      snippet = file_subset(lines, start_line_number..end_line_number)

      assign(socket,
        is_correct: false,
        has_answered: false,
        choices: choices,
        correct_answer: correct_answer,
        file_lines: lines,
        snippet: %{
          content: snippet,
          start_line_number: start_line_number,
          end_line_number: end_line_number
        }
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

  defp file_subset(lines, range) do
    lines
    |> Enum.slice(range)
    |> Enum.join("\n")
  end
end
