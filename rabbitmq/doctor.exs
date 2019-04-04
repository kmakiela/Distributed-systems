defmodule Doctor do
  def accept_patient channel, doc_to_tech_ex do
    injury_type = IO.gets("Type in: injury type\n") |> String.trim()
    case injury_type do
      "knee" ->
        :ok
      "elbow" ->
        :ok
      "hip" ->
        :ok
      _->
        IO.puts("Injury type can only be knee, elbow or hip")
        accept_patient(channel, doc_to_tech_ex)
    end
    name = IO.gets("Type in: name\n") |> String.trim()
    AMQP.Basic.publish(channel, doc_to_tech_ex, injury_type, name)
    IO.puts("Sent message about #{name} with #{injury_type} injury")
    accept_patient(channel, doc_to_tech_ex)
  end
end

{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
doc_to_tech_ex = "doc_to_tech"
AMQP.Exchange.declare(channel, doc_to_tech_ex, :direct)

AMQP.Queue.declare(channel, "q_knee")
AMQP.Queue.bind(channel, "q_knee", doc_to_tech_ex, routing_key: "knee")

AMQP.Queue.declare(channel, "q_elbow")
AMQP.Queue.bind(channel, "q_elbow", doc_to_tech_ex, routing_key: "elbow")

AMQP.Queue.declare(channel, "q_hip")
AMQP.Queue.bind(channel, "q_hip", doc_to_tech_ex, routing_key: "hip")


Doctor.accept_patient(channel, doc_to_tech_ex)
