defmodule Admin do
  use GenServer

  # client

  def start do
    GenServer.start_link(__MODULE__, :ok)
  end

  def stop server do
    GenServer.stop(server)
  end

  def broadcast server, message do
    GenServer.cast(server, {:broadcast, message})
  end

  # callbacks

  def init(_args) do

    # connection opening
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)

    # exchanges
#    AMQP.Exchange.declare(channel, "to_admin", :direct)
    AMQP.Exchange.declare(channel, "from_admin", :fanout)
    AMQP.Exchange.declare(channel, "doc_to_tech", :topic)
    AMQP.Exchange.declare(channel, "tech_to_doc", :topic)

    # injury queues
    AMQP.Queue.declare(channel, "knee")
    AMQP.Queue.declare(channel, "elbow")
    AMQP.Queue.declare(channel, "hip")
    AMQP.Queue.declare(channel, "logs")

    # binds
    AMQP.Queue.bind(channel, "knee", "doc_to_tech", routing_key: "knee.#")
    AMQP.Queue.bind(channel, "elbow", "doc_to_tech", routing_key: "elbow.#")
    AMQP.Queue.bind(channel, "hip", "doc_to_tech", routing_key: "hip.#")
    AMQP.Queue.bind(channel, "logs", "doc_to_tech", routing_key: "#.log")
    AMQP.Queue.bind(channel, "logs", "tech_to_doc", routing_key: "#.log")

    # admin work
    {:ok, tag} = AMQP.Basic.consume(channel, "logs", nil, no_ack: true)

    # return value is {:ok, state}
    {:ok, %{connection: connection, channel: channel, consumer_tag: tag}}
  end

  def handle_info({:basic_consume_ok, _msg}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, _meta}, state) do
    IO.puts("-------LOG--ADMIN--#{inspect self()}------- " <> payload)

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_cast({:broadcast, message}, state) do
    AMQP.Basic.publish(state.channel, "from_admin", "", message)
    {:noreply, state}
  end

  def terminate(_reason, state) do
    {:ok, consumer_tag} = AMQP.Basic.cancel(state.channel, state.consumer_tag)
    receive do
      {:basic_cancel_ok, %{consumer_tag: ^consumer_tag}} ->
        {:ok, consumer_tag}
    end
    AMQP.Queue.delete(state.channel, "knee")
    AMQP.Queue.delete(state.channel, "elbow")
    AMQP.Queue.delete(state.channel, "hip")
    AMQP.Queue.delete(state.channel, "logs")

    AMQP.Channel.close(state.channel)
    AMQP.Connection.close(state.connection)
  end
end
