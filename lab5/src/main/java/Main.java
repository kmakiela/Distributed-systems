import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import server.BookstoreActor;
import server.message.Order;
import server.message.SearchRequest;
import server.message.StreamRequest;

import java.util.Scanner;

public class Main {
    private static final Logger logger = LoggerFactory.getLogger(Main.class);

    public static void main(String[] args) {
        ActorSystem system = ActorSystem.create("bookstore_system");
        ActorRef serverActor = system.actorOf(Props.create(BookstoreActor.class), "server");
        ActorRef clientActor = system.actorOf(Props.create(BookstoreClientActor.class), "client");

        runClient(serverActor, clientActor);
    }

    private static void runClient(ActorRef bookstore, ActorRef client) {
        logger.info("Available commands are: search, order and stream");

        Scanner s = new Scanner(System.in);
        while (true) {
            String line = s.nextLine();
            String[] args = line.split("\\s+");
            if (args.length != 2) {
                logger.error("Invalid args");
                continue;
            }

            switch (args[0]) {
                case "search":
                    requestSearch(bookstore, client, args[1]);
                    break;
                case "order":
                    requestOrder(bookstore, client, args[1]);
                    break;
                case "stream":
                    requestStreaming(bookstore, client, args[1]);
                    break;
                default:
                    logger.error("Unknown command: " + args[0]);
                    break;
            }
        }
    }

    private static void requestOrder(ActorRef bookstore, ActorRef client, String title) {
        Order order = new Order(title);
        logger.info("Requesting ORDER: " + order);
        bookstore.tell(order, client);
    }

    private static void requestSearch(ActorRef bookstore, ActorRef client, String title) {
        SearchRequest request = new SearchRequest(title);
        logger.info("Requesting SEARCH: " + request);
        bookstore.tell(request, client);
    }

    private static void requestStreaming(ActorRef bookstore, ActorRef client, String title) {
        StreamRequest request = new StreamRequest(title);
        logger.info("Requesting STREAM: " + request);
        bookstore.tell(request, client);
    }
}
