defmodule AstrosTest do
  use ExUnit.Case

  import Tesla.Mock, only: [mock: 1, json: 2]

  describe "report/0" do
    test "returns expected output" do
      mock(fn %{method: :get, url: "http://api.open-notify.org/astros.json"} ->
        response = %{
          "message" => "success",
          "number" => 6,
          "people" => [
            %{"craft" => "ISS", "name" => "Oleg Kononenko"},
            %{"craft" => "ISS", "name" => "David Saint-Jacques"},
            %{"craft" => "ISS", "name" => "Anne McClain"},
            %{"craft" => "ISS", "name" => "Alexey Ovchinin"},
            %{"craft" => "ISS", "name" => "Nick Hague"},
            %{"craft" => "ISS", "name" => "Christina Koch"}
          ]
        }

        json(response, status: 200)
      end)

      expected_output =
        """
        There are 6 people in space right now:

        Name                | Craft
        --------------------|------
        Oleg Kononenko      | ISS
        David Saint-Jacques | ISS
        Anne McClain        | ISS
        Alexey Ovchinin     | ISS
        Nick Hague          | ISS
        Christina Koch      | ISS
        """
        |> String.trim()

      assert {:ok, output} = Astros.report()
      assert output == expected_output
    end
  end
end
