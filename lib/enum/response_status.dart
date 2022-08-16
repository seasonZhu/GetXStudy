enum SuccessStatus { empty, hasContent }

extension SuccessValue on SuccessStatus {
  get value {
    switch (this) {
      case SuccessStatus.hasContent:
        return 2;
      case SuccessStatus.empty:
        return 3;
    }
  }
}

enum ResponseStatus { successHasContent, successNoData, loading, fail }

extension Value on ResponseStatus {
  get value {
    switch (this) {
      case ResponseStatus.successHasContent:
        return 2;
      case ResponseStatus.successNoData:
        return 3;
      case ResponseStatus.loading:
        return 0;
      case ResponseStatus.fail:
        return 1;
    }
  }
}

/// 这是例子
enum Water {
  frozen(0),
  lukewarm(40),
  boiling(100);

  final int temperature;
  const Water(this.temperature);

  @override
  String toString() => 'The $name water is $temperature';
}

/// 有关于枚举里面加泛型
enum Season<T extends Object> {
  spring("好"),
  summer(true),
  autumn(100),
  winter([]);

  final T temperature;
  const Season(this.temperature);
}

final s = Season.spring.temperature;
