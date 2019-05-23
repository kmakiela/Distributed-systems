package server;

import akka.actor.AbstractActor;
import akka.actor.OneForOneStrategy;
import akka.actor.SupervisorStrategy;
import akka.japi.pf.DeciderBuilder;
import server.message.Order;
import server.message.SearchRequest;
import server.message.StreamRequest;
import scala.concurrent.duration.Duration;
import static akka.actor.SupervisorStrategy.restart;

public class BookstoreActor extends AbstractActor {

    private static final SupervisorStrategy strategy = new OneForOneStrategy(10,
            Duration.create("1 minute"), DeciderBuilder.matchAny(o -> restart()).build());

    private final BookstoreContext context = new BookstoreContext(getSelf(), getContext());

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(SearchRequest.class, request -> context.getSearchRouter().route(request, getSender()))
                .match(Order.class, request -> context.getOrderRouter().route(request, getSender()))
                .match(StreamRequest.class, request -> context.getStreamRouter().route(request, getSender()))
                .build();
    }

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }
}
