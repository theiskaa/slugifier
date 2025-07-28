const std = @import("std");

/// Maps a CJK Unicode codepoint to ASCII equivalent
pub fn mapCJKCodepoint(codepoint: u21) ?[]const u8 {
    // Common CJK punctuation and symbols
    return switch (codepoint) {
        // CJK punctuation
        0x3000 => " ", // Ideographic space
        0x3001 => ",", // Ideographic comma
        0x3002 => ".", // Ideographic full stop
        0x3008 => "<", // Left angle bracket
        0x3009 => ">", // Right angle bracket
        0x300A => "<<", // Left double angle bracket
        0x300B => ">>", // Right double angle bracket
        0x300C => "[", // Left corner bracket
        0x300D => "]", // Right corner bracket
        0x300E => "[", // Left white corner bracket
        0x300F => "]", // Right white corner bracket
        0x3010 => "[", // Left black lenticular bracket
        0x3011 => "]", // Right black lenticular bracket
        0x3014 => "[", // Left tortoise shell bracket
        0x3015 => "]", // Right tortoise shell bracket
        0x3016 => "[", // Left white lenticular bracket
        0x3017 => "]", // Right white lenticular bracket
        0x3018 => "[", // Left white tortoise shell bracket
        0x3019 => "]", // Right white tortoise shell bracket
        0x301A => "[", // Left white square bracket
        0x301B => "]", // Right white square bracket
        
        // Japanese punctuation
        0x30FB => ".", // Katakana middle dot
        0x30FC => "-", // Katakana-hiragana prolonged sound mark
        
        // Full-width ASCII variants
        0xFF01 => "!", // Fullwidth exclamation mark
        0xFF02 => "\"", // Fullwidth quotation mark
        0xFF03 => "#", // Fullwidth number sign
        0xFF04 => "$", // Fullwidth dollar sign
        0xFF05 => "%", // Fullwidth percent sign
        0xFF06 => "&", // Fullwidth ampersand
        0xFF07 => "'", // Fullwidth apostrophe
        0xFF08 => "(", // Fullwidth left parenthesis
        0xFF09 => ")", // Fullwidth right parenthesis
        0xFF0A => "*", // Fullwidth asterisk
        0xFF0B => "+", // Fullwidth plus sign
        0xFF0C => ",", // Fullwidth comma
        0xFF0D => "-", // Fullwidth hyphen-minus
        0xFF0E => ".", // Fullwidth full stop
        0xFF0F => "/", // Fullwidth solidus
        0xFF10...0xFF19 => |cp| blk: {
            const digit = @as(u8, @intCast(cp - 0xFF10 + '0'));
            break :blk &[_]u8{digit};
        }, // Fullwidth digits 0-9
        0xFF1A => ":", // Fullwidth colon
        0xFF1B => ";", // Fullwidth semicolon
        0xFF1C => "<", // Fullwidth less-than sign
        0xFF1D => "=", // Fullwidth equals sign
        0xFF1E => ">", // Fullwidth greater-than sign
        0xFF1F => "?", // Fullwidth question mark
        0xFF20 => "@", // Fullwidth commercial at
        0xFF21...0xFF3A => |cp| blk: {
            const letter = @as(u8, @intCast(cp - 0xFF21 + 'A'));
            break :blk &[_]u8{letter};
        }, // Fullwidth A-Z
        0xFF3B => "[", // Fullwidth left square bracket
        0xFF3C => "\\", // Fullwidth reverse solidus
        0xFF3D => "]", // Fullwidth right square bracket
        0xFF3E => "^", // Fullwidth circumflex accent
        0xFF3F => "_", // Fullwidth low line
        0xFF40 => "`", // Fullwidth grave accent
        0xFF41...0xFF5A => |cp| blk: {
            const letter = @as(u8, @intCast(cp - 0xFF41 + 'a'));
            break :blk &[_]u8{letter};
        }, // Fullwidth a-z
        0xFF5B => "{", // Fullwidth left curly bracket
        0xFF5C => "|", // Fullwidth vertical line
        0xFF5D => "}", // Fullwidth right curly bracket
        0xFF5E => "~", // Fullwidth tilde
        
        else => {
            // Try Japanese hiragana/katakana as fallback for generic CJK mapping
            if (mapJapaneseCodepoint(codepoint)) |mapping| {
                return mapping;
            }
            return null;
        },
    };
}

