abstract class DatabaseService<T> {
  Future<void> initialize();
  T get client;
  Future<void> close();
}
