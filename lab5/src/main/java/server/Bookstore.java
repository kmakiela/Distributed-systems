package server;

import akka.util.Timeout;
import scala.concurrent.duration.Duration;

public class Bookstore {
    public static final int SEARCH_SERVICES = 2;
    public static final long ORDER_SERVICES = 2;
    public static final long STREAMING_SERVICES = 2;

    public static final String DATABASE1 = "database_1.txt";
    public static final String DATABASE2 = "database_2.txt";
    public static final String ORDER_DATABASE = "orders.txt";

    public static final Timeout DATABASE_TIMEOUT = new Timeout(Duration.create(5, "seconds"));
    public static final Timeout SEARCH_TIMEOUT = new Timeout(Duration.create(5, "seconds"));
}
