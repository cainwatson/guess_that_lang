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
    %{snippet: snippet, choices: choices, correct_answer: correct_answer} = load_prompt()

    {:ok,
     assign(socket,
       snippet: snippet,
       choices: choices,
       correct_answer: correct_answer,
       has_answered: false,
       is_correct: false
     )}
  end

  @impl true
  def handle_event("answer", %{"choice" => choice}, socket) do
    is_correct = choice == socket.assigns.correct_answer
    {:noreply, assign(socket, has_answered: true, is_correct: is_correct)}
  end

  @impl true
  def handle_event("next", _value, socket) do
    %{snippet: snippet, choices: choices, correct_answer: correct_answer} = load_prompt()

    {:noreply,
     assign(socket,
       snippet: snippet,
       choices: choices,
       correct_answer: correct_answer,
       has_answered: false,
       is_correct: false
     )}
  end

  defp load_prompt do
    choices =
      @languages
      |> Enum.shuffle()
      |> Enum.take(4)

    correct_answer = Enum.random(choices)

    case GuessThatLang.CodeSearcher.search(langauge: correct_answer) do
      {:ok, %{content: snippet}} ->
        %{choices: choices, correct_answer: correct_answer, snippet: snippet}

      _ ->
        %{
          choices: ["javascript", "python", "java", "haskell"],
          correct_answer: "javascript",
          snippet: "const a = 2;
let b = 2;"
        }
    end
  end
end
