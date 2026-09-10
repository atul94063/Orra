CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15),
    username VARCHAR(100),
    address VARCHAR(255),
    profile_pic VARCHAR(255),
    pan_number VARCHAR(20),
    aadhaar_number VARCHAR(20),
    supabase_id UUID UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    verified BOOLEAN DEFAULT FALSE,
    subscribed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
