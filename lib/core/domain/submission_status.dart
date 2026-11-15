/// Where a form is in its save cycle. `success` is set only after the
/// database commit has returned.
enum SubmissionStatus {
  idle,
  submitting,
  success,
  failure;

  bool get isSubmitting => this == SubmissionStatus.submitting;
}

/// Where a screen is in loading its data.
enum LoadStatus { loading, loaded, failure }
