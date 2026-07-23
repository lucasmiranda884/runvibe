package com.runvibe.repository;

import com.runvibe.entity.ActivityComment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ActivityCommentRepository extends JpaRepository<ActivityComment, UUID> {
    long countByActivityId(UUID activityId);
}
