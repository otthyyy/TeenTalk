enum ReportReason {
  spam('spam', 'Spam or misleading'),
  harassment('harassment', 'Harassment or bullying'),
  hateSpeech('hate_speech', 'Hate speech'),
  violence('violence', 'Violence or dangerous content'),
  sexualContent('sexual_content', 'Sexual content'),
  misinformation('misinformation', 'Misinformation'),
  selfHarm('self_harm', 'Self-harm or suicide'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const ReportReason(this.value, this.displayName);

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => ReportReason.other,
    );
  }
}
