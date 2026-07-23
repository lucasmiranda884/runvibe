package com.runvibe.repository;

import com.runvibe.entity.Activity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ActivityRepository extends JpaRepository<Activity, UUID> {

    @EntityGraph(attributePaths = {"user", "shoe"})
    @Query("select a from Activity a where a.id = :id")
    Optional<Activity> findDetailsById(@Param("id") UUID id);

    @EntityGraph(attributePaths = {"user", "shoe"})
    @Query("""
            select a from Activity a
            where a.user.id = :viewerId
               or a.user.id in (
                   select f.followed.id from UserFollow f where f.follower.id = :viewerId
               )
            """)
    Page<Activity> findFeed(@Param("viewerId") UUID viewerId, Pageable pageable);
}