/// Chinese-specific character mappings using Pinyin romanization
pub fn mapChineseCodepoint(codepoint: u21) ?[]const u8 {
    // Common Chinese characters with Pinyin romanization
    return switch (codepoint) {
        // Numbers
        0x4E00 => "yi", // 一 (one)
        0x4E8C => "er", // 二 (two)
        0x4E09 => "san", // 三 (three)
        0x56DB => "si", // 四 (four)
        0x4E94 => "wu", // 五 (five)
        0x516D => "liu", // 六 (six)
        0x4E03 => "qi", // 七 (seven)
        0x516B => "ba", // 八 (eight)
        0x4E5D => "jiu", // 九 (nine)
        0x5341 => "shi", // 十 (ten)
        0x767E => "bai", // 百 (hundred)
        0x5343 => "qian", // 千 (thousand)
        0x4E07 => "wan", // 万 (ten thousand)
        
        // Common words
        0x4EBA => "ren", // 人 (person)
        0x5927 => "da", // 大 (big)
        0x5C0F => "xiao", // 小 (small)
        0x4E2D => "zhong", // 中 (middle/China)
        0x56FD => "guo", // 国 (country)
        0x5BB6 => "jia", // 家 (home/family)
        0x4E0A => "shang", // 上 (up/above)
        0x4E0B => "xia", // 下 (down/below)
        0x5929 => "tian", // 天 (sky/day)
        0x5730 => "di", // 地 (earth/ground)
        0x6C34 => "shui", // 水 (water)
        0x706B => "huo", // 火 (fire)
        0x6728 => "mu", // 木 (wood)
        0x91D1 => "jin", // 金 (metal/gold)
        0x571F => "tu", // 土 (earth/soil)
        0x65E5 => "ri", // 日 (sun/day)
        0x6708 => "yue", // 月 (moon/month)
        0x5E74 => "nian", // 年 (year)
        0x4E66 => "shu", // 书 (book)
        0x5B66 => "xue", // 学 (study/learn)
        0x6821 => "xiao", // 校 (school)
        0x8001 => "lao", // 老 (old)
        0x5E08 => "shi", // 师 (teacher)
        0x597D => "hao", // 好 (good)
        0x4E0D => "bu", // 不 (not)
        0x662F => "shi", // 是 (to be)
        0x6709 => "you", // 有 (to have)
        0x6CA1 => "mei", // 没 (not have)
        0x548C => "he", // 和 (and)
        0x6211 => "wo", // 我 (I/me)
        0x4F60 => "ni", // 你 (you)
        0x4ED6 => "ta", // 他 (he/him)
        0x5979 => "ta", // 她 (she/her)
        0x5B83 => "ta", // 它 (it)
        0x4EEC => "men", // 们 (plural marker)
        0x7684 => "de", // 的 (possessive particle)
        0x5728 => "zai", // 在 (at/in)
        0x53BB => "qu", // 去 (to go)
        0x6765 => "lai", // 来 (to come)
        0x56DE => "hui", // 回 (to return)
        0x770B => "kan", // 看 (to see/look)
        0x542C => "ting", // 听 (to listen)
        0x8BF4 => "shuo", // 说 (to say/speak)
        0x5403 => "chi", // 吃 (to eat)
        0x559D => "he", // 喝 (to drink)
        0x7761 => "shui", // 睡 (to sleep)
        0x8D77 => "qi", // 起 (to get up)
        0x505A => "zuo", // 做 (to do/make)
        0x4F5C => "zuo", // 作 (to work/make)
        0x5DE5 => "gong", // 工 (work)
        0x7231 => "ai", // 爱 (love)
        0x559C => "xi", // 喜 (like/happy)
        0x6B22 => "huan", // 欢 (happy/joyful)
        0x9AD8 => "gao", // 高 (tall/high)
        0x77EE => "ai", // 矮 (short/low)
        0x957F => "chang", // 长 (long)
        0x77ED => "duan", // 短 (short)
        0x65B0 => "xin", // 新 (new)
        0x65E7 => "jiu", // 旧 (old)
        0x5FEB => "kuai", // 快 (fast)
        0x6162 => "man", // 慢 (slow)
        0x591A => "duo", // 多 (many/much)
        0x5C11 => "shao", // 少 (few/little)
        
        else => null,
    };
}

