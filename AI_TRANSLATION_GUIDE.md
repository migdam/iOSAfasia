# AI Translation Guide

Complete guide for using AI-powered translation in the Aphasia Therapy iOS app.

## Overview

The app supports **36+ languages** through AI-powered translation. Instead of manually translating every string into every language, the app uses a language model to automatically translate content on-demand.

### Benefits

- ✅ **Support for 36+ languages** out of the box
- ✅ **Automatic translation** of all app content
- ✅ **Cached translations** for fast performance
- ✅ **Offline fallback** to English and Polish
- ✅ **Medical terminology** awareness
- ✅ **Easy to add** new languages

## Supported Languages

### European Languages (19)
- 🇬🇧 English (base language)
- 🇵🇱 Polish (Polski) - pre-translated
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇩🇪 German (Deutsch)
- 🇮🇹 Italian (Italiano)
- 🇵🇹 Portuguese (Português)
- 🇳🇱 Dutch (Nederlands)
- 🇷🇺 Russian (Русский)
- 🇺🇦 Ukrainian (Українська)
- 🇨🇿 Czech (Čeština)
- 🇷🇴 Romanian (Română)
- 🇬🇷 Greek (Ελληνικά)
- 🇸🇪 Swedish (Svenska)
- 🇳🇴 Norwegian (Norsk)
- 🇩🇰 Danish (Dansk)
- 🇫🇮 Finnish (Suomi)
- 🇭🇺 Hungarian (Magyar)
- 🇹🇷 Turkish (Türkçe)

### Asian Languages (10)
- 🇨🇳 Chinese (中文)
- 🇯🇵 Japanese (日本語)
- 🇰🇷 Korean (한국어)
- 🇮🇳 Hindi (हिन्दी)
- 🇧🇩 Bengali (বাংলা)
- 🇻🇳 Vietnamese (Tiếng Việt)
- 🇹🇭 Thai (ไทย)
- 🇮🇩 Indonesian (Bahasa Indonesia)
- 🇵🇭 Filipino
- 🇲🇾 Malay (Bahasa Melayu)

### Middle Eastern Languages (4)
- 🇸🇦 Arabic (العربية) - RTL support
- 🇮🇱 Hebrew (עברית) - RTL support
- 🇮🇷 Persian (فارسی) - RTL support
- 🇵🇰 Urdu (اردو) - RTL support

### Other Languages (2)
- 🇰🇪 Swahili (Kiswahili)
- 🇿🇦 Afrikaans

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────┐
│          LocalizationManager                    │
│  - Manages current language                     │
│  - Provides localize() function                 │
│  - Coordinates with TranslationService          │
└────────────┬────────────────────────────────────┘
             │
             ├─ Hardcoded Translations (English, Polish)
             │  └─ Instant, no API needed
             │
             ├─ TranslationService (Other languages)
             │  ├─ Check cache first
             │  ├─ If not cached, call LLM API
             │  └─ Cache result for future use
             │
             └─ TranslationCacheManager
                ├─ In-memory cache
                └─ Persistent UserDefaults cache
```

### Translation Flow

1. **User selects a language** (e.g., Spanish)
2. **App checks for hardcoded translation**
   - English and Polish have pre-translated strings
   - Return immediately if found
3. **Check translation cache**
   - Cached translations are instant
4. **If not cached:**
   - Return English text temporarily
   - Request translation from AI in background
   - Cache the result
   - Update UI when translation is ready
5. **Batch loading** (optional)
   - Pre-load all translations when language is selected
   - Better UX but requires API call

## Setup Instructions

### 1. Get an API Key

#### Option A: OpenAI API (Recommended)

1. Sign up at [platform.openai.com](https://platform.openai.com)
2. Create an API key
3. Add credits to your account ($5-10 is plenty)

**Cost:** ~$0.002 per 1000 tokens
- Translating the entire app (~100 strings) ≈ $0.01
- Very affordable for production use

#### Option B: Other LLM APIs

The service can be adapted for:
- **Anthropic Claude API** - Excellent quality
- **Google Translate API** - Simple, good quality
- **Azure Translator** - Enterprise-grade
- **Self-hosted Llama** - Free, but requires server

### 2. Configure the App

#### Method 1: Settings Screen (End Users)

1. Open the app
2. Go to **Profile** tab
3. Tap **Language Preference**
4. Enable **AI Translation** toggle
5. Enter API key (if required)

#### Method 2: Environment Variable (Developers)

Add to `Config.swift`:

```swift
struct Config {
    static let translationAPIKey: String = {
        #if DEBUG
        return ProcessInfo.processInfo.environment["TRANSLATION_API_KEY"] ?? ""
        #else
        return KeychainService().getAPIKey("translation_api_key") ?? ""
        #endif
    }()
}
```

Then initialize:

```swift
// In TranslationService init
init(apiKey: String = Config.translationAPIKey) {
    self.apiKey = apiKey
}
```

#### Method 3: Hardcode (Testing Only)

⚠️ **Not recommended for production!**

Edit `TranslationService.swift`:

```swift
init(apiBaseURL: String = "https://api.openai.com/v1",
     apiKey: String = "sk-your-api-key-here") {
    self.apiBaseURL = apiBaseURL
    self.apiKey = apiKey
}
```

### 3. Test the Translation

1. Run the app
2. Go to Profile → Language Preference
3. Select a language (e.g., Spanish)
4. The app should:
   - Show English text initially
   - Load translations in background
   - Update UI with Spanish text
   - Show loading indicator during translation

## Usage Examples

### Basic Translation

```swift
// In any view
@EnvironmentObject var localizationManager: LocalizationManager

