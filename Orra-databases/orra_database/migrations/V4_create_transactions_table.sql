CREATE TABLE transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT,

    amount NUMERIC(10,2) NOT NULL,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,

    payment_gateway_ref VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
