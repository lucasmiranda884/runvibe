package com.runvibe.repository;

import com.runvibe.entity.UserFollow;
import com.runvibe.entity.UserFollowId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserFollowRepository extends JpaRepository<UserFollow, UserFollowId> {
}
