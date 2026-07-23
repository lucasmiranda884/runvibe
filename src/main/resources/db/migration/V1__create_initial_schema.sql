CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(320) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    bio VARCHAR(500),
    profile_picture_url VARCHAR(2048),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shoes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(120) NOT NULL,
    max_distance_km NUMERIC(10,2) NOT NULL CHECK (max_distance_km > 0),
    accumulated_distance_km NUMERIC(12,3) NOT NULL DEFAULT 0 CHECK (accumulated_distance_km >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE activities (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shoe_id UUID REFERENCES shoes(id) ON DELETE SET NULL,
    title VARCHAR(160) NOT NULL,
    description VARCHAR(2000),
    total_distance_meters DOUBLE PRECISION NOT NULL CHECK (total_distance_meters >= 0),
    elapsed_time_seconds INTEGER NOT NULL CHECK (elapsed_time_seconds >= 0),
    moving_time_seconds INTEGER NOT NULL CHECK (moving_time_seconds >= 0),
    average_pace_seconds_per_km INTEGER NOT NULL CHECK (average_pace_seconds_per_km >= 0),
    elevation_gain_meters DOUBLE PRECISION NOT NULL CHECK (elevation_gain_meters >= 0),
    route_polyline TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_activity_moving_time CHECK (moving_time_seconds <= elapsed_time_seconds)
);

CREATE SEQUENCE activity_gps_points_seq START WITH 1 INCREMENT BY 500;

CREATE TABLE activity_gps_points (
    id BIGINT PRIMARY KEY DEFAULT nextval('activity_gps_points_seq'),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    elevation DOUBLE PRECISION,
    speed_ms DOUBLE PRECISION CHECK (speed_ms IS NULL OR speed_ms >= 0),
    heart_rate INTEGER CHECK (heart_rate IS NULL OR heart_rate BETWEEN 20 AND 260),
    timestamp TIMESTAMPTZ NOT NULL,
    location geometry(Point, 4326) NOT NULL
);

CREATE TABLE activity_kudos (
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (activity_id, user_id)
);

CREATE TABLE activity_comments (
    id UUID PRIMARY KEY,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_follows (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    followed_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, followed_id),
    CONSTRAINT chk_no_self_follow CHECK (follower_id <> followed_id)
);

CREATE INDEX idx_activities_user_created_at ON activities (user_id, created_at DESC);
CREATE INDEX idx_activities_created_at ON activities (created_at DESC);
CREATE INDEX idx_gps_points_activity_timestamp ON activity_gps_points (activity_id, timestamp);
CREATE INDEX idx_gps_points_location ON activity_gps_points USING GIST (location);
CREATE INDEX idx_shoes_user_active ON shoes (user_id, is_active);
CREATE INDEX idx_kudos_user ON activity_kudos (user_id);
CREATE INDEX idx_comments_activity_created_at ON activity_comments (activity_id, created_at);
CREATE INDEX idx_follows_followed ON user_follows (followed_id, follower_id);
