package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class SearchRequest {
    private final String title;

    public SearchRequest(String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }
}
