package com.runvibe.repository;

import com.runvibe.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmailIgnoreCase(String email);
    boolean existsByEmailIgnoreCase(String email);
    List<User> findTop20ByIdNotOrderByCreatedAtDesc(UUID currentUserId);

    @Query("""
            select u from User u
            where u.id <> :currentUserId
              and (lower(u.name) like lower(concat('%', :query, '%'))
                   or lower(u.email) like lower(concat('%', :query, '%')))
            order by u.name
            """)
    List<User> search(@Param("query") String query,
                      @Param("currentUserId") UUID currentUserId);
}
