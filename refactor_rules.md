# Refactor + Unit Test + Widget Extraction Guide
## 1. قاعدة الـ 100 سطر

```
if (file.lines > 100) → فصّل
```

| نوع الملف | بيتفصل إزاي |
|---|---|
| Cubit | cubit في ملف / state في ملف |
| Repository impl | كل method group في extension |
| Page | كل section → widget منفصل |
| Widget كبير | sub-widgets في `widgets/` folder |

---

## 2. هيكل الـ Unit Tests

```
test/
└── features/
    └── feature/
        ├── data/
        │   ├── datasources/  feature_datasource_test.dart
        │   └── repositories/ feature_repository_test.dart
        ├── domain/
        │   └── usecases/     feature_usecases_test.dart
        └── presentation/
            └── cubit/        feature_cubit_test.dart
```

> الكود الكامل للتيستات → **[`feature_tests.dart`](./feature_tests.dart)**

---

## 3. هيكل الـ Widgets بعد الفصل

```
presentation/
├── cubit/
│   ├── feature_cubit.dart
│   └── feature_state.dart        ← اتفصل من الـ cubit
├── pages/
│   └── feature_page.dart         ← بس بيعمل BlocBuilder + scaffold
└── widgets/
    ├── feature_list.dart          ← اللي بيعرض الـ list
    ├── feature_list_item.dart     ← الـ item الواحد
    ├── feature_empty_state.dart   ← لما مفيش data
    ├── feature_error_widget.dart  ← لما يحصل error
    └── feature_form.dart          ← form الـ create/edit
```

---

## 4. قاعدة فصل الـ Widgets

```dart
// ✅ الـ page بس بتنظم — مفيش منطق جوّاها
class FeaturePage extends StatelessWidget {
  Widget build(context) => BlocBuilder<FeatureCubit, FeatureState>(
    builder: (_, state) => Scaffold(
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const CircularProgressIndicator(),
        loaded:  (items) => FeatureList(items: items),   // widgets/feature_list.dart
        error:   (msg)   => FeatureErrorWidget(msg),     // widgets/feature_error_widget.dart
      ),
      floatingActionButton: const FeatureForm(),         // widgets/feature_form.dart
    ),
  );
}
```

> `feature_state.dart` بيتفصل من `feature_cubit.dart` بـ `part of`

---

## 5. Unit Test: ماذا نتيست؟

| Layer | بنتيست إيه | Tool |
|---|---|---|
| Datasource | بترجع الداتا صح من Supabase | `mocktail` |
| Repository | بتعمل map صح من model → entity | `mocktail` |
| Usecases | بتستدعي الـ repo وترجع الـ result | `mocktail` |
| Cubit | الـ states بتتبعت بالترتيب الصح | `bloc_test` |

> **التيست الكامل في [`feature_tests.dart`](./feature_tests.dart)**

---

## 7. Checklist قبل ما تـ push

```
□ كل ملف < 100 سطر
□ كل widget في widgets/ folder ليها ملفها
□ feature_state.dart منفصل عن feature_cubit.dart
□ cubit tests: success + failure لكل operation
□ repository tests: Right و Left cases
□ mock بـ mocktail — مفيش real Supabase في التيستات
```

// test/features/feature/presentation/cubit/feature_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────
class MockGetAllFeaturesUsecase extends Mock implements GetAllFeaturesUsecase {}
class MockCreateFeatureUsecase  extends Mock implements CreateFeatureUsecase  {}
class MockUpdateFeatureUsecase  extends Mock implements UpdateFeatureUsecase  {}
class MockDeleteFeatureUsecase  extends Mock implements DeleteFeatureUsecase  {}
class MockFeatureRepository     extends Mock implements FeatureRepository     {}

// ─── Fake Entities ───────────────────────────────────────────────────────────
class FakeFeatureEntity extends Fake implements FeatureEntity {}

// ─── Helpers ─────────────────────────────────────────────────────────────────
final tEntity = FeatureEntity(id: '1', name: 'Test Feature');
final tList   = [tEntity];
const tFailure = ServerFailure('something went wrong');

