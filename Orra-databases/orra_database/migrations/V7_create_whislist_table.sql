CREATE TABLE wishlist (
    wishlist_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    product_id BIGINT,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES listings(product_id)
);