/// Japanese-specific character mappings using Romaji
pub fn mapJapaneseCodepoint(codepoint: u21) ?[]const u8 {
    // Hiragana to Romaji
    if (codepoint >= 0x3041 and codepoint <= 0x3096) {
        return switch (codepoint) {
            0x3042 => "a", // あ
            0x3044 => "i", // い
            0x3046 => "u", // う
            0x3048 => "e", // え
            0x304A => "o", // お
            0x304B => "ka", // か
            0x304D => "ki", // き
            0x304F => "ku", // く
            0x3051 => "ke", // け
            0x3053 => "ko", // こ
            0x3055 => "sa", // さ
            0x3057 => "shi", // し
            0x3059 => "su", // す
            0x305B => "se", // せ
            0x305D => "so", // そ
            0x305F => "ta", // た
            0x3061 => "chi", // ち
            0x3064 => "tsu", // つ
            0x3066 => "te", // て
            0x3068 => "to", // と
            0x306A => "na", // な
            0x306B => "ni", // に
            0x306C => "nu", // ぬ
            0x306D => "ne", // ね
            0x306E => "no", // の
            0x306F => "ha", // は
            0x3072 => "hi", // ひ
            0x3075 => "fu", // ふ
            0x3078 => "he", // へ
            0x307B => "ho", // ほ
            0x307E => "ma", // ま
            0x307F => "mi", // み
            0x3080 => "mu", // む
            0x3081 => "me", // め
            0x3082 => "mo", // も
            0x3084 => "ya", // や
            0x3086 => "yu", // ゆ
            0x3088 => "yo", // よ
            0x3089 => "ra", // ら
            0x308A => "ri", // り
            0x308B => "ru", // る
            0x308C => "re", // れ
            0x308D => "ro", // ろ
            0x308F => "wa", // わ
            0x3092 => "wo", // を
            0x3093 => "n", // ん
            else => null,
        };
    }
    
    // Katakana to Romaji
    if (codepoint >= 0x30A1 and codepoint <= 0x30F6) {
        return switch (codepoint) {
            0x30A2 => "a", // ア
            0x30A4 => "i", // イ
            0x30A6 => "u", // ウ
            0x30A8 => "e", // エ
            0x30AA => "o", // オ
            0x30AB => "ka", // カ
            0x30AD => "ki", // キ
            0x30AF => "ku", // ク
            0x30B1 => "ke", // ケ
            0x30B3 => "ko", // コ
            0x30B5 => "sa", // サ
            0x30B7 => "shi", // シ
            0x30B9 => "su", // ス
            0x30BB => "se", // セ
            0x30BD => "so", // ソ
            0x30BF => "ta", // タ
            0x30C1 => "chi", // チ
            0x30C4 => "tsu", // ツ
            0x30C6 => "te", // テ
            0x30C8 => "to", // ト
            0x30CA => "na", // ナ
            0x30CB => "ni", // ニ
            0x30CC => "nu", // ヌ
            0x30CD => "ne", // ネ
            0x30CE => "no", // ノ
            0x30CF => "ha", // ハ
            0x30D2 => "hi", // ヒ
            0x30D5 => "fu", // フ
            0x30D8 => "he", // ヘ
            0x30DB => "ho", // ホ
            0x30DE => "ma", // マ
            0x30DF => "mi", // ミ
            0x30E0 => "mu", // ム
            0x30E1 => "me", // メ
            0x30E2 => "mo", // モ
            0x30E4 => "ya", // ヤ
            0x30E6 => "yu", // ユ
            0x30E8 => "yo", // ヨ
            0x30E9 => "ra", // ラ
            0x30EA => "ri", // リ
            0x30EB => "ru", // ル
            0x30EC => "re", // レ
            0x30ED => "ro", // ロ
            0x30EF => "wa", // ワ
            0x30F2 => "wo", // ヲ
            0x30F3 => "n", // ン
            else => null,
        };
    }
    
    return null;
}

