package com.runvibe.repository;

import com.runvibe.entity.Shoe;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ShoeRepository extends JpaRepository<Shoe, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select s from Shoe s where s.id = :shoeId and s.user.id = :userId")
    Optional<Shoe> findOwnedByIdForUpdate(@Param("shoeId") UUID shoeId,
                                          @Param("userId") UUID userId);
}
