package com.kevolution.service;

import com.kevolution.entity.Member;
import com.kevolution.entity.Notice;
import com.kevolution.entity.Qna;
import com.kevolution.repository.MemberRepository;
import com.kevolution.repository.NoticeRepository;
import com.kevolution.repository.QnaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SupportService {

    private final NoticeRepository noticeRepository;
    private final QnaRepository qnaRepository;
    private final MemberRepository memberRepository;

    public Page<Notice> getNotices(Pageable pageable) {
        return noticeRepository.findAllByOrderByPinnedDescCreatedAtDesc(pageable);
    }

    @Transactional
    public Notice getNotice(Long noticeId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new IllegalArgumentException("공지사항을 찾을 수 없습니다."));
        notice.increaseViewCount();
        return notice;
    }

    public Page<Qna> getMyQnaList(String userId, Pageable pageable) {
        Member member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
        return qnaRepository.findByMemberOrderByCreatedAtDesc(member, pageable);
    }

    public Qna getQna(Long qnaId, String userId) {
        Qna qna = qnaRepository.findById(qnaId)
                .orElseThrow(() -> new IllegalArgumentException("문의를 찾을 수 없습니다."));
        if (qna.isSecret() && !qna.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("비밀 문의는 작성자만 볼 수 있습니다.");
        }
        return qna;
    }

    @Transactional
    public void writeQna(String userId, String title, String content, boolean secret) {
        Member member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));
        qnaRepository.save(Qna.builder()
                .member(member)
                .title(title)
                .content(content)
                .secret(secret)
                .build());
    }
}
