package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class OrderComplete {

    private final boolean success;

    public OrderComplete(boolean success) {
        this.success = success;
    }

    public boolean isSuccess() {
        return success;
    }

}
