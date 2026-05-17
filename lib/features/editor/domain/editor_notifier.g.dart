// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'98a09c6cfd43966155dfbdb0787fa18c85438e13';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$templateRepositoryHash() =>
    r'449d1e2cdeeee672dfc3e30f734d4ae2e95bfbc0';

/// See also [templateRepository].
@ProviderFor(templateRepository)
final templateRepositoryProvider = Provider<TemplateRepository>.internal(
  templateRepository,
  name: r'templateRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$templateRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TemplateRepositoryRef = ProviderRef<TemplateRepository>;
String _$templatesHash() => r'c446f888683b6e9c508ea720611a0270bb69a29d';

/// See also [templates].
@ProviderFor(templates)
final templatesProvider =
    AutoDisposeFutureProvider<List<NotebookTemplate>>.internal(
      templates,
      name: r'templatesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$templatesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TemplatesRef = AutoDisposeFutureProviderRef<List<NotebookTemplate>>;
String _$editorNotifierHash() => r'545e4403b8dd85b65d2858ff8d6ca19b2e84cb22';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$EditorNotifier
    extends BuildlessAutoDisposeNotifier<EditorState> {
  late final ({
    List<
      ({
        String? colorHex,
        LayerConfig config,
        double heightRatio,
        double yRatio,
      })
    >?
    presets,
    String? uuid,
  })
  param;

  EditorState build(
    ({
      List<
        ({
          String? colorHex,
          LayerConfig config,
          double heightRatio,
          double yRatio,
        })
      >?
      presets,
      String? uuid,
    })
    param,
  );
}

/// See also [EditorNotifier].
@ProviderFor(EditorNotifier)
const editorNotifierProvider = EditorNotifierFamily();

/// See also [EditorNotifier].
class EditorNotifierFamily extends Family<EditorState> {
  /// See also [EditorNotifier].
  const EditorNotifierFamily();

  /// See also [EditorNotifier].
  EditorNotifierProvider call(
    ({
      List<
        ({
          String? colorHex,
          LayerConfig config,
          double heightRatio,
          double yRatio,
        })
      >?
      presets,
      String? uuid,
    })
    param,
  ) {
    return EditorNotifierProvider(param);
  }

  @override
  EditorNotifierProvider getProviderOverride(
    covariant EditorNotifierProvider provider,
  ) {
    return call(provider.param);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'editorNotifierProvider';
}

/// See also [EditorNotifier].
class EditorNotifierProvider
    extends AutoDisposeNotifierProviderImpl<EditorNotifier, EditorState> {
  /// See also [EditorNotifier].
  EditorNotifierProvider(
    ({
      List<
        ({
          String? colorHex,
          LayerConfig config,
          double heightRatio,
          double yRatio,
        })
      >?
      presets,
      String? uuid,
    })
    param,
  ) : this._internal(
        () => EditorNotifier()..param = param,
        from: editorNotifierProvider,
        name: r'editorNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$editorNotifierHash,
        dependencies: EditorNotifierFamily._dependencies,
        allTransitiveDependencies:
            EditorNotifierFamily._allTransitiveDependencies,
        param: param,
      );

  EditorNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.param,
  }) : super.internal();

  final ({
    List<
      ({
        String? colorHex,
        LayerConfig config,
        double heightRatio,
        double yRatio,
      })
    >?
    presets,
    String? uuid,
  })
  param;

  @override
  EditorState runNotifierBuild(covariant EditorNotifier notifier) {
    return notifier.build(param);
  }

  @override
  Override overrideWith(EditorNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditorNotifierProvider._internal(
        () => create()..param = param,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        param: param,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EditorNotifier, EditorState>
  createElement() {
    return _EditorNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditorNotifierProvider && other.param == param;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, param.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditorNotifierRef on AutoDisposeNotifierProviderRef<EditorState> {
  /// The parameter `param` of this provider.
  ({
    List<
      ({
        String? colorHex,
        LayerConfig config,
        double heightRatio,
        double yRatio,
      })
    >?
    presets,
    String? uuid,
  })
  get param;
}

class _EditorNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<EditorNotifier, EditorState>
    with EditorNotifierRef {
  _EditorNotifierProviderElement(super.provider);

  @override
  ({
    List<
      ({
        String? colorHex,
        LayerConfig config,
        double heightRatio,
        double yRatio,
      })
    >?
    presets,
    String? uuid,
  })
  get param => (origin as EditorNotifierProvider).param;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
