package com.kevolution.ai.controller;

import com.kevolution.ai.dto.ChatMessage;
import com.kevolution.ai.dto.ChatRequest;
import com.kevolution.ai.dto.ChatResponse;
import com.kevolution.ai.service.AiService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

/**
 * AI 상담 챗봇 엔드포인트. 대화 이력은 우선 세션에만 유지한다(DB 저장 없음).
 * 접근 권한은 SecurityConfig 의 /api/ai/** 규칙으로 제한한다.
 */
@RestController
@RequiredArgsConstructor
public class ChatController {

    /** 세션에 유지할 최근 메시지 수(질문+답변 합산). 토큰/비용 관리를 위해 상한을 둔다. */
    private static final int MAX_HISTORY = 12;
    private static final String SESSION_KEY = "AI_CHAT_HISTORY";

    private final AiService aiService;

    @PostMapping("/api/ai/chat")
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest req, HttpSession session) {
        if (req == null || req.message() == null || req.message().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        String question = req.message().trim();

        List<ChatMessage> history = loadHistory(session);
        ChatResponse res = aiService.chat(question, history);

        history.add(new ChatMessage("user", question));
        history.add(new ChatMessage("assistant", res.answer()));
        trim(history);
        session.setAttribute(SESSION_KEY, history);

        return ResponseEntity.ok(res);
    }

    @SuppressWarnings("unchecked")
    private List<ChatMessage> loadHistory(HttpSession session) {
        Object stored = session.getAttribute(SESSION_KEY);
        return (stored instanceof List)
                ? new ArrayList<>((List<ChatMessage>) stored)
                : new ArrayList<>();
    }

    /** 오래된 메시지부터 잘라 최근 MAX_HISTORY 개만 남긴다. */
    private void trim(List<ChatMessage> history) {
        while (history.size() > MAX_HISTORY) {
            history.remove(0);
        }
    }
}
