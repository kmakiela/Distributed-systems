package server;

import akka.actor.ActorContext;
import akka.actor.ActorRef;
import akka.actor.Props;
import akka.routing.ActorRefRoutee;
import akka.routing.RoundRobinRoutingLogic;
import akka.routing.Routee;
import akka.routing.Router;
import scala.concurrent.ExecutionContext;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class BookstoreContext {

    private final ExecutionContext executionContext = ExecutionContext.fromExecutor(Executors.newCachedThreadPool());
    private final ActorRef bookstore;
    private final Router searchRouter;
    private final Router orderRouter;
    private final Router streamRouter;
    private final ActorRef database1Actor;
    private final ActorRef database2Actor;
    private final ActorRef ordersActor;

    public BookstoreContext(ActorRef bookstore, ActorContext context) {
        this.bookstore = bookstore;

        List<Routee> searchServants = Stream.generate(() -> createSearchActor(context))
                .limit(Bookstore.SEARCH_SERVICES)
                .map(ActorRefRoutee::new)
                .collect(Collectors.toList());
        this.searchRouter = new Router(new RoundRobinRoutingLogic(), searchServants);

        List<Routee> orderServants = Stream.generate(() -> createOrderActor(context))
                .limit(Bookstore.ORDER_SERVICES)
                .map(ActorRefRoutee::new)
                .collect(Collectors.toList());
        this.orderRouter = new Router(new RoundRobinRoutingLogic(), orderServants);

        List<Routee> streamServants = Stream.generate(() -> createStreamActor(context))
                .limit(Bookstore.STREAMING_SERVICES)
                .map(ActorRefRoutee::new)
                .collect(Collectors.toList());
        this.streamRouter = new Router(new RoundRobinRoutingLogic(), streamServants);

        this.database1Actor = createDatabaseActor(context, Bookstore.DATABASE1);
        this.database2Actor = createDatabaseActor(context, Bookstore.DATABASE2);
        this.ordersActor = createOrderDatabaseActor(context);
    }

    private ActorRef createStreamActor(ActorContext context) {
        return context.actorOf(Props.create(StreamingActor.class, this), "stream_actor_" + UUID.randomUUID());
    }

    private ActorRef createOrderActor(ActorContext context) {
        return context.actorOf(Props.create(OrderActor.class, this), "order_actor_" + UUID.randomUUID());
    }

    private ActorRef createSearchActor(ActorContext context) {
        return context.actorOf(Props.create(SearchActor.class, this), "search_actor_" + UUID.randomUUID());
    }

    private ActorRef createDatabaseActor(ActorContext context, String database) {
        return context.actorOf(Props.create(DatabaseActor.class, this, database), "db_actor_" + UUID.randomUUID());
    }

    private ActorRef createOrderDatabaseActor(ActorContext context) {
        return context.actorOf(Props.create(OrderDatabaseActor.class, this, Bookstore.ORDER_DATABASE), "order_db_acotr");
    }

    public Router getSearchRouter() {
        return searchRouter;
    }

    public ActorRef getDatabase1Actor() {
        return database1Actor;
    }

    public ActorRef getDatabase2Actor() {
        return database2Actor;
    }

    public ExecutionContext getExecutionContext() {
        return executionContext;
    }

    public Router getOrderRouter() {
        return orderRouter;
    }

    public ActorRef getOrdersActor() {
        return ordersActor;
    }

    public ActorRef getBookstore() {
        return bookstore;
    }

    public Router getStreamRouter() {
        return streamRouter;
    }
}
