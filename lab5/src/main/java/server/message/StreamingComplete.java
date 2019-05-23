package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class StreamingComplete {
    private final boolean success;

    public StreamingComplete(boolean success) {
        this.success = success;
    }

    public boolean isSuccess() {
        return success;
    }
}
