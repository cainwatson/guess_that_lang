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
       has_answered: false,
       is_correct: false
     )}
  end

  @impl true
  def handle_event("answer", %{"choice" => choice}, socket) do
    is_correct = choice == "JavaScript"
    {:noreply, assign(socket, has_answered: true, is_correct: is_correct)}
  end
end
