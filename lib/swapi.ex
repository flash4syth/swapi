defmodule Swapi do
  def main(_) do
    HTTPoison.start()

    ship_id = 0

    loop(
     call_get(ship_id),
     ship_id,
     _output = %{},
     _failed_count = 0
     )
    # |> Jason.decode!()
    # |> IO.inspect()
  end

  @doc """
  Loop over results until we are fairly certain no more results will
  be forthcoming, then output the collected data.  These are the following states and
  desired actions given the state:
  1. Not Found 50 times consecutively => Return output
  2. Empty pilot list => skip
  3. One or more pilots in the pilot list => collect data
  4. Not Found but less than 50th instance => skip
  """
  def loop(%HTTPoison.Response{body: "{\"detail\":\"Not found\"}"}, _ship_id, output, failed_count) when failed_count == 49 do
    IO.inspect(output)
  end

  def loop(%HTTPoison.Response{body: "{\"detail\":\"Not found\"}"}, ship_id, output, failed_count) do
    ship_id = ship_id + 1
    failed_count = failed_count + 1

    loop(
    call_get(ship_id),
    ship_id,
    output,
    failed_count
    )
  end

  def loop(%HTTPoison.Response{body: body}, ship_id, output, _failed_count) do
    case Jason.decode!(body) do
      %{"pilots" => []} ->
        ship_id = ship_id + 1

        loop(
          call_get(ship_id),
          ship_id,
          output,
          _failed_count = 0
        )

      %{"pilots" => pilots, "name" => ship_name} ->
        output = Map.put(output, ship_name, pilots)

        ship_id = ship_id + 1

        loop(
        call_get(ship_id),
        ship_id,
        output,
        _failed_count = 0
        )
        end

  end

  defp call_get(ship_id), do: HTTPoison.get!("https://swapi.dev/api/starships/#{ship_id}/")
end
