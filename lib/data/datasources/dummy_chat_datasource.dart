/// Data source for dummy chat responses with intelligent understanding
class DummyChatDatasource {
  /// Gets an appropriate response based on the user's message
  String getResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();
    final normalizedMessage = _normalizeArabic(message);

    // Questions about name - check first before other checks
    final normalizedMsg = _normalizeArabic(message);
    if (_containsAny(normalizedMsg, [
          'اسمك',
          'من انت',
          'من أنت',
          'what is your name',
          'who are you',
          'ما اسمك',
        ]) ||
        (normalizedMsg.contains('من') && normalizedMsg.length < 10)) {
      return _getRandomResponse([
        'أنا ChatBot Assistant، مساعدك الذكي! 🤖',
        'I\'m ChatBot Assistant, your AI helper!',
        'اسمي ChatBot Assistant، كيف يمكنني مساعدتك؟',
        'أنا مساعدك الذكي ChatBot Assistant. أنا هنا لمساعدتك في أي شيء تحتاجه!',
      ]);
    }

    // Questions about name - check first before other checks
    if (_containsAny(normalizedMessage, [
          'اسمك',
          'من انت',
          'من أنت',
          'what is your name',
          'who are you',
          'ما اسمك',
        ]) ||
        (normalizedMessage.contains('من') && normalizedMessage.length < 10)) {
      return _getRandomResponse([
        'أنا ChatBot Assistant، مساعدك الذكي! 🤖',
        'I\'m ChatBot Assistant, your AI helper!',
        'اسمي ChatBot Assistant، كيف يمكنني مساعدتك؟',
        'أنا مساعدك الذكي ChatBot Assistant. أنا هنا لمساعدتك في أي شيء تحتاجه!',
      ]);
    }

    // Greetings
    if (_containsAny(normalizedMessage, [
      'مرحبا',
      'hello',
      'hi',
      'hey',
      'السلام',
      'صباح',
      'مساء',
      'good morning',
      'good evening',
    ])) {
      return _getRandomResponse([
        'مرحباً! 👋 كيف يمكنني مساعدتك اليوم؟',
        'Hello! How can I help you today?',
        'أهلاً وسهلاً! أنا هنا لمساعدتك.',
        'Hi there! What can I do for you?',
      ]);
    }

    // Questions about help
    if (_containsAny(normalizedMessage, [
      'مساعدة',
      'help',
      'ساعدني',
      'ماذا يمكنك',
      'what can you do',
      'help me',
    ])) {
      return _getRandomResponse([
        'يمكنني مساعدتك في الإجابة على أسئلتك وتقديم المعلومات. ما الذي تريد معرفته؟',
        'I can help you answer questions and provide information. What would you like to know?',
        'أنا هنا للإجابة على أسئلتك. اسألني أي شيء!',
      ]);
    }

    // Questions about time/date
    if (_containsAny(normalizedMessage, [
      'الوقت',
      'الساعة',
      'what time',
      'what date',
      'التاريخ',
      'time',
      'date',
    ])) {
      final now = DateTime.now();
      return 'الوقت الحالي هو ${now.hour}:${now.minute.toString().padLeft(2, '0')} والتاريخ هو ${now.day}/${now.month}/${now.year}';
    }

    // Questions about weather
    if (_containsAny(normalizedMessage, [
      'الطقس',
      'weather',
      'الجو',
      'درجة الحرارة',
      'temperature',
    ])) {
      return _getRandomResponse([
        'الطقس اليوم جميل ومناسب للخروج! ☀️',
        'The weather today is nice and suitable for going out!',
        'درجة الحرارة معتدلة والجو لطيف.',
      ]);
    }

    // Questions about programming/code
    if (_containsAny(normalizedMessage, [
      'برمجة',
      'كود',
      'code',
      'programming',
      'flutter',
      'dart',
      'كيف أبرمج',
    ])) {
      return _getRandomResponse([
        'يمكنني مساعدتك في البرمجة! Flutter و Dart من التقنيات الرائعة لتطوير التطبيقات.',
        'I can help you with programming! Flutter and Dart are great technologies for app development.',
        'البرمجة ممتعة! ما اللغة التي تريد التعلم عنها؟',
      ]);
    }

