package com.runvibe.service;

import com.runvibe.entity.Activity;
import com.runvibe.entity.ActivityComment;
import com.runvibe.entity.ActivityKudos;
import com.runvibe.entity.ActivityKudosId;
import com.runvibe.entity.User;
import com.runvibe.entity.UserFollow;
import com.runvibe.entity.UserFollowId;
import com.runvibe.exception.ResourceNotFoundException;
import com.runvibe.repository.ActivityKudosRepository;
import com.runvibe.repository.ActivityCommentRepository;
import com.runvibe.repository.ActivityRepository;
import com.runvibe.repository.UserFollowRepository;
import com.runvibe.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SocialService {

    private final UserRepository userRepository;
    private final ActivityRepository activityRepository;
    private final ActivityKudosRepository kudosRepository;
    private final ActivityCommentRepository commentRepository;
    private final UserFollowRepository followRepository;

    @Transactional
    public ToggleResult toggleKudos(UUID activityId, UUID userId) {
        ActivityKudosId id = new ActivityKudosId(activityId, userId);
        if (kudosRepository.existsById(id)) {
            kudosRepository.deleteById(id);
            return new ToggleResult(false);
        }
        Activity activity = activityRepository.findById(activityId)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade não encontrada"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));
        ActivityKudos kudos = new ActivityKudos();
        kudos.setId(id);
        kudos.setActivity(activity);
        kudos.setUser(user);
        kudosRepository.save(kudos);
        return new ToggleResult(true);
    }

    @Transactional
    public ToggleResult toggleFollow(UUID followerId, UUID followedId) {
        if (followerId.equals(followedId)) {
            throw new IllegalArgumentException("Não é possível seguir a si mesmo");
        }
        UserFollowId id = new UserFollowId(followerId, followedId);
        if (followRepository.existsById(id)) {
            followRepository.deleteById(id);
            return new ToggleResult(false);
        }
        User follower = userRepository.findById(followerId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário autenticado não encontrado"));
        User followed = userRepository.findById(followedId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário a seguir não encontrado"));
        UserFollow follow = new UserFollow();
        follow.setId(id);
        follow.setFollower(follower);
        follow.setFollowed(followed);
        followRepository.save(follow);
        return new ToggleResult(true);
    }

    @Transactional(readOnly = true)
    public List<ActivityComment> getComments(UUID activityId) {
        if (!activityRepository.existsById(activityId)) {
            throw new ResourceNotFoundException("Atividade não encontrada");
        }
        return commentRepository.findByActivityIdOrderByCreatedAtAsc(activityId);
    }

    @Transactional
    public ActivityComment addComment(UUID activityId, UUID userId, String content) {
        Activity activity = activityRepository.findById(activityId)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade não encontrada"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));
        ActivityComment comment = new ActivityComment();
        comment.setActivity(activity);
        comment.setUser(user);
        comment.setContent(content.trim());
        return commentRepository.save(comment);
    }

    public record ToggleResult(boolean active) {
    }
}
