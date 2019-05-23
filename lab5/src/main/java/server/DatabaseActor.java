package server;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import server.message.SearchRequest;
import server.message.SearchResponse;

import java.io.IOException;
import java.io.InputStream;
import java.util.Scanner;

public class DatabaseActor extends AbstractActor {

    private final BookstoreContext context;
    private final String database;

    public DatabaseActor(BookstoreContext context, String database) {
        this.context = context;
        this.database = database;
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(SearchRequest.class, request -> {
                    ActorRef sender = getSender();
                    ActorRef self = getSelf();
                    String title = request.getTitle();
                    context.getExecutionContext().execute(() -> {
                        try (Scanner scanner = new Scanner(getInputStream())) {
                            while(scanner.hasNext()) {
                                String[] line = scanner.nextLine().split(":");
                                String dbTitle = line[0];
                                String dbPrice = line[1];

                                if (dbTitle.equals(title)) {
                                    sender.tell(new SearchResponse(title, true, dbPrice), self);
                                    return;
                                }
                            }
                        }
                        sender.tell(new SearchResponse(title, false, null), self);
                    });
                })
                .build();
    }

    private InputStream getInputStream() {
        return DatabaseActor.class.getClassLoader().getResourceAsStream(database);
    }
}
