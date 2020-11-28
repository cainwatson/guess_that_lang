defmodule GuessThatLangWeb.GameLive do
  use GuessThatLangWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    snippet = "const a = 2;
let b = 2;"
    choices = ["JavaScript", "Python", "Java", "Haskell"]

    {:ok,
     assign(socket,
       snippet: snippet,
       choices: choices,
       correct_answer: "JavaScript",
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
    snippet = "def a(1), do: true"
    choices = ["Ruby", "Elixir", "Clojure", "Python"]

    {:noreply,
     assign(socket,
       snippet: snippet,
       choices: choices,
       correct_answer: "Elixir",
       has_answered: false,
       is_correct: false
     )}
  end
end
