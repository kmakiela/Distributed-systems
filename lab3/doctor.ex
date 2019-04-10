defmodule Doctor do
  use GenServer

  # client

  def start do
    GenServer.start_link(__MODULE__, :ok)
  end

  def stop server do
    GenServer.stop(server)
  end

  def request_examination server, injury_type, patient_name do
    GenServer.cast(server, {:examination, injury_type, patient_name})
  end

  # callbacks

  def init(_args) do

    # connection opening
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.qos(channel, prefetch_count: 1)

    # doc queue
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "")
    {:ok, tag} = AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

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
    AMQP.Queue.bind(channel, queue_name, "from_admin")
    AMQP.Queue.bind(channel, queue_name, "tech_to_doc", routing_key: queue_name <> ".#")

    # return value is {:ok, state}
    {:ok, %{connection: connection, channel: channel, queue: queue_name, consumer_tag: tag}}
  end

  def handle_info({:basic_consume_ok, _msg}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, _meta}, state) do
    IO.puts("Doctor #{inspect self()} received message: " <> payload)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_cast({:examination, injury_type, patient_name}, state) do
    message = "#{injury_type} #{patient_name}"
    AMQP.Basic.publish(state.channel, "doc_to_tech", "#{injury_type}.log", message, reply_to: state.queue)
    IO.puts("Doctor #{inspect self()} sent message about #{patient_name} with #{injury_type} injury")
    {:noreply, state}
  end

  def terminate(_reason, state) do
    {:ok, consumer_tag} = AMQP.Basic.cancel(state.channel, state.consumer_tag)
    receive do
      {:basic_cancel_ok, %{consumer_tag: ^consumer_tag}} ->
        {:ok, consumer_tag}
    end
    AMQP.Queue.delete(state.channel, state.queue)
    AMQP.Channel.close(state.channel)
    AMQP.Connection.close(state.connection)
  end
end
