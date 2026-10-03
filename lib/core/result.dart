sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get dataOrNull => this is Ok<T> ? (this as Ok<T>).data : null;
  String? get errorOrNull => this is Err<T> ? (this as Err<T>).message : null;

  R when<R>({
    required R Function(T data) ok,
    required R Function(String message) err,
  }) {
    final self = this;
    if (self is Ok<T>) return ok(self.data);
    return err((self as Err<T>).message);
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;
}

class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}