// ─────────────────────────────────────────────────────────────────────────────
//  CUBIT TESTS
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockGetAllFeaturesUsecase mockGetAll;
  late MockCreateFeatureUsecase  mockCreate;
  late MockUpdateFeatureUsecase  mockUpdate;
  late MockDeleteFeatureUsecase  mockDelete;
  late FeatureCubit              cubit;

  setUpAll(() => registerFallbackValue(FakeFeatureEntity()));

  setUp(() {
    mockGetAll = MockGetAllFeaturesUsecase();
    mockCreate = MockCreateFeatureUsecase();
    mockUpdate = MockUpdateFeatureUsecase();
    mockDelete = MockDeleteFeatureUsecase();
    cubit = FeatureCubit(
      getAll: mockGetAll,
      create: mockCreate,
      update: mockUpdate,
      delete: mockDelete,
    );
  });

  tearDown(() => cubit.close());

  // ── loadAll ────────────────────────────────────────────────────────────────
  group('loadAll()', () {
    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => mockGetAll()).thenAnswer((_) async => Right(tList));
        return cubit;
      },
      act: (c) => c.loadAll(),
      expect: () => [
        const FeatureState.loading(),
        FeatureState.loaded(tList),
      ],
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockGetAll()).thenAnswer((_) async => const Left(tFailure));
        return cubit;
      },
      act: (c) => c.loadAll(),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.error('something went wrong'),
      ],
    );
  });

  // ── create ─────────────────────────────────────────────────────────────────
  group('create()', () {
    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, loaded] after successful create + refresh',
      build: () {
        when(() => mockCreate(any())).thenAnswer((_) async => Right(tEntity));
        when(() => mockGetAll()).thenAnswer((_) async => Right(tList));
        return cubit;
      },
      act: (c) => c.create(tEntity),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.loading(), // من الـ loadAll
        FeatureState.loaded(tList),
      ],
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, error] on create failure',
      build: () {
        when(() => mockCreate(any()))
            .thenAnswer((_) async => const Left(tFailure));
        return cubit;
      },
      act: (c) => c.create(tEntity),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.error('something went wrong'),
      ],
    );
  });

  // ── update ─────────────────────────────────────────────────────────────────
  group('update()', () {
    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, loaded] after successful update + refresh',
      build: () {
        when(() => mockUpdate(any())).thenAnswer((_) async => Right(tEntity));
        when(() => mockGetAll()).thenAnswer((_) async => Right(tList));
        return cubit;
      },
      act: (c) => c.update(tEntity),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.loading(),
        FeatureState.loaded(tList),
      ],
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, error] on update failure',
      build: () {
        when(() => mockUpdate(any()))
            .thenAnswer((_) async => const Left(tFailure));
        return cubit;
      },
      act: (c) => c.update(tEntity),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.error('something went wrong'),
      ],
    );
  });

  // ── delete ─────────────────────────────────────────────────────────────────
  group('delete()', () {
    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, loaded] after successful delete + refresh',
      build: () {
        when(() => mockDelete(any())).thenAnswer((_) async => const Right(unit));
        when(() => mockGetAll()).thenAnswer((_) async => Right(tList));
        return cubit;
      },
      act: (c) => c.delete('1'),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.loading(),
        FeatureState.loaded(tList),
      ],
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [loading, error] on delete failure',
      build: () {
        when(() => mockDelete(any()))
            .thenAnswer((_) async => const Left(tFailure));
        return cubit;
      },
      act: (c) => c.delete('1'),
      expect: () => [
        const FeatureState.loading(),
        const FeatureState.error('something went wrong'),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  //  REPOSITORY TESTS  →  test/features/feature/data/repositories/
  // ─────────────────────────────────────────────────────────────────────────
  group('FeatureRepositoryImpl', () {
    late MockFeatureRemoteDatasource mockDatasource;
    late FeatureRepositoryImpl       repo;

    setUp(() {
      mockDatasource = MockFeatureRemoteDatasource();
      repo = FeatureRepositoryImpl(remote: mockDatasource);
    });

    test('getAll returns Right(list) on success', () async {
      when(() => mockDatasource.getAll())
          .thenAnswer((_) async => [FeatureModel.fromEntity(tEntity)]);
      final result = await repo.getAll();
      expect(result, Right(tList));
    });

    test('getAll returns Left(ServerFailure) on exception', () async {
      when(() => mockDatasource.getAll())
          .thenThrow(ServerException('error'));
      final result = await repo.getAll();
      expect(result, const Left(ServerFailure('error')));
    });

    test('create returns Right(entity) on success', () async {
      when(() => mockDatasource.create(any()))
          .thenAnswer((_) async => FeatureModel.fromEntity(tEntity));
      final result = await repo.create(tEntity);
      expect(result, Right(tEntity));
    });

    test('delete returns Right(unit) on success', () async {
      when(() => mockDatasource.delete(any())).thenAnswer((_) async {});
      final result = await repo.delete('1');
      expect(result, const Right(unit));
    });
  });
}