    // Questions about thanks
    if (_containsAny(normalizedMessage, [
      'شكرا',
      'thank you',
      'thanks',
      'مشكور',
      'متشكر',
    ])) {
      return _getRandomResponse([
        'العفو! 😊 سعيد بمساعدتك. هل لديك أي أسئلة أخرى؟',
        'You\'re welcome! Happy to help. Any other questions?',
        'لا شكر على واجب! أنا هنا دائماً لمساعدتك.',
      ]);
    }

    // Questions about goodbye
    if (_containsAny(normalizedMessage, [
      'وداعا',
      'bye',
      'goodbye',
      'مع السلامة',
      'see you',
    ])) {
      return _getRandomResponse([
        'مع السلامة! 👋 أتمنى أن أكون قد ساعدتك.',
        'Goodbye! Hope I was helpful.',
        'إلى اللقاء! أتمنى لك يوماً رائعاً.',
      ]);
    }

    // Questions about how are you
    if (_containsAny(normalizedMessage, [
      'كيف حالك',
      'how are you',
      'كيفك',
      'what\'s up',
    ])) {
      return _getRandomResponse([
        'أنا بخير، شكراً لسؤالك! 😊 كيف حالك أنت؟',
        'I\'m doing great, thanks for asking! How are you?',
        'كل شيء على ما يرام! كيف يمكنني مساعدتك اليوم؟',
      ]);
    }

    // Questions about age
    if (_containsAny(normalizedMessage, [
      'عمرك',
      'how old',
      'كم عمرك',
      'age',
    ])) {
      return _getRandomResponse([
        'أنا برنامج ذكي، لا أملك عمراً بالمعنى التقليدي! 😄',
        'I\'m an AI, I don\'t have an age in the traditional sense!',
        'أنا مساعد ذكي حديث، أساعد الناس كل يوم!',
      ]);
    }

    // Default response for other questions
    return _getDefaultResponse(normalizedMessage);
  }

  /// Gets a random response from a list
  String _getRandomResponse(List<String> responses) {
    final index = DateTime.now().millisecond % responses.length;
    return responses[index];
  }

  /// Default responses for general questions
  String _getDefaultResponse(String message) {
    // Check if it's a question
    final isQuestion =
        message.contains('?') ||
        message.contains('؟') ||
        message.startsWith('ما') ||
        message.startsWith('ماذا') ||
        message.startsWith('كيف') ||
        message.startsWith('لماذا') ||
        message.startsWith('أين') ||
        message.startsWith('متى') ||
        message.startsWith('who') ||
        message.startsWith('what') ||
        message.startsWith('how') ||
        message.startsWith('why') ||
        message.startsWith('where') ||
        message.startsWith('when');

    if (isQuestion) {
      return _getRandomResponse([
        'هذا سؤال مثير للاهتمام! دعني أفكر... يمكنني مساعدتك في ذلك.',
        'That\'s an interesting question! Let me think... I can help with that.',
        'فهمت سؤالك. إليك ما أعتقده...',
        'I understand your question. Here\'s what I think...',
        'سؤال جيد! دعني أشرح لك...',
        'Good question! Let me explain...',
      ]);
    }

    // For statements
    return _getRandomResponse([
      'فهمت ما تقصده. هل تريد معرفة المزيد عن هذا الموضوع؟',
      'I understand what you mean. Would you like to know more about this?',
      'ممتاز! هل لديك أي أسئلة أخرى؟',
      'Great! Do you have any other questions?',
      'شكراً لمشاركتك هذا. كيف يمكنني مساعدتك أكثر؟',
      'Thanks for sharing that. How can I help you further?',
    ]);
  }

  /// Checks if message contains any of the given keywords
  bool _containsAny(String message, List<String> keywords) {
    // Normalize Arabic text (remove diacritics and normalize variations)
    final normalizedMessage = _normalizeArabic(message);
    return keywords.any((keyword) {
      final normalizedKeyword = _normalizeArabic(keyword);
      return normalizedMessage.contains(normalizedKeyword);
    });
  }

  /// Normalizes Arabic text to handle variations (أ/ا, ي/ى, etc.)
  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('؟', '?')
        .trim();
  }

  /// Gets all available response patterns (for testing)
  List<String> getAvailablePatterns() {
    return [
      'Greetings',
      'Name questions',
      'Help requests',
      'Time/Date questions',
      'Weather questions',
      'Programming questions',
      'Thanks',
      'Goodbye',
      'How are you',
      'Age questions',
      'General questions',
    ];
  }
}
