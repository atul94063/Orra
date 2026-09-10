CREATE TABLE bookings (
    booking_id BIGSERIAL PRIMARY KEY,

    listing_id BIGINT,
    renter_id BIGINT,

    start_datetime DATE NOT NULL,
    end_datetime DATE NOT NULL,

    total_price NUMERIC(10,2),
    deposit_amount NUMERIC(10,2),

    status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    paid_at TIMESTAMP,
    shipped_at TIMESTAMP,
    completed_at TIMESTAMP,

    FOREIGN KEY (listing_id) REFERENCES listings(product_id),
    FOREIGN KEY (renter_id) REFERENCES users(user_id)
);
