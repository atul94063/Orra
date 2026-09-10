
-- Index of Table does not start with 0 So run the TRUNCATE command first   
-- RESTART IDENTITY COMMAND RESETS PostgreSQL index count to Zero 
-- Execute commands in this order only 

TRUNCATE TABLE wishlist RESTART IDENTITY CASCADE;
TRUNCATE TABLE notifications RESTART IDENTITY CASCADE;
TRUNCATE TABLE listing_images RESTART IDENTITY CASCADE;
TRUNCATE TABLE reviews RESTART IDENTITY CASCADE;
TRUNCATE TABLE transactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE bookings RESTART IDENTITY CASCADE;
TRUNCATE TABLE listings RESTART IDENTITY CASCADE;
TRUNCATE TABLE users RESTART IDENTITY CASCADE;


-- Safe Reset of Tables 

DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS listing CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS listing_images CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS wishlist CASCADE;

DROP TYPE IF EXISTS user_role_enum;
DROP TYPE IF EXISTS id_proof_enum;
DROP TYPE IF EXISTS booking_status_enum;
DROP TYPE IF EXISTS transaction_type_enum;
DROP TYPE IF EXISTS transaction_status_enum;


-- V0 ENUM CREATION 

CREATE TYPE app_user_role_enum AS ENUM (
    'BUYER',
    'OWNER',
    'ADMIN'
);

CREATE TYPE id_proof_enum AS ENUM(
    'PAN',
    'AADHAAR',
    'BOTH',
    'NONE'
);

CREATE TYPE booking_status-enum AS ENUM(
    'PENDING',
    'ACCEPTED',
    'REJECTED',
    'PAID',
    'SHIPPED',
    'COMPLETED',
    'REFUNDED',
    'CANCELLED'
);

CREATE TYPE transaction_type_enum AS ENUM(
    'RENTAL PAYMENT',
    'DEPOSIT HOLD',
    'DEPOSIT REFUND',
    'REFUND'
);

CREATE TYPE transaction_status_enum AS ENUM(
    'PENDING',
    'SUCCESS',
    'FAILED'
);

CREATE TYPE category_enum AS ENUM (
    'LAPTOP',
    'CAMERA',
    'GAMING_CONSOLES',
    'DRONES',
    'MOBILE',
    'SMART_WATCHES',
    'AUDIO_DEVICES',
    'MONITORS',
    'VR_AR',
    'LENSES',
    'LIGHTING',
    'ACTION_CAMERAS',
    'PROJECTORS',
    'MICROPHONES',
    'TABLETS',
    'ACCESSORIES',
    'REFRIGERATOR',
    'TV'
);


-- V1 USER TABLE CREATION 

CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,

    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),

    username VARCHAR(100),
    profile_pic VARCHAR(255),
    avatar VARCHAR(255),
    address VARCHAR(255),

    pan_number VARCHAR(20),
    aadhaar_number VARCHAR(20),
    id_proof VARCHAR(20),

    supabase_id UUID UNIQUE,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_verified BOOLEAN DEFAULT FALSE,
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    subscribed BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V2 LISTING TABLE CREATION

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

    location VARCHAR(150),
    description VARCHAR(500),
    category VARCHAR(50),
    productspec JSONB,

    purchase_year INT,
    days INT,

    available_from DATE,
    available_to DATE,
    minimum_rental_days INT,
    maximum_rental_days INT,

    is_active BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

-- V3 BOOKING TABLE CREATION

CREATE TABLE bookings (
    booking_id BIGSERIAL PRIMARY KEY,

    listing_id BIGINT,
    renter_id BIGINT,

    start_datetime DATE NOT NULL,
    end_datetime DATE NOT NULL,

    total_price NUMERIC(10,2),
    deposit_amount NUMERIC(10,2),

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    FOREIGN KEY (listing_id) REFERENCES listings(product_id),
    FOREIGN KEY (renter_id) REFERENCES users(user_id)
);

-- V4 TRANSACTION TABLE CREATION

CREATE TABLE transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT,

    amount NUMERIC(10,2) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,

    payment_gateway_ref VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);


-- V5 LISTING IMAGE TABLE CREATION

CREATE TABLE listing_images (
    image_id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL,

    image_url TEXT NOT NULL,
    image_data TEXT,

    is_cover BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INT NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (listing_id) REFERENCES listings(product_id)
);
-- V6 NOTIFICATION TABLE CREATION

CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL,
    booking_id BIGINT,

    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
--V7 WHISLIST TABLE CREATION

CREATE TABLE wishlist (
    wishlist_id BIGSERIAL PRIMARY KEY,

    user_id BIGINT,
    product_id BIGINT,

    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES listings(product_id)
);


--V8 USER ROLE CREATION

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,

    PRIMARY KEY (user_id, role),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
