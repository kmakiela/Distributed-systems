package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class Order {

    private final String title;

    public Order(String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }
}