var body: some View {
    Text(localizationManager.localize("welcome"))
}
```

This automatically:
- Returns hardcoded translation if available
- Returns cached AI translation if available
- Triggers background translation if needed
- Falls back to English if translation fails

### Async Translation (Wait for Result)

```swift
let translation = await localizationManager.localizeAsync("session_complete")
```

This waits for the translation to complete before continuing.

### Batch Translation (Preload)

```swift
// Automatically called when language changes
await localizationManager.loadAITranslations()
```

This pre-translates all strings at once for better UX.

### Check Translation Status

```swift
if localizationManager.isLoadingTranslations {
    ProgressView()
}
```

## Customization

### Change LLM Provider

Edit `TranslationService.swift`:

```swift
private func callLLMAPI(prompt: String) async throws -> String {
    // Replace with your preferred API
    // Examples:
    // - Anthropic Claude: https://api.anthropic.com/v1/messages
    // - Google: https://translation.googleapis.com/language/translate/v2
    // - Azure: https://api.cognitive.microsofttranslator.com/translate
}
```

### Customize Translation Prompt

The prompt is optimized for medical/therapy terminology:

```swift
let prompt = """
Translate the following text from \(sourceLanguage.displayName) to \(targetLanguage.displayName).
Only provide the translation, no explanations.
Keep the same tone and formality level.
For medical/therapy terms, use professional terminology.

Text to translate:
\(text)

Translation:
"""
```

You can modify this to:
- Change tone (more formal/informal)
- Add context (this is a medical app)
- Specify terminology (use WHO standard terms)
- Add examples (translate "Home" as "Inicio" not "Casa")

### Add New Language

1. Add to `Language` enum in `LocalizationManager.swift`:

```swift
enum Language: String, CaseIterable {
    // ...
    case bulgarian = "bg"  // New language
}
```

2. Add display name:

```swift
var displayName: String {
    switch self {
    // ...
    case .bulgarian: return "Български"
    }
}
```

3. Add flag:

```swift
var flag: String {
    switch self {
    // ...
    case .bulgarian: return "🇧🇬"
    }
}
```

4. (Optional) Add RTL support:

```swift
var isRTL: Bool {
    switch self {
    case .arabic, .hebrew, .persian, .urdu:
        return true
    default:
        return false
    }
}
```

5. Done! The language is now available.

### Pre-translate a Language

For languages you expect to use heavily, pre-translate and hardcode:

```swift
translations[.spanish] = [
    "app_name": "Terapia de Afasia",
    "continue": "Continuar",
    "cancel": "Cancelar",
    // ... all strings
]
```

This makes Spanish instant like English and Polish.

## Performance Optimization

### Caching Strategy

Translations are cached at three levels:

1. **In-memory cache** (fastest)
   - Stored in `LocalizationManager.translations`
   - Lost when app closes

2. **UserDefaults cache** (persistent)
   - Stored in `TranslationCacheManager`
   - Survives app restarts
   - Cleared if user deletes app

3. **Hardcoded translations** (permanent)
   - English and Polish
   - Compiled into app
   - Always available

### Batch vs On-Demand

**Batch translation** (recommended):
- Pre-load all strings when language selected
- Better UX (no waiting)
- One API call (~100 strings)
- Cost: $0.01 per language change

**On-demand translation**:
- Translate only when needed
- Faster initial language switch
- More API calls (one per unique string)
- Cost: Same overall

Toggle in settings:

```swift
// In LocalizationManager init
currentLanguage = language {
    didSet {
        Task {
            await loadAITranslations()  // Batch load
        }
    }
}
```

Or remove for on-demand only.

### Reduce API Calls

1. **Use cache aggressively**:
   ```swift
   // Check cache before every translation
   if let cached = cacheManager.getCachedTranslation(...) {
       return cached
   }
   ```

2. **Hardcode popular languages**:
   - Identify top 5 languages from analytics
   - Pre-translate and hardcode them
   - Reduces API usage by 80%+

3. **Batch translations**:
   - Translate multiple strings in one API call
   - Current implementation does this

## Troubleshooting

### No translations appearing

**Check:**
- [ ] AI translation is enabled (Profile → AI Translation toggle)
- [ ] API key is configured correctly
- [ ] Internet connection is working
- [ ] No errors in Xcode console

**Fix:**
```swift
// In TranslationService
print("API Key: \(apiKey.prefix(10))...")  // Should show key
```

### Translations are slow

**Reasons:**
- Cold start (first translation takes 2-3 seconds)
- Network latency
- LLM API is slow

**Fix:**
- Use batch translation (pre-load)
- Show loading indicator
- Cache more aggressively

### Wrong translations

**Reasons:**
- LLM misunderstood context
- Medical terms not recognized
- Prompt needs improvement

**Fix:**
1. Update prompt with better context
2. Add examples to prompt
3. Use specialized medical translation API
4. Manually fix and hardcode that string

### API errors

**Common errors:**

```
"Translation API key not configured"
```
→ Add API key in settings

```
"Translation API error"
```
→ Check API key is valid and has credits

```
"Network error during translation"
```
→ Check internet connection

```
"Failed to parse translation response"
```
→ LLM returned unexpected format, check logs

## Cost Analysis

### OpenAI GPT-3.5-Turbo

- **Price**: $0.0015 per 1K input tokens, $0.002 per 1K output tokens
- **App has**: ~100 UI strings, ~20 words each = ~2000 words
- **Tokens**: ~2500 input + ~2500 output = 5000 tokens total
- **Cost per language**: ~$0.01
- **Cost for 36 languages**: ~$0.36 one-time

### Monthly Cost Estimate

Assuming:
- 1000 active users
- 50% change language once per month
- Average 2 language changes per user per month

**Calculation:**
- 1000 users × 50% = 500 language changes/month
- 500 × $0.01 = **$5/month**

Very affordable!

### Cost Reduction Strategies

1. **Pre-translate popular languages**: -80% cost
2. **Cache aggressively**: -50% redundant calls
3. **Use cheaper model**: GPT-3.5 instead of GPT-4
4. **Self-host**: Free but requires infrastructure

## Security Considerations

### API Key Storage

**Bad (hardcoded):**
```swift
let apiKey = "sk-abc123..."  // Never do this!
```

**Good (Keychain):**
```swift
let apiKey = KeychainService().getAPIKey("translation")
```

**Better (Environment + Keychain):**
```swift
#if DEBUG
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
#else
let apiKey = KeychainService().getAPIKey("translation") ?? ""
#endif
```

### API Key Management

**Development:**
- Use environment variables
- Add to `.gitignore`
- Share via secure channel (1Password, etc.)

**Production:**
- Store in Keychain
- Allow users to input their own key (optional)
- Or use backend proxy (more secure)

### Backend Proxy (Recommended)

Instead of calling OpenAI directly:

```
iOS App → Your Backend → OpenAI
```

Benefits:
- API key never exposed to client
- Rate limiting per user
- Usage analytics
- Cost control

Implementation:

```swift
// Change TranslationService endpoint
init(apiBaseURL: String = "https://api.yourbackend.com") {
    self.apiBaseURL = apiBaseURL
}

