package com.runvibe.dto.social;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateCommentRequest(
        @NotBlank(message = "O comentário não pode ficar vazio")
        @Size(max = 1000, message = "O comentário deve ter no máximo 1000 caracteres")
        String content
) {
}
