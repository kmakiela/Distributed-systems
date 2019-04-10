defmodule Technician do
  use GenServer

  # client

  def start injury_type1, injury_type2 do
    GenServer.start_link(__MODULE__, [{:inj1, injury_type1}, {:inj2, injury_type2}])
  end

  def stop server do
    GenServer.stop(server)
  end

  # callbacks

  def init(args) do

    # connection opening
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)

    # technician queue
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "")

    # exchanges
#    AMQP.Exchange.declare(channel, "to_admin", :direct)
    AMQP.Exchange.declare(channel, "from_admin", :fanout)
    AMQP.Exchange.declare(channel, "doc_to_tech", :topic)
    AMQP.Exchange.declare(channel, "tech_to_doc", :topic)

    # injury queues
    AMQP.Queue.declare(channel, args[:inj1])
    AMQP.Queue.declare(channel, args[:inj2])
    AMQP.Queue.declare(channel, "logs")

    # binds
    AMQP.Queue.bind(channel, args[:inj1], "doc_to_tech", routing_key: "#{args[:inj1]}.#")
    AMQP.Queue.bind(channel, args[:inj2], "doc_to_tech", routing_key: "#{args[:inj2]}.#")
    AMQP.Queue.bind(channel, "logs", "doc_to_tech", routing_key: "#.log")
    AMQP.Queue.bind(channel, queue_name, "from_admin")
    # technician work
    {:ok, tag1} = AMQP.Basic.consume(channel, args[:inj1], nil, no_ack: true)
    {:ok, tag2} = AMQP.Basic.consume(channel, args[:inj2], nil, no_ack: true)
    {:ok, tag3} = AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

    # return value is {:ok, state}
    {:ok, %{connection: connection, channel: channel, consumer_tag: [tag1, tag2, tag3]}}
  end

  def handle_info({:basic_consume_ok, _msg}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta}, state) do
    IO.puts("Technician #{inspect self()} received message: " <> payload)
    reply_key = "#{meta.reply_to}.log"
    :timer.sleep(5000)
    AMQP.Basic.publish(state.channel, "tech_to_doc", reply_key, "#{payload} done")
    {:noreply, state}
  end

  def terminate(_reason, state) do
    Enum.map(state.consumer_tag, fn x ->
      {:ok, consumer_tag} = AMQP.Basic.cancel(state.channel, x)
      receive do
        {:basic_cancel_ok, %{consumer_tag: ^consumer_tag}} ->
          {:ok, consumer_tag}
      end
    end)

    AMQP.Channel.close(state.channel)
    AMQP.Connection.close(state.connection)
  end
end
