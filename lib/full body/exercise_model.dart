class ExerciseModel {
  final String name;
  final String filePath;
  final String time; // e.g., "00:30" or "16 reps"
  final bool isAnimation; // true = image, false = Lottie

  ExerciseModel({
    required this.name,
    required this.filePath,
    required this.time,
    required this.isAnimation,
  });

  /// Convert "00:30" -> 30 seconds, or return 0 if it's reps-based
  int get durationInSeconds {
    try {
      if (time.toLowerCase().contains("reps")) return 0;
      final parts = time.split(':');
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60) + seconds;
    } catch (e) {
      return 0;
    }
  }
}
