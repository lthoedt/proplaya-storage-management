class Cacher<T> {
  T? _value;

  Cacher(T? value) {
    _value = value;
  }

  Future<T?>? get(
    Future<T?>? Function() fn, {
    bool force = false,
  }) {
    if (this._value != null && !force) {
      return Future.value(this._value);
    }

    final Future<T?>? value = fn();

    if (value == null) return null;

    return () async {
      this._value = await value;
      return this._value;
    }();
  }

  T? get value => _value;
}
