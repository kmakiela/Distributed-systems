package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class StreamingPart {
    private final String line;

    public StreamingPart(String line) {
        this.line = line;
    }

    public String getLine() {
        return line;
    }
}
