defmodule Doctor do
  def accept_patient channel, doc_to_tech_ex, doc_name do
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
        accept_patient(channel, doc_to_tech_ex, doc_name)
    end
    name = IO.gets("Type in: patient's name\n") |> String.trim()
    AMQP.Basic.publish(channel, doc_to_tech_ex, injury_type, "#{doc_name} #{name}")
    IO.puts("Sent message about #{name} with #{injury_type} injury")
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts "#{payload}'s examination was done"
    end
    accept_patient(channel, doc_to_tech_ex, doc_name)
  end
end

{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Basic.qos(channel, prefetch_count: 1)
doc_to_tech_ex = "doc_to_tech"
tech_to_doc_ex = "tech_to_doc"
AMQP.Exchange.declare(channel, doc_to_tech_ex, :direct)
AMQP.Exchange.declare(channel, tech_to_doc_ex, :direct)

AMQP.Queue.declare(channel, "q_knee")
AMQP.Queue.bind(channel, "q_knee", doc_to_tech_ex, routing_key: "knee")

AMQP.Queue.declare(channel, "q_elbow")
AMQP.Queue.bind(channel, "q_elbow", doc_to_tech_ex, routing_key: "elbow")

AMQP.Queue.declare(channel, "q_hip")
AMQP.Queue.bind(channel, "q_hip", doc_to_tech_ex, routing_key: "hip")

doc_name = IO.gets("Type in: name of the doctor\n") |> String.trim()
AMQP.Queue.declare(channel, doc_name)
AMQP.Queue.bind(channel, doc_name, tech_to_doc_ex, routing_key: doc_name)
AMQP.Basic.consume(channel, doc_name, nil, no_ack: true)

Doctor.accept_patient(channel, doc_to_tech_ex, doc_name)
