package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class StreamRequest {
    private final String title;

    public StreamRequest(String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }
}