// Backend endpoint /translate
POST /api/translate
{
  "text": "Welcome",
  "source_lang": "en",
  "target_lang": "es"
}

// Backend forwards to OpenAI and returns result
```

## Advanced Features

### RTL Language Support

Arabic, Hebrew, Persian, and Urdu need right-to-left layout:

```swift
var body: some View {
    Text(localizationManager.localize("welcome"))
        .environment(\.layoutDirection,
                     localizationManager.currentLanguage.isRTL ? .rightToLeft : .leftToRight)
}
```

### Translation Quality Feedback

Allow users to report bad translations:

```swift
Button("Report Translation Issue") {
    reportTranslation(key: "welcome", language: currentLanguage)
}
```

Store feedback and manually review/fix.

### A/B Testing Translations

Compare AI translations vs professional:

```swift
if experimentGroup == "ai" {
    return aiTranslation
} else {
    return professionalTranslation
}
```

Measure user satisfaction, retention, etc.

## FAQ

**Q: Do I need an API key?**
A: Only if you want languages beyond English and Polish. Those two work offline.

**Q: Does this work offline?**
A: Partially. Cached translations work offline. New translations need internet.

**Q: Can I use this in production?**
A: Yes! It's production-ready. Just configure API key securely.

**Q: How accurate are the translations?**
A: Very accurate for common languages. Medical terms are good but not perfect. Consider professional review for critical content.

**Q: Can I mix AI and manual translations?**
A: Yes! Hardcoded translations always take priority over AI.

**Q: How do I add my own translations?**
A: Add them to `translations[.language]` dictionary. They'll override AI.

**Q: What if the LLM API is down?**
A: App falls back to English. Cached translations still work.

**Q: Can I use a different LLM?**
A: Yes! Just modify `callLLMAPI()` in TranslationService.

**Q: Is this HIPAA compliant?**
A: Depends on API provider. OpenAI API is not HIPAA compliant by default. Use Azure OpenAI for HIPAA.

## Resources

- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [Anthropic Claude API](https://docs.anthropic.com/claude/reference)
- [Google Cloud Translation](https://cloud.google.com/translate/docs)
- [Azure Translator](https://docs.microsoft.com/en-us/azure/cognitive-services/translator/)
- [Apple Localization Guide](https://developer.apple.com/localization/)

## Support

Questions about AI translation?

- **GitHub Issues**: Report bugs and request features
- **Email**: dev@aphasiatherapy.com
- **Documentation**: This guide!

---

**Happy Translating! 🌍**
