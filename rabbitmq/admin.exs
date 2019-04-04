defmodule Admin do
  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts payload
        wait_for_messages()
    end
  end
end

{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Basic.qos(channel, prefetch_count: 1)
to_admin_ex = "to_admin"
AMQP.Exchange.declare(channel, to_admin_ex, :direct)
AMQP.Queue.declare(channel, "log")
AMQP.Queue.bind(channel, "log", to_admin_ex, routing_key: "log")
AMQP.Basic.consume(channel, "log", nil, no_ack: true)

Admin.wait_for_messages()