/// Korean-specific character mappings using Romanization
pub fn mapKoreanCodepoint(codepoint: u21) ?[]const u8 {
    // Hangul syllables - we'll map some common ones
    // This is a simplified mapping for common Korean syllables
    if (codepoint >= 0xAC00 and codepoint <= 0xD7AF) {
        return switch (codepoint) {
            // Common Korean syllables
            0xAC00 => "ga", // 가
            0xAC01 => "gag", // 각
            0xAC04 => "gan", // 간
            0xAC15 => "gam", // 감
            0xAC19 => "gam", // 갑
            0xAC70 => "geo", // 거
            0xAC71 => "geog", // 걱
            0xAC74 => "geon", // 건
            0xAC83 => "geom", // 검
            0xAC8C => "gae", // 게
            0xACBD => "gyeong", // 경
            0xACE0 => "go", // 고
            0xACE1 => "gog", // 곡
            0xACE4 => "gon", // 곤
            0xACF5 => "gong", // 공
            0xAD00 => "gwa", // 과
            0xAD11 => "gwang", // 광
            0xAD34 => "gyo", // 교
            0xAD6C => "gu", // 구
            0xAD6D => "gug", // 국
            0xAD70 => "gun", // 군
            0xAD74 => "gul", // 굴
            0xADC0 => "geu", // 그
            0xADC4 => "geun", // 근
            0xADF8 => "gi", // 기
            0xAE30 => "na", // 나
            0xAE4C => "nae", // 내
            0xB098 => "neo", // 너
            0xB140 => "no", // 노
            0xB178 => "nu", // 누
            0xB2E4 => "da", // 다
            0xB300 => "dang", // 당
            0xB358 => "dae", // 대
            0xB3C4 => "do", // 도
            0xB3C5 => "dog", // 독
            0xB3D9 => "dong", // 동
            0xB418 => "doel", // 될
            0xB450 => "du", // 두
            0xB4E4 => "deul", // 들
            0xB514 => "deu", // 드
            0xB77C => "ra", // 라
            0xB9AC => "ri", // 리
            0xB9C8 => "ma", // 마
            0xB9CE => "man", // 만
            0xB9D0 => "mal", // 말
            0xBA74 => "myeon", // 면
            0xBAAC => "mo", // 모
            0xBB34 => "mu", // 무
            0xBBF8 => "mi", // 미
            0xBC14 => "ba", // 바
            0xBC15 => "bag", // 박
            0xBC18 => "ban", // 반
            0xBC31 => "baeg", // 백
            0xBC88 => "beon", // 번
            0xBCF4 => "bo", // 보
            0xBCF5 => "bog", // 복
            0xBD80 => "bu", // 부
            0xBD84 => "bun", // 분
            0xBE44 => "bi", // 비
            0xC0AC => "sa", // 사
            0xC0AD => "sag", // 삭
            0xC0B0 => "san", // 산
            0xC0C1 => "sang", // 상
            0xC11C => "seo", // 서
            0xC120 => "seon", // 선
            0xC131 => "seong", // 성
            0xC138 => "se", // 세
            0xC18C => "so", // 소
            0xC18D => "sog", // 속
            0xC218 => "su", // 수
            0xC2A4 => "seu", // 스
            0xC2DC => "si", // 시
            0xC544 => "a", // 아
            0xC548 => "an", // 안
            0xC554 => "am", // 암
            0xC591 => "yang", // 양
            0xC5B4 => "eo", // 어
            0xC5B5 => "eog", // 억
            0xC5B8 => "eon", // 언
            0xC5C4 => "eom", // 엄
            0xC5C6 => "eob", // 업
            0xC5C9 => "eobs", // 없
            0xC5D0 => "e", // 에
            0xC624 => "o", // 오
            0xC625 => "og", // 옥
            0xC628 => "on", // 온
            0xC640 => "wa", // 와
            0xC644 => "wan", // 완
            0xC678 => "oe", // 외
            0xC694 => "yo", // 요
            0xC6A9 => "yong", // 용
            0xC6B0 => "u", // 우
            0xC6B1 => "ug", // 욱
            0xC6B4 => "un", // 운
            0xC6C0 => "ul", // 울
            0xC6D0 => "won", // 원
            0xC704 => "wi", // 위
            0xC720 => "yu", // 유
            0xC721 => "yug", // 육
            0xC724 => "yun", // 윤
            0xC73C => "eu", // 으
            0xC740 => "eun", // 은
            0xC744 => "eul", // 을
            0xC751 => "eung", // 응
            0xC758 => "ui", // 의
            0xC774 => "i", // 이
            0xC778 => "in", // 인
            0xC785 => "im", // 임
            0xC788 => "iss", // 있
            0xC790 => "ja", // 자
            0xC791 => "jag", // 작
            0xC794 => "jan", // 잔
            0xC7A5 => "jang", // 장
            0xC7AC => "jae", // 재
            0xC800 => "jeo", // 저
            0xC804 => "jeon", // 전
            0xC815 => "jeong", // 정
            0xC81C => "je", // 제
            0xC870 => "jo", // 조
            0xC871 => "jog", // 족
            0xC874 => "jon", // 존
            0xC885 => "jong", // 종
            0xC8FC => "ju", // 주
            0xC8FD => "jun", // 준
            0xC911 => "jung", // 중
            0xC988 => "ji", // 지
            0xC9C0 => "cha", // 차
            0xCC28 => "chal", // 찰
            0xCC38 => "cham", // 참
            0xCC44 => "chang", // 창
            0xCC98 => "cheo", // 처
            0xCC9C => "cheon", // 천
            0xCCA0 => "cheol", // 철
            0xCCB4 => "che", // 체
            0xCD08 => "cho", // 초
            0xCD5C => "choe", // 최
            0xCD94 => "chu", // 추
            0xCDA9 => "chul", // 출
            0xCE58 => "chi", // 치
            0xCE74 => "ka", // 카
            0xD0A4 => "ki", // 키
            0xD0C0 => "ta", // 타
            0xD0DC => "tae", // 태
            0xD130 => "teo", // 터
            0xD1A0 => "to", // 토
            0xD1B5 => "tong", // 통
            0xD22C => "tu", // 투
            0xD280 => "teul", // 틀
            0xD2B8 => "ti", // 티
            0xD30C => "pa", // 파
            0xD310 => "pan", // 판
            0xD314 => "pal", // 팔
            0xD37C => "peo", // 퍼
            0xD3B8 => "pyeon", // 편
            0xD3C9 => "pyeong", // 평
            0xD3EC => "po", // 포
            0xD480 => "pu", // 푸
            0xD488 => "pul", // 풀
            0xD504 => "peu", // 프
            0xD53C => "pi", // 피
            0xD558 => "ha", // 하
            0xD55C => "han", // 한
            0xD560 => "hal", // 할
            0xD569 => "hab", // 합
            0xD574 => "hae", // 해
            0xD575 => "haeg", // 핵
            0xD5A5 => "hyang", // 향
            0xD5C8 => "heo", // 허
            0xD601 => "hyeon", // 현
            0xD615 => "hyeong", // 형
            0xD61C => "hye", // 혜
            0xD638 => "ho", // 호
            0xD63C => "hon", // 혼
            0xD654 => "hwa", // 화
            0xD655 => "hwag", // 확
            0xD658 => "hwan", // 환
            0xD669 => "hwang", // 황
            0xD68C => "hoe", // 회
            0xD6A8 => "hyo", // 효
            0xD6C4 => "hu", // 후
            0xD760 => "heul", // 흘
            0xD788 => "hi", // 히
            else => null,
        };
    }
    
    // Hangul Jamo (basic consonants and vowels)
    if (codepoint >= 0x1100 and codepoint <= 0x11FF) {
        return switch (codepoint) {
            0x1100 => "g", // ㄱ
            0x1101 => "gg", // ㄲ
            0x1102 => "n", // ㄴ
            0x1103 => "d", // ㄷ
            0x1104 => "dd", // ㄸ
            0x1105 => "r", // ㄹ
            0x1106 => "m", // ㅁ
            0x1107 => "b", // ㅂ
            0x1108 => "bb", // ㅃ
            0x1109 => "s", // ㅅ
            0x110A => "ss", // ㅆ
            0x110B => "", // ㅇ (silent)
            0x110C => "j", // ㅈ
            0x110D => "jj", // ㅉ
            0x110E => "ch", // ㅊ
            0x110F => "k", // ㅋ
            0x1110 => "t", // ㅌ
            0x1111 => "p", // ㅍ
            0x1112 => "h", // ㅎ
            0x1161 => "a", // ㅏ
            0x1162 => "ae", // ㅐ
            0x1163 => "ya", // ㅑ
            0x1164 => "yae", // ㅒ
            0x1165 => "eo", // ㅓ
            0x1166 => "e", // ㅔ
            0x1167 => "yeo", // ㅕ
            0x1168 => "ye", // ㅖ
            0x1169 => "o", // ㅗ
            0x116A => "wa", // ㅘ
            0x116B => "wae", // ㅙ
            0x116C => "oe", // ㅚ
            0x116D => "yo", // ㅛ
            0x116E => "u", // ㅜ
            0x116F => "wo", // ㅝ
            0x1170 => "we", // ㅞ
            0x1171 => "wi", // ㅟ
            0x1172 => "yu", // ㅠ
            0x1173 => "eu", // ㅡ
            0x1174 => "ui", // ㅢ
            0x1175 => "i", // ㅣ
            else => null,
        };
    }
    
    return null;
}

