package server.message;

import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@ToString
@EqualsAndHashCode
public class SearchResponse {
    private final String title;
    private final boolean exists;
    private final String price;


    public SearchResponse(String title, boolean exists, String price) {
        this.title = title;
        this.exists = exists;
        this.price = price;
    }

    public String getTitle() {
        return title;
    }

    public boolean isExists() {
        return exists;
    }

    public String getPrice() {
        return price;
    }
}
