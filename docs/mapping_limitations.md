# Mapping limitations

### Chinese (Simplified/Traditional):
- Only ~70 characters out of 50,000+ commonly used Chinese characters
- Missing: Most everyday vocabulary, proper nouns, technical terms
- No Traditional Chinese specific mappings (只有简体)
- No tone handling in Pinyin romanization

### Japanese:
- Hiragana/Katakana: ✅ Complete basic sets
- Kanji: ❌ Zero coverage - this is huge since most Japanese text uses Kanji
- No compound word handling (like 日本 → "nihon" vs "ni hon")
- Missing: Dakuten/handakuten variants, small tsu, etc.

### Korean:
- Only ~200 syllables out of 11,172 possible Hangul combinations
- Missing: Most actual Korean vocabulary
- No compound syllable decomposition
- Limited Jamo coverage

### Real-World Example Issues:

// What works now:
"你好" → "nihao" ✅
"こんにちは" → "konnichiha" ✅
"한국" → "hangug" ✅

// What fails:
"北京大学" → "" ❌ (Beijing University - no mappings)
"日本語" → "" ❌ (Japanese language - no kanji)
"프로그래밍" → "" ❌ (Programming - missing syllables)
"東京都" → "" ❌ (Tokyo - no kanji mappings)

To Handle "All Cases" Would Need:

1. Massive character databases (10,000+ Chinese characters)
2. Multiple romanization systems (Pinyin, Wade-Giles, etc.)
3. Context-aware translation (same character, different pronunciations)
4. Proper name handling (Beijing vs Bei Jing)
5. Traditional/Simplified Chinese support
6. Full Kanji database with readings (on'yomi/kun'yomi)
7. Korean compound word rules

This current implementation is a solid foundation for basic CJK support, but it's more of a "proof of concept" than production-ready comprehensive coverage. For full CJK support, you'd typically integrate with dedicated
transliteration libraries or services.