test "cjk mappings - common punctuation" {
    try std.testing.expectEqualStrings(" ", mapCJKCodepoint(0x3000).?); // Ideographic space
    try std.testing.expectEqualStrings(",", mapCJKCodepoint(0x3001).?); // Ideographic comma
    try std.testing.expectEqualStrings(".", mapCJKCodepoint(0x3002).?); // Ideographic full stop
    try std.testing.expectEqualStrings("<", mapCJKCodepoint(0x3008).?); // Left angle bracket
    try std.testing.expectEqualStrings(">", mapCJKCodepoint(0x3009).?); // Right angle bracket
}

test "cjk mappings - fullwidth ascii" {
    try std.testing.expectEqualStrings("!", mapCJKCodepoint(0xFF01).?); // Fullwidth exclamation
    try std.testing.expectEqualStrings("0", mapCJKCodepoint(0xFF10).?); // Fullwidth 0
    try std.testing.expectEqualStrings("9", mapCJKCodepoint(0xFF19).?); // Fullwidth 9
    try std.testing.expectEqualStrings("A", mapCJKCodepoint(0xFF21).?); // Fullwidth A
    try std.testing.expectEqualStrings("Z", mapCJKCodepoint(0xFF3A).?); // Fullwidth Z
    try std.testing.expectEqualStrings("a", mapCJKCodepoint(0xFF41).?); // Fullwidth a
    try std.testing.expectEqualStrings("z", mapCJKCodepoint(0xFF5A).?); // Fullwidth z
}

