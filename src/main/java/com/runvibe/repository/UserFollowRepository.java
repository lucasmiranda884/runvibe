package com.runvibe.repository;

import com.runvibe.entity.UserFollow;
import com.runvibe.entity.UserFollowId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface UserFollowRepository extends JpaRepository<UserFollow, UserFollowId> {
    @Query("select count(f) from UserFollow f where f.follower.id = :userId")
    long countFollowing(@Param("userId") UUID userId);

    @Query("select count(f) from UserFollow f where f.followed.id = :userId")
    long countFollowers(@Param("userId") UUID userId);
}
