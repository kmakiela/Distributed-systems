package server;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.pattern.Patterns;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import server.message.SearchRequest;
import server.message.SearchResponse;
import scala.concurrent.ExecutionContext;
import scala.concurrent.Future;
import scala.util.Try;

public class SearchActor extends AbstractActor {

    private final Logger logger = LoggerFactory.getLogger(getSelf().toString());
    private final BookstoreContext context;

    public SearchActor(BookstoreContext context) {
        this.context = context;
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(SearchRequest.class, request -> {
                    logger.info("Got SEARCH request");
                    ExecutionContext executionContext = context.getExecutionContext();
                    Future<SearchResponse> result1Future = Patterns.ask(context.getDatabase1Actor(), request, Bookstore.DATABASE_TIMEOUT)
                            .map(r -> (SearchResponse) r, executionContext);
                    Future<SearchResponse> result2Future = Patterns.ask(context.getDatabase2Actor(), request, Bookstore.DATABASE_TIMEOUT)
                            .map(r -> (SearchResponse) r, executionContext);

                    ActorRef sender = getSender();
                    result1Future.onComplete(result1 -> handleResult(request, result1, result2Future, sender), executionContext);
                })
                .build();
    }

    private Void handleResult(SearchRequest request, Try<SearchResponse> result, Future<SearchResponse> fallback, ActorRef sender) {
        if (result.isSuccess() && result.get().isExists()) {
            sender.tell(result.get(), getSelf());
        } else if (fallback != null) {
            fallback.onComplete(result2 -> handleResult(request, result2, null, sender), context.getExecutionContext());
        } else {
            sender.tell(new SearchResponse(request.getTitle(), false, null), getSelf());
        }

        return null;
    }
}
