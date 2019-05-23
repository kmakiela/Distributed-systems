import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import server.message.OrderResponse;
import server.message.SearchResponse;
import server.message.StreamingComplete;
import server.message.StreamingPart;

public class BookstoreClientActor extends AbstractActor {

    private static final Logger logger = LoggerFactory.getLogger(BookstoreClientActor.class);

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(OrderResponse.class, response -> logger.info("ORDER response: " + response))
                .match(SearchResponse.class, response -> logger.info("SEARCH response: " + response))
                .match(StreamingPart.class, part -> logger.info("STREAM loading: " + part))
                .match(StreamingComplete.class, complete -> logger.info("STREAM complete: " + complete))
                .match(Object.class, obj -> logger.info("Unknown: " + obj))
                .build();
    }
}
