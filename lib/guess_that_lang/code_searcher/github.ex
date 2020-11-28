defmodule GuessThatLang.CodeSearcher.Github do
  @topics [
    "app",
    "arduino"
  ]

  def search(opts) do
    query = Enum.random(@topics)
    language = Keyword.fetch!(opts, :langauge)

    {200, %{"items" => items}, _response} =
      Tentacat.Search.code(
        client(),
        %{
          q: "#{query} language:#{language}",
          per_page: 1
        },
        pagination: :none
      )

    item = Enum.random(items)
    owner = item["repository"]["owner"]["login"]
    repo = item["repository"]["name"]
    path = item["path"]

    {200, %{"encoding" => "base64", "content" => content_base64}, _response} =
      Tentacat.Contents.find(client(), owner, repo, path)

    {:ok, content_raw} = Base.decode64(content_base64, ignore: :whitespace)

    lines = String.split(content_raw, "\n")
    start_line_number = 0
    end_line_number = 10

    content_raw_subset =
      lines
      |> Enum.slice(start_line_number..end_line_number)
      |> Enum.join("\n")

    {:ok,
     %{
       content: content_raw_subset,
       language: language,
       repository_full_name: item["repository"]["full_name"],
       file_name: item["name"],
       file_path: item["path"],
       file_url: item["html_url"]
     }}
  end

  defp client do
    config = Application.get_env(:guess_that_lang, __MODULE__)
    access_token = Keyword.fetch!(config, :github_access_token)
    Tentacat.Client.new(%{access_token: access_token})
  end
end
