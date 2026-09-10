CREATE TABLE listing_images (
    image_id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL,

    image_url TEXT NOT NULL,
    is_cover BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    image_data TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (listing_id) REFERENCES listings(product_id)
);
