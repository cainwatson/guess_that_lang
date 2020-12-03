defmodule GuessThatLang.CodeSearcher.Github do
  @topics [
    "app",
    "arduino"
  ]

  def search(opts) do
    language = Keyword.fetch!(opts, :language)

    with {:ok, codes} <- fetch_code(language: language),
         {:ok, content_base64} <- Enum.random(codes) |> fetch_content(),
         {:ok, content_raw} <- Base.decode64(content_base64, ignore: :whitespace) do
      {:ok, %{content: content_raw, language: language}}
    end
  end

  defp config, do: Application.get_env(:guess_that_lang, __MODULE__)

  defp client do
    access_token = Keyword.fetch!(config(), :access_token)
    Tentacat.Client.new(%{access_token: access_token})
  end

  defp fetch_code(opts) do
    batch_size = Keyword.fetch!(config(), :batch_size)
    language = Keyword.fetch!(opts, :language)
    query = Enum.random(@topics)

    params = %{
      q: "#{query} language:#{language}",
      per_page: batch_size
    }

    with {200, %{"items" => codes}, _response} <-
           Tentacat.Search.code(client(), params, pagination: :none),
         do: {:ok, codes}
  end

  defp fetch_content(%{} = code) do
    owner = code["repository"]["owner"]["login"]
    repo = code["repository"]["name"]
    path = code["path"]

    with {200, %{"encoding" => "base64", "content" => content_base64}, _response} <-
           Tentacat.Contents.find(client(), owner, repo, path),
         do: {:ok, content_base64}
  end
end
