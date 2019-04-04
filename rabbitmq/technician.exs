defmodule Technician do
  def register channel, doc_to_tech_ex do
    [injury_type1|[injury_type2]] = IO.gets("Type in: injury_type1 injury_type2\n") |> String.trim() |> String.split()
    case injury_type1 do
      "knee" ->
        :ok
      "elbow" ->
        :ok
      "hip" ->
        :ok
      _->
        IO.puts "Injury1 type can only be knee, elbow or hip"
        register channel, doc_to_tech_ex
    end
    case injury_type2 do
      "knee" ->
        :ok
      "elbow" ->
        :ok
      "hip" ->
        :ok
      _->
        IO.puts "Injury2 type can only be knee, elbow or hip"
        register channel, doc_to_tech_ex
    end
    AMQP.Queue.declare(channel, "q_#{injury_type1}")
    AMQP.Queue.declare(channel, "q_#{injury_type2}")
    AMQP.Basic.consume(channel, "q_#{injury_type1}", nil)
    AMQP.Basic.consume(channel, "q_#{injury_type2}", nil)


  end

  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts "Received patient #{payload}"
        wait_for_messages()
    end

  end

end
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
doc_to_tech_ex = "doc_to_tech"
AMQP.Exchange.declare(channel, doc_to_tech_ex, :direct)

Technician.register(channel, doc_to_tech_ex)
Technician.wait_for_messages()
