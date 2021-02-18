class Settings {
  final int id;
  final String aboutUs;
  final String privacyPolicy;
  final String termsAndConditions;
  final String faq;
  final String contactUs;

  Settings({
    this.id,
    this.privacyPolicy,
    this.termsAndConditions,
    this.aboutUs,
    this.faq,
    this.contactUs,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'],
      privacyPolicy: json['privacy_policy'],
      termsAndConditions: json['terms_and_conditions'],
      aboutUs: json['about_us'],
      faq: json['faq'],
      contactUs: json['contact_us'],
    );
  }
}
