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

    /** 작성자가 목록에서 답변을 펼쳐 확인하면 확인 시점을 기록한다. (본인만, 멱등) */
    @Transactional
    public void markAnswerRead(Long qnaId, String userId) {
        Qna qna = qnaRepository.findById(qnaId)
                .orElseThrow(() -> new IllegalArgumentException("문의를 찾을 수 없습니다."));
        if (qna.getMember().getUserId().equals(userId)) {
            qna.markAnswerRead();
        }
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

    @Transactional
    public void updateQna(Long qnaId, String userId, String title, String content) {
        Qna qna = loadModifiable(qnaId, userId, "수정");
        qna.edit(title, content);
    }

    @Transactional
    public void deleteQna(Long qnaId, String userId) {
        loadModifiable(qnaId, userId, "삭제");
        qnaRepository.deleteById(qnaId);
    }

    /**
     * 작성자 본인 + 답변 전(미답변) 조건을 모두 만족할 때만 문의를 반환한다.
     * 답변이 달린 문의는 응대 기록 보존을 위해 수정·삭제할 수 없다.
     */
    private Qna loadModifiable(Long qnaId, String userId, String action) {
        Qna qna = qnaRepository.findById(qnaId)
                .orElseThrow(() -> new IllegalArgumentException("문의를 찾을 수 없습니다."));
        if (!qna.getMember().getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인이 작성한 문의만 " + action + "할 수 있습니다.");
        }
        if (qna.isAnswered()) {
            throw new IllegalArgumentException(
                    "답변이 등록된 문의는 " + action + "할 수 없습니다. 변경이 필요하면 고객센터로 문의해 주세요.");
        }
        return qna;
    }
}
