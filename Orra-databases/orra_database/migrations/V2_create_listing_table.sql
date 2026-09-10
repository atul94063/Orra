CREATE TABLE listings (
    product_id BIGSERIAL PRIMARY KEY,
    owner_id BIGINT,

    product_name VARCHAR(150),
    brand VARCHAR(100),
    model VARCHAR(100),
    serial_or_imei VARCHAR(100) UNIQUE,

    purchase_price NUMERIC(10,2),
    daily_rate NUMERIC(10,2) NOT NULL,
    security_deposit NUMERIC(10,2) NOT NULL,

    health_score INT CHECK (health_score BETWEEN 1 AND 100),

    category VARCHAR(50),
    description VARCHAR(500),
    location VARCHAR(150),

    productspec JSONB,

    purchase_year INT,

    available_from DATE,
    available_to DATE,

    minimum_rental_days INT,
    maximum_rental_days INT,

    is_active BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN DEFAULT TRUE,

    approval_status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);
