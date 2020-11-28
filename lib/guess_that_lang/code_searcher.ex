defmodule GuessThatLang.CodeSearcher do
  def search(opts) do
    GuessThatLang.CodeSearcher.Github.search(opts)
  end
end