test "chinese mappings - numbers" {
    try std.testing.expectEqualStrings("yi", mapChineseCodepoint(0x4E00).?); // 一 (one)
    try std.testing.expectEqualStrings("er", mapChineseCodepoint(0x4E8C).?); // 二 (two)
    try std.testing.expectEqualStrings("san", mapChineseCodepoint(0x4E09).?); // 三 (three)
    try std.testing.expectEqualStrings("si", mapChineseCodepoint(0x56DB).?); // 四 (four)
    try std.testing.expectEqualStrings("wu", mapChineseCodepoint(0x4E94).?); // 五 (five)
    try std.testing.expectEqualStrings("shi", mapChineseCodepoint(0x5341).?); // 十 (ten)
}

test "chinese mappings - common words" {
    try std.testing.expectEqualStrings("ren", mapChineseCodepoint(0x4EBA).?); // 人 (person)
    try std.testing.expectEqualStrings("da", mapChineseCodepoint(0x5927).?); // 大 (big)
    try std.testing.expectEqualStrings("xiao", mapChineseCodepoint(0x5C0F).?); // 小 (small)
    try std.testing.expectEqualStrings("zhong", mapChineseCodepoint(0x4E2D).?); // 中 (middle)
    try std.testing.expectEqualStrings("guo", mapChineseCodepoint(0x56FD).?); // 国 (country)
    try std.testing.expectEqualStrings("wo", mapChineseCodepoint(0x6211).?); // 我 (I/me)
    try std.testing.expectEqualStrings("ni", mapChineseCodepoint(0x4F60).?); // 你 (you)
    try std.testing.expectEqualStrings("hao", mapChineseCodepoint(0x597D).?); // 好 (good)
}

