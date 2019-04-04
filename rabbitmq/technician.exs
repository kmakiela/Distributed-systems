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
    AMQP.Basic.consume(channel, "q_#{injury_type1}", nil, no_ack: true)
    AMQP.Basic.consume(channel, "q_#{injury_type2}", nil, no_ack: true)
  end

  def wait_for_messages channel, tech_to_doc_ex, to_admin_ex do
    receive do
      {:basic_deliver, payload, _meta} ->
        [doc_name|patient_name] = payload |> String.trim() |> String.split()
        IO.puts "Received patient #{patient_name} from doctor #{doc_name}"
        AMQP.Queue.declare(channel, doc_name)
#        :timer.sleep(5000)
        AMQP.Basic.publish(channel, tech_to_doc_ex, doc_name, patient_name)
        AMQP.Basic.publish(channel, to_admin_ex, "log", "Technician got patient #{patient_name} from Doctor #{doc_name}")
        IO.puts "Sent response to doctor #{doc_name}"
        wait_for_messages(channel, tech_to_doc_ex, to_admin_ex)
    end

  end

end
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Basic.qos(channel, prefetch_count: 1)

doc_to_tech_ex = "doc_to_tech"
tech_to_doc_ex = "tech_to_doc"
to_admin_ex = "to_admin"
AMQP.Exchange.declare(channel, to_admin_ex, :direct)
AMQP.Exchange.declare(channel, doc_to_tech_ex, :direct)
injury_type1 = ""
injury_type2 = ""
Technician.register(channel, doc_to_tech_ex)
Technician.wait_for_messages(channel, tech_to_doc_ex, to_admin_ex)
