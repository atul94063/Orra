CREATE TABLE user_roles (
    user_id BIGINT,
    role VARCHAR(20),

    PRIMARY KEY (user_id, role),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