test "japanese mappings - hiragana" {
    try std.testing.expectEqualStrings("a", mapJapaneseCodepoint(0x3042).?); // あ
    try std.testing.expectEqualStrings("ka", mapJapaneseCodepoint(0x304B).?); // か
    try std.testing.expectEqualStrings("ki", mapJapaneseCodepoint(0x304D).?); // き
    try std.testing.expectEqualStrings("ku", mapJapaneseCodepoint(0x304F).?); // く
    try std.testing.expectEqualStrings("sa", mapJapaneseCodepoint(0x3055).?); // さ
    try std.testing.expectEqualStrings("shi", mapJapaneseCodepoint(0x3057).?); // し
    try std.testing.expectEqualStrings("ta", mapJapaneseCodepoint(0x305F).?); // た
    try std.testing.expectEqualStrings("chi", mapJapaneseCodepoint(0x3061).?); // ち
    try std.testing.expectEqualStrings("tsu", mapJapaneseCodepoint(0x3064).?); // つ
    try std.testing.expectEqualStrings("n", mapJapaneseCodepoint(0x3093).?); // ん
}

test "japanese mappings - katakana" {
    try std.testing.expectEqualStrings("a", mapJapaneseCodepoint(0x30A2).?); // ア
    try std.testing.expectEqualStrings("ka", mapJapaneseCodepoint(0x30AB).?); // カ
    try std.testing.expectEqualStrings("ki", mapJapaneseCodepoint(0x30AD).?); // キ
    try std.testing.expectEqualStrings("ku", mapJapaneseCodepoint(0x30AF).?); // ク
    try std.testing.expectEqualStrings("sa", mapJapaneseCodepoint(0x30B5).?); // サ
    try std.testing.expectEqualStrings("shi", mapJapaneseCodepoint(0x30B7).?); // シ
    try std.testing.expectEqualStrings("ta", mapJapaneseCodepoint(0x30BF).?); // タ
    try std.testing.expectEqualStrings("chi", mapJapaneseCodepoint(0x30C1).?); // チ
    try std.testing.expectEqualStrings("tsu", mapJapaneseCodepoint(0x30C4).?); // ツ
    try std.testing.expectEqualStrings("n", mapJapaneseCodepoint(0x30F3).?); // ン
}

test "korean mappings - common syllables" {
    try std.testing.expectEqualStrings("ga", mapKoreanCodepoint(0xAC00).?); // 가
    try std.testing.expectEqualStrings("an", mapKoreanCodepoint(0xC548).?); // 안
    try std.testing.expectEqualStrings("a", mapKoreanCodepoint(0xC544).?); // 아
    try std.testing.expectEqualStrings("han", mapKoreanCodepoint(0xD55C).?); // 한
    try std.testing.expectEqualStrings("gug", mapKoreanCodepoint(0xAD6D).?); // 국
    try std.testing.expectEqualStrings("hae", mapKoreanCodepoint(0xD574).?); // 해
    try std.testing.expectEqualStrings("sa", mapKoreanCodepoint(0xC0AC).?); // 사
    // Test unmapped character returns null
    try std.testing.expectEqual(@as(?[]const u8, null), mapKoreanCodepoint(0xB791)); // 람 - not in our mapping
}

test "korean mappings - hangul jamo" {
    try std.testing.expectEqualStrings("g", mapKoreanCodepoint(0x1100).?); // ㄱ
    try std.testing.expectEqualStrings("n", mapKoreanCodepoint(0x1102).?); // ㄴ
    try std.testing.expectEqualStrings("d", mapKoreanCodepoint(0x1103).?); // ㄷ
    try std.testing.expectEqualStrings("r", mapKoreanCodepoint(0x1105).?); // ㄹ
    try std.testing.expectEqualStrings("m", mapKoreanCodepoint(0x1106).?); // ㅁ
    try std.testing.expectEqualStrings("a", mapKoreanCodepoint(0x1161).?); // ㅏ
    try std.testing.expectEqualStrings("i", mapKoreanCodepoint(0x1175).?); // ㅣ
}

test "cjk mappings - unmapped characters return null" {
    try std.testing.expectEqual(@as(?[]const u8, null), mapCJKCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapChineseCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapJapaneseCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapKoreanCodepoint('a')); // Regular ASCII
    try std.testing.expectEqual(@as(?[]const u8, null), mapChineseCodepoint(0x0041)); // Latin A
    try std.testing.expectEqual(@as(?[]const u8, null), mapJapaneseCodepoint(0x0041)); // Latin A
    try std.testing.expectEqual(@as(?[]const u8, null), mapKoreanCodepoint(0x0041)); // Latin A
}