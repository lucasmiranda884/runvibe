package com.runvibe.repository;

import com.runvibe.entity.ActivityComment;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ActivityCommentRepository extends JpaRepository<ActivityComment, UUID> {
    long countByActivityId(UUID activityId);

    @EntityGraph(attributePaths = "user")
    List<ActivityComment> findByActivityIdOrderByCreatedAtAsc(UUID activityId);
}
