defmodule GuessThatLang.CodeSearcher.Github do
  @behaviour GuessThatLang.CodeSearcher

  require Logger

  @topics [
    "app",
    "arduino"
  ]

  @impl true
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

  defp check_rate_limit(%HTTPoison.Response{headers: headers} = response) do
    {_, limit} = List.keyfind(headers, "X-RateLimit-Limit", 0)
    {_, remaining} = List.keyfind(headers, "X-RateLimit-Remaining", 0)
    {_, reset} = List.keyfind(headers, "X-RateLimit-Reset", 0)

    {limit, _} = Integer.parse(limit)
    {remaining, _} = Integer.parse(remaining)
    {reset, _} = Integer.parse(reset)
    reset = DateTime.from_unix!(reset)

    half_limit = Integer.floor_div(limit, 2)
    three_quarters_limit = Integer.floor_div(limit, 3)

    cond do
      remaining == 0 ->
        Logger.error("Github rate limit reached! #{remaining}/#{limit} used. Resets at #{reset}")
        {:error, {:rate_limit_reached, response}}

      remaining in [half_limit, three_quarters_limit, 1] ->
        Logger.warn(
          "Github rate limit status: #{remaining}/#{limit} remaining. Resets at #{reset}"
        )

        :ok

      true ->
        :ok
    end
  end

  defp fetch_code(opts) do
    batch_size = Keyword.fetch!(config(), :batch_size)
    language = Keyword.fetch!(opts, :language)
    query = Enum.random(@topics)

    params = %{
      q: "#{query} language:\"#{language}\"",
      per_page: batch_size
    }

    with {200, %{"items" => codes}, response} <-
           Tentacat.Search.code(client(), params, pagination: :none),
         :ok <- check_rate_limit(response) do
      {:ok, codes}
    end
  end

  defp fetch_content(%{} = code) do
    owner = code["repository"]["owner"]["login"]
    repo = code["repository"]["name"]
    path = code["path"]

    with {200, %{"encoding" => "base64", "content" => content_base64}, response} <-
           Tentacat.Contents.find(client(), owner, repo, path),
         :ok <- check_rate_limit(response) do
      {:ok, content_base64}
    end
  end
end
