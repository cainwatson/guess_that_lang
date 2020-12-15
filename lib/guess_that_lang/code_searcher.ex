defmodule GuessThatLang.CodeSearcher do
  @callback search(opts :: keyword()) ::
              {:ok, %{content: binary(), language: binary()}} | {:error, term()}

  def search(opts) do
    config = Application.get_env(:guess_that_lang, __MODULE__)
    searcher = Keyword.fetch!(config, :searcher)

    searcher.search(opts)
  end
end
