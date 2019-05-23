package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class OrderResponse {
    private final String title;
    private final boolean success;
    private final String price;

    public OrderResponse(String title, boolean success, String price) {
        this.title = title;
        this.success = success;
        this.price = price;
    }

    public String getTitle() {
        return title;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getPrice() {
        return price;
    }
}
