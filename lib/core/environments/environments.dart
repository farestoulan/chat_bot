sealed class Environment {
  const Environment(this.name);

  final String name;

  String get baseUrl;
}

final class DevelopmentEnvironment extends Environment {
  const DevelopmentEnvironment() : super('development');

  @override
  String get baseUrl =>
      'https://by4snzvvns5rnyvs3eoemt7neu0amywq.lambda-url.us-east-1.on.aws/api';
}
