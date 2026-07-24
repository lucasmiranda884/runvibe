ALTER TABLE activities
    ADD COLUMN sport_type VARCHAR(32) NOT NULL DEFAULT 'RUNNING';

ALTER TABLE activities
    ADD CONSTRAINT chk_activity_sport_type
    CHECK (sport_type IN ('RUNNING', 'CYCLING', 'WALKING', 'HIKING'));

CREATE INDEX idx_activities_user_sport_created
    ON activities (user_id, sport_type, created_at DESC);
