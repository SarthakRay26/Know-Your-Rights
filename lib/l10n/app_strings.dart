/// All user-facing strings used in the app, keyed by locale code.
/// This avoids hardcoding any string in widgets.
class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_title': 'Know Your Rights',
      'select_language': 'Choose Your Language',
      'continue_btn': 'Continue',
      'home_title': 'What happened?',
      'home_subtitle': 'Select the issue you are facing',
      'step_of': 'Step {current} of {total}',
      'your_rights': 'Your Rights',
      'what_law_says': 'What the law says',
      'common_myths': 'Common Myths',
      'myth_label': 'Myth',
      'fact_label': 'Fact',
      'applicable_laws': 'Applicable Laws',
      'typical_timeline': 'Typical Timeline',
      'action_steps': 'What You Should Do',
      'next': 'Next',
      'back': 'Back',
      'see_your_rights': 'See Your Rights',
      'see_action_steps': 'What Should I Do?',
      'disclaimer': 'This is general legal awareness, not legal advice.',
      'bookmark': 'Bookmark',
      'bookmarked': 'Bookmarked',
      'describe_problem': 'Describe your problem',
      'chat_greeting': 'Describe what happened. You can write in simple words.',
      'chat_unclear': "I couldn't clearly understand the issue.",
      'chat_choose_from_list': 'Choose from list',
      'chat_try_rephrase': 'Try rephrasing',
      'chat_detected': 'This seems related to: {issue}',
      'chat_yes_correct': "Yes, that's correct",
      'chat_no_different': 'No, choose a different issue',
      'chat_error': 'Something went wrong. You can choose the issue manually.',
      'chat_rephrase_prompt': 'No problem. Try describing what happened in different words.',
      'chat_input_hint': 'Describe what happened...',
      'chat_title': 'Describe Your Problem',
    },
    'hi': {
      'app_title': 'अपने अधिकार जानें',
      'select_language': 'अपनी भाषा चुनें',
      'continue_btn': 'जारी रखें',
      'home_title': 'क्या हुआ?',
      'home_subtitle': 'आप जिस समस्या का सामना कर रहे हैं उसे चुनें',
      'step_of': 'चरण {current} / {total}',
      'your_rights': 'आपके अधिकार',
      'what_law_says': 'कानून क्या कहता है',
      'common_myths': 'आम भ्रांतियाँ',
      'myth_label': 'भ्रांति',
      'fact_label': 'सच',
      'applicable_laws': 'लागू कानून',
      'typical_timeline': 'सामान्य समयसीमा',
      'action_steps': 'आपको क्या करना चाहिए',
      'next': 'आगे',
      'back': 'पीछे',
      'see_your_rights': 'अपने अधिकार देखें',
      'see_action_steps': 'मुझे क्या करना चाहिए?',
      'disclaimer': 'यह सामान्य कानूनी जागरूकता है, कानूनी सलाह नहीं।',
      'bookmark': 'बुकमार्क',
      'bookmarked': 'बुकमार्क किया',
      'describe_problem': 'अपनी समस्या बताएं',
      'chat_greeting': 'बताएं क्या हुआ। आप सरल शब्दों में लिख सकते हैं।',
      'chat_unclear': 'मैं समस्या को स्पष्ट रूप से समझ नहीं पाया।',
      'chat_choose_from_list': 'सूची से चुनें',
      'chat_try_rephrase': 'दोबारा बताएं',
      'chat_detected': 'यह इससे संबंधित लगता है: {issue}',
      'chat_yes_correct': 'हाँ, यह सही है',
      'chat_no_different': 'नहीं, दूसरा विषय चुनें',
      'chat_error': 'कुछ गलत हो गया। आप समस्या को सूची से चुन सकते हैं।',
      'chat_rephrase_prompt': 'कोई बात नहीं। अलग शब्दों में बताएं क्या हुआ।',
      'chat_input_hint': 'बताएं क्या हुआ...',
      'chat_title': 'अपनी समस्या बताएं',
    },
  };

  /// Returns the localized string for [key] in [locale].
  /// Falls back to English if the key isn't found in the requested locale.
  static String get(String locale, String key) {
    return _strings[locale]?[key] ?? _strings['en']?[key] ?? key;
  }

  /// Convenience: returns [get] with placeholder replacement.
  static String getFormatted(
    String locale,
    String key,
    Map<String, String> params,
  ) {
    var result = get(locale, key);
    params.forEach((placeholder, value) {
      result = result.replaceAll('{$placeholder}', value);
    });
    return result;
  }
}
