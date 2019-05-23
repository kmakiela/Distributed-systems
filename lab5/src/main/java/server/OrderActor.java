package server;

import akka.actor.AbstractActor;
import akka.pattern.Patterns;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import server.message.Order;
import server.message.OrderComplete;
import server.message.OrderResponse;
import server.message.SearchRequest;
import server.message.SearchResponse;
import scala.concurrent.Await;
import scala.concurrent.Future;


public class OrderActor extends AbstractActor {

    private final Logger logger = LoggerFactory.getLogger(getSelf().toString());
    private final BookstoreContext context;

    public OrderActor(BookstoreContext context) {
        this.context = context;
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(Order.class, order -> {
                    logger.info("Got ORDER request");
                    Future<Object> future = Patterns.ask(context.getBookstore(), new SearchRequest(order.getTitle()), Bookstore.SEARCH_TIMEOUT);
                    SearchResponse searchResponse = (SearchResponse) Await.result(future, Bookstore.SEARCH_TIMEOUT.duration());

                    if (!searchResponse.isExists()) {
                        tellOrderFailed(order);
                        return;
                    }

                    Future<Object> future2 = Patterns.ask(context.getOrdersActor(), order, Bookstore.DATABASE_TIMEOUT);
                    OrderComplete orderComplete = (OrderComplete) Await.result(future2, Bookstore.DATABASE_TIMEOUT.duration());

                    if (orderComplete.isSuccess()) {
                        getSender().tell(new OrderResponse(order.getTitle(), true, searchResponse.getPrice()), getSelf());
                    } else {
                        tellOrderFailed(order);
                    }
                })
                .build();
    }

    private void tellOrderFailed(Order order) {
        getSender().tell(new OrderResponse(order.getTitle(), false, null), getSelf());
    }
}
