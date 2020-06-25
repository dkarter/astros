defmodule Astros do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "http://api.open-notify.org")
  plug(Tesla.Middleware.JSON)

  def report do
    case get("/astros.json") do
      {:ok, %Tesla.Env{status: 200, body: %{"message" => "success"} = body}} ->
        output = [summary(body), build_table(body)] |> Enum.join("\n\n")
        IO.puts(output)
        {:ok, output}

      error ->
        IO.inspect(error, label: "failed to fetch data from api")
        {:error, :failed_to_fetch_report}
    end
  end

  defp summary(%{"number" => number}) do
    "There are #{number} people in space right now:"
  end

  defp build_table(%{"people" => people}) do
    person_with_longest_name =
      Enum.max_by(people, fn %{"name" => name} -> String.length(name) end)

    longest_name_length = String.length(person_with_longest_name["name"])

    headers = [String.pad_trailing("Name", longest_name_length), "Craft"]

    [
      headers |> Enum.join(" | "),
      underline(headers),
      build_people_rows(people, longest_name_length)
    ]
    |> Enum.join("\n")
  end

  defp build_people_rows(people, longest_name_length) do
    people
    |> Enum.map(fn %{"name" => name, "craft" => craft} ->
      [String.pad_trailing(name, longest_name_length), craft] |> Enum.join(" | ")
    end)
    |> Enum.join("\n")
  end

  defp underline(headers) do
    headers
    |> Enum.map(fn header -> String.pad_leading("", String.length(header) + 1, "-") end)
    |> Enum.join("|")
  end
end
