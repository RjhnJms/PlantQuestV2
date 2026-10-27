// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Explorer'),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _avatarIdMeta = const VerificationMeta('avatarId');
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
    'avatar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('boy_cap'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta('onboarded');
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("onboarded" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _soundOnMeta = const VerificationMeta('soundOn');
  @override
  late final GeneratedColumn<bool> soundOn = GeneratedColumn<bool>(
    'sound_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("sound_on" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoReadMeta = const VerificationMeta('autoRead');
  @override
  late final GeneratedColumn<bool> autoRead = GeneratedColumn<bool>(
    'auto_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("auto_read" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _speechRateMeta = const VerificationMeta('speechRate');
  @override
  late final GeneratedColumn<String> speechRate = GeneratedColumn<String>(
    'speech_rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _voiceIdMeta = const VerificationMeta('voiceId');
  @override
  late final GeneratedColumn<String> voiceId = GeneratedColumn<String>(
    'voice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceStyleMeta = const VerificationMeta('voiceStyle');
  @override
  late final GeneratedColumn<String> voiceStyle = GeneratedColumn<String>(
    'voice_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cheerful'),
  );
  static const VerificationMeta _lessMotionMeta = const VerificationMeta('lessMotion');
  @override
  late final GeneratedColumn<bool> lessMotion = GeneratedColumn<bool>(
    'less_motion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("less_motion" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _musicOnMeta = const VerificationMeta('musicOn');
  @override
  late final GeneratedColumn<bool> musicOn = GeneratedColumn<bool>(
    'music_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("music_on" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _wearSalakotMeta = const VerificationMeta('wearSalakot');
  @override
  late final GeneratedColumn<bool> wearSalakot = GeneratedColumn<bool>(
    'wear_salakot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("wear_salakot" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wearGarlandMeta = const VerificationMeta('wearGarland');
  @override
  late final GeneratedColumn<bool> wearGarland = GeneratedColumn<bool>(
    'wear_garland',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("wear_garland" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wearSunglassesMeta = const VerificationMeta('wearSunglasses');
  @override
  late final GeneratedColumn<bool> wearSunglasses = GeneratedColumn<bool>(
    'wear_sunglasses',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("wear_sunglasses" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _potPatternMeta = const VerificationMeta('potPattern');
  @override
  late final GeneratedColumn<String> potPattern = GeneratedColumn<String>(
    'pot_pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('plain'),
  );
  static const VerificationMeta _hatMeta = const VerificationMeta('hat');
  @override
  late final GeneratedColumn<String> hat = GeneratedColumn<String>(
    'hat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _glassesMeta = const VerificationMeta('glasses');
  @override
  late final GeneratedColumn<String> glasses = GeneratedColumn<String>(
    'glasses',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neckMeta = const VerificationMeta('neck');
  @override
  late final GeneratedColumn<String> neck = GeneratedColumn<String>(
    'neck',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _friendMeta = const VerificationMeta('friend');
  @override
  late final GeneratedColumn<String> friend = GeneratedColumn<String>(
    'friend',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spotMeta = const VerificationMeta('spot');
  @override
  late final GeneratedColumn<String> spot = GeneratedColumn<String>(
    'spot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    grade,
    avatarId,
    joinedAt,
    onboarded,
    soundOn,
    autoRead,
    speechRate,
    voiceId,
    voiceStyle,
    lessMotion,
    musicOn,
    wearSalakot,
    wearGarland,
    wearSunglasses,
    potPattern,
    hat,
    glasses,
    neck,
    friend,
    spot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(_gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('avatar_id')) {
      context.handle(_avatarIdMeta, avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta, joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('onboarded')) {
      context.handle(_onboardedMeta, onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta));
    }
    if (data.containsKey('sound_on')) {
      context.handle(_soundOnMeta, soundOn.isAcceptableOrUnknown(data['sound_on']!, _soundOnMeta));
    }
    if (data.containsKey('auto_read')) {
      context.handle(_autoReadMeta, autoRead.isAcceptableOrUnknown(data['auto_read']!, _autoReadMeta));
    }
    if (data.containsKey('speech_rate')) {
      context.handle(_speechRateMeta, speechRate.isAcceptableOrUnknown(data['speech_rate']!, _speechRateMeta));
    }
    if (data.containsKey('voice_id')) {
      context.handle(_voiceIdMeta, voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta));
    }
    if (data.containsKey('voice_style')) {
      context.handle(_voiceStyleMeta, voiceStyle.isAcceptableOrUnknown(data['voice_style']!, _voiceStyleMeta));
    }
    if (data.containsKey('less_motion')) {
      context.handle(_lessMotionMeta, lessMotion.isAcceptableOrUnknown(data['less_motion']!, _lessMotionMeta));
    }
    if (data.containsKey('music_on')) {
      context.handle(_musicOnMeta, musicOn.isAcceptableOrUnknown(data['music_on']!, _musicOnMeta));
    }
    if (data.containsKey('wear_salakot')) {
      context.handle(_wearSalakotMeta, wearSalakot.isAcceptableOrUnknown(data['wear_salakot']!, _wearSalakotMeta));
    }
    if (data.containsKey('wear_garland')) {
      context.handle(_wearGarlandMeta, wearGarland.isAcceptableOrUnknown(data['wear_garland']!, _wearGarlandMeta));
    }
    if (data.containsKey('wear_sunglasses')) {
      context.handle(
        _wearSunglassesMeta,
        wearSunglasses.isAcceptableOrUnknown(data['wear_sunglasses']!, _wearSunglassesMeta),
      );
    }
    if (data.containsKey('pot_pattern')) {
      context.handle(_potPatternMeta, potPattern.isAcceptableOrUnknown(data['pot_pattern']!, _potPatternMeta));
    }
    if (data.containsKey('hat')) {
      context.handle(_hatMeta, hat.isAcceptableOrUnknown(data['hat']!, _hatMeta));
    }
    if (data.containsKey('glasses')) {
      context.handle(_glassesMeta, glasses.isAcceptableOrUnknown(data['glasses']!, _glassesMeta));
    }
    if (data.containsKey('neck')) {
      context.handle(_neckMeta, neck.isAcceptableOrUnknown(data['neck']!, _neckMeta));
    }
    if (data.containsKey('friend')) {
      context.handle(_friendMeta, friend.isAcceptableOrUnknown(data['friend']!, _friendMeta));
    }
    if (data.containsKey('spot')) {
      context.handle(_spotMeta, spot.isAcceptableOrUnknown(data['spot']!, _spotMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      grade: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}grade'])!,
      avatarId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}avatar_id'])!,
      joinedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
      onboarded: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}onboarded'])!,
      soundOn: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}sound_on'])!,
      autoRead: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}auto_read'])!,
      speechRate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}speech_rate'])!,
      voiceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}voice_id']),
      voiceStyle: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}voice_style'])!,
      lessMotion: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}less_motion'])!,
      musicOn: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}music_on'])!,
      wearSalakot: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}wear_salakot'])!,
      wearGarland: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}wear_garland'])!,
      wearSunglasses: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}wear_sunglasses'])!,
      potPattern: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pot_pattern'])!,
      hat: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hat']),
      glasses: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}glasses']),
      neck: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}neck']),
      friend: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}friend']),
      spot: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}spot']),
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String name;
  final int grade;
  final String avatarId;
  final DateTime joinedAt;
  final bool onboarded;
  final bool soundOn;
  final bool autoRead;

  /// 'slow' or 'normal'.
  final String speechRate;

  /// An offline voice name, or null for Automatic.
  final String? voiceId;

  /// 'cheerful', 'normal' or 'calm'.
  final String voiceStyle;
  final bool lessMotion;

  /// Background music (v4). Separate from sound effects.
  final bool musicOn;
  final bool wearSalakot;
  final bool wearGarland;
  final bool wearSunglasses;

  /// A PotPattern name, e.g. 'plain', 'stripes' or 'jeepney'.
  final String potPattern;
  final String? hat;
  final String? glasses;
  final String? neck;
  final String? friend;
  final String? spot;
  const ProfileRow({
    required this.id,
    required this.name,
    required this.grade,
    required this.avatarId,
    required this.joinedAt,
    required this.onboarded,
    required this.soundOn,
    required this.autoRead,
    required this.speechRate,
    this.voiceId,
    required this.voiceStyle,
    required this.lessMotion,
    required this.musicOn,
    required this.wearSalakot,
    required this.wearGarland,
    required this.wearSunglasses,
    required this.potPattern,
    this.hat,
    this.glasses,
    this.neck,
    this.friend,
    this.spot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['grade'] = Variable<int>(grade);
    map['avatar_id'] = Variable<String>(avatarId);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    map['onboarded'] = Variable<bool>(onboarded);
    map['sound_on'] = Variable<bool>(soundOn);
    map['auto_read'] = Variable<bool>(autoRead);
    map['speech_rate'] = Variable<String>(speechRate);
    if (!nullToAbsent || voiceId != null) {
      map['voice_id'] = Variable<String>(voiceId);
    }
    map['voice_style'] = Variable<String>(voiceStyle);
    map['less_motion'] = Variable<bool>(lessMotion);
    map['music_on'] = Variable<bool>(musicOn);
    map['wear_salakot'] = Variable<bool>(wearSalakot);
    map['wear_garland'] = Variable<bool>(wearGarland);
    map['wear_sunglasses'] = Variable<bool>(wearSunglasses);
    map['pot_pattern'] = Variable<String>(potPattern);
    if (!nullToAbsent || hat != null) {
      map['hat'] = Variable<String>(hat);
    }
    if (!nullToAbsent || glasses != null) {
      map['glasses'] = Variable<String>(glasses);
    }
    if (!nullToAbsent || neck != null) {
      map['neck'] = Variable<String>(neck);
    }
    if (!nullToAbsent || friend != null) {
      map['friend'] = Variable<String>(friend);
    }
    if (!nullToAbsent || spot != null) {
      map['spot'] = Variable<String>(spot);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      name: Value(name),
      grade: Value(grade),
      avatarId: Value(avatarId),
      joinedAt: Value(joinedAt),
      onboarded: Value(onboarded),
      soundOn: Value(soundOn),
      autoRead: Value(autoRead),
      speechRate: Value(speechRate),
      voiceId: voiceId == null && nullToAbsent ? const Value.absent() : Value(voiceId),
      voiceStyle: Value(voiceStyle),
      lessMotion: Value(lessMotion),
      musicOn: Value(musicOn),
      wearSalakot: Value(wearSalakot),
      wearGarland: Value(wearGarland),
      wearSunglasses: Value(wearSunglasses),
      potPattern: Value(potPattern),
      hat: hat == null && nullToAbsent ? const Value.absent() : Value(hat),
      glasses: glasses == null && nullToAbsent ? const Value.absent() : Value(glasses),
      neck: neck == null && nullToAbsent ? const Value.absent() : Value(neck),
      friend: friend == null && nullToAbsent ? const Value.absent() : Value(friend),
      spot: spot == null && nullToAbsent ? const Value.absent() : Value(spot),
    );
  }

  factory ProfileRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      grade: serializer.fromJson<int>(json['grade']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      soundOn: serializer.fromJson<bool>(json['soundOn']),
      autoRead: serializer.fromJson<bool>(json['autoRead']),
      speechRate: serializer.fromJson<String>(json['speechRate']),
      voiceId: serializer.fromJson<String?>(json['voiceId']),
      voiceStyle: serializer.fromJson<String>(json['voiceStyle']),
      lessMotion: serializer.fromJson<bool>(json['lessMotion']),
      musicOn: serializer.fromJson<bool>(json['musicOn']),
      wearSalakot: serializer.fromJson<bool>(json['wearSalakot']),
      wearGarland: serializer.fromJson<bool>(json['wearGarland']),
      wearSunglasses: serializer.fromJson<bool>(json['wearSunglasses']),
      potPattern: serializer.fromJson<String>(json['potPattern']),
      hat: serializer.fromJson<String?>(json['hat']),
      glasses: serializer.fromJson<String?>(json['glasses']),
      neck: serializer.fromJson<String?>(json['neck']),
      friend: serializer.fromJson<String?>(json['friend']),
      spot: serializer.fromJson<String?>(json['spot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'grade': serializer.toJson<int>(grade),
      'avatarId': serializer.toJson<String>(avatarId),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'onboarded': serializer.toJson<bool>(onboarded),
      'soundOn': serializer.toJson<bool>(soundOn),
      'autoRead': serializer.toJson<bool>(autoRead),
      'speechRate': serializer.toJson<String>(speechRate),
      'voiceId': serializer.toJson<String?>(voiceId),
      'voiceStyle': serializer.toJson<String>(voiceStyle),
      'lessMotion': serializer.toJson<bool>(lessMotion),
      'musicOn': serializer.toJson<bool>(musicOn),
      'wearSalakot': serializer.toJson<bool>(wearSalakot),
      'wearGarland': serializer.toJson<bool>(wearGarland),
      'wearSunglasses': serializer.toJson<bool>(wearSunglasses),
      'potPattern': serializer.toJson<String>(potPattern),
      'hat': serializer.toJson<String?>(hat),
      'glasses': serializer.toJson<String?>(glasses),
      'neck': serializer.toJson<String?>(neck),
      'friend': serializer.toJson<String?>(friend),
      'spot': serializer.toJson<String?>(spot),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? name,
    int? grade,
    String? avatarId,
    DateTime? joinedAt,
    bool? onboarded,
    bool? soundOn,
    bool? autoRead,
    String? speechRate,
    Value<String?> voiceId = const Value.absent(),
    String? voiceStyle,
    bool? lessMotion,
    bool? musicOn,
    bool? wearSalakot,
    bool? wearGarland,
    bool? wearSunglasses,
    String? potPattern,
    Value<String?> hat = const Value.absent(),
    Value<String?> glasses = const Value.absent(),
    Value<String?> neck = const Value.absent(),
    Value<String?> friend = const Value.absent(),
    Value<String?> spot = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    grade: grade ?? this.grade,
    avatarId: avatarId ?? this.avatarId,
    joinedAt: joinedAt ?? this.joinedAt,
    onboarded: onboarded ?? this.onboarded,
    soundOn: soundOn ?? this.soundOn,
    autoRead: autoRead ?? this.autoRead,
    speechRate: speechRate ?? this.speechRate,
    voiceId: voiceId.present ? voiceId.value : this.voiceId,
    voiceStyle: voiceStyle ?? this.voiceStyle,
    lessMotion: lessMotion ?? this.lessMotion,
    musicOn: musicOn ?? this.musicOn,
    wearSalakot: wearSalakot ?? this.wearSalakot,
    wearGarland: wearGarland ?? this.wearGarland,
    wearSunglasses: wearSunglasses ?? this.wearSunglasses,
    potPattern: potPattern ?? this.potPattern,
    hat: hat.present ? hat.value : this.hat,
    glasses: glasses.present ? glasses.value : this.glasses,
    neck: neck.present ? neck.value : this.neck,
    friend: friend.present ? friend.value : this.friend,
    spot: spot.present ? spot.value : this.spot,
  );
  ProfileRow copyWithCompanion(ProfileCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      grade: data.grade.present ? data.grade.value : this.grade,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      soundOn: data.soundOn.present ? data.soundOn.value : this.soundOn,
      autoRead: data.autoRead.present ? data.autoRead.value : this.autoRead,
      speechRate: data.speechRate.present ? data.speechRate.value : this.speechRate,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      voiceStyle: data.voiceStyle.present ? data.voiceStyle.value : this.voiceStyle,
      lessMotion: data.lessMotion.present ? data.lessMotion.value : this.lessMotion,
      musicOn: data.musicOn.present ? data.musicOn.value : this.musicOn,
      wearSalakot: data.wearSalakot.present ? data.wearSalakot.value : this.wearSalakot,
      wearGarland: data.wearGarland.present ? data.wearGarland.value : this.wearGarland,
      wearSunglasses: data.wearSunglasses.present ? data.wearSunglasses.value : this.wearSunglasses,
      potPattern: data.potPattern.present ? data.potPattern.value : this.potPattern,
      hat: data.hat.present ? data.hat.value : this.hat,
      glasses: data.glasses.present ? data.glasses.value : this.glasses,
      neck: data.neck.present ? data.neck.value : this.neck,
      friend: data.friend.present ? data.friend.value : this.friend,
      spot: data.spot.present ? data.spot.value : this.spot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('avatarId: $avatarId, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('onboarded: $onboarded, ')
          ..write('soundOn: $soundOn, ')
          ..write('autoRead: $autoRead, ')
          ..write('speechRate: $speechRate, ')
          ..write('voiceId: $voiceId, ')
          ..write('voiceStyle: $voiceStyle, ')
          ..write('lessMotion: $lessMotion, ')
          ..write('musicOn: $musicOn, ')
          ..write('wearSalakot: $wearSalakot, ')
          ..write('wearGarland: $wearGarland, ')
          ..write('wearSunglasses: $wearSunglasses, ')
          ..write('potPattern: $potPattern, ')
          ..write('hat: $hat, ')
          ..write('glasses: $glasses, ')
          ..write('neck: $neck, ')
          ..write('friend: $friend, ')
          ..write('spot: $spot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    grade,
    avatarId,
    joinedAt,
    onboarded,
    soundOn,
    autoRead,
    speechRate,
    voiceId,
    voiceStyle,
    lessMotion,
    musicOn,
    wearSalakot,
    wearGarland,
    wearSunglasses,
    potPattern,
    hat,
    glasses,
    neck,
    friend,
    spot,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.grade == this.grade &&
          other.avatarId == this.avatarId &&
          other.joinedAt == this.joinedAt &&
          other.onboarded == this.onboarded &&
          other.soundOn == this.soundOn &&
          other.autoRead == this.autoRead &&
          other.speechRate == this.speechRate &&
          other.voiceId == this.voiceId &&
          other.voiceStyle == this.voiceStyle &&
          other.lessMotion == this.lessMotion &&
          other.musicOn == this.musicOn &&
          other.wearSalakot == this.wearSalakot &&
          other.wearGarland == this.wearGarland &&
          other.wearSunglasses == this.wearSunglasses &&
          other.potPattern == this.potPattern &&
          other.hat == this.hat &&
          other.glasses == this.glasses &&
          other.neck == this.neck &&
          other.friend == this.friend &&
          other.spot == this.spot);
}

class ProfileCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> grade;
  final Value<String> avatarId;
  final Value<DateTime> joinedAt;
  final Value<bool> onboarded;
  final Value<bool> soundOn;
  final Value<bool> autoRead;
  final Value<String> speechRate;
  final Value<String?> voiceId;
  final Value<String> voiceStyle;
  final Value<bool> lessMotion;
  final Value<bool> musicOn;
  final Value<bool> wearSalakot;
  final Value<bool> wearGarland;
  final Value<bool> wearSunglasses;
  final Value<String> potPattern;
  final Value<String?> hat;
  final Value<String?> glasses;
  final Value<String?> neck;
  final Value<String?> friend;
  final Value<String?> spot;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.grade = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.autoRead = const Value.absent(),
    this.speechRate = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.voiceStyle = const Value.absent(),
    this.lessMotion = const Value.absent(),
    this.musicOn = const Value.absent(),
    this.wearSalakot = const Value.absent(),
    this.wearGarland = const Value.absent(),
    this.wearSunglasses = const Value.absent(),
    this.potPattern = const Value.absent(),
    this.hat = const Value.absent(),
    this.glasses = const Value.absent(),
    this.neck = const Value.absent(),
    this.friend = const Value.absent(),
    this.spot = const Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.grade = const Value.absent(),
    this.avatarId = const Value.absent(),
    required DateTime joinedAt,
    this.onboarded = const Value.absent(),
    this.soundOn = const Value.absent(),
    this.autoRead = const Value.absent(),
    this.speechRate = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.voiceStyle = const Value.absent(),
    this.lessMotion = const Value.absent(),
    this.musicOn = const Value.absent(),
    this.wearSalakot = const Value.absent(),
    this.wearGarland = const Value.absent(),
    this.wearSunglasses = const Value.absent(),
    this.potPattern = const Value.absent(),
    this.hat = const Value.absent(),
    this.glasses = const Value.absent(),
    this.neck = const Value.absent(),
    this.friend = const Value.absent(),
    this.spot = const Value.absent(),
  }) : joinedAt = Value(joinedAt);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? grade,
    Expression<String>? avatarId,
    Expression<DateTime>? joinedAt,
    Expression<bool>? onboarded,
    Expression<bool>? soundOn,
    Expression<bool>? autoRead,
    Expression<String>? speechRate,
    Expression<String>? voiceId,
    Expression<String>? voiceStyle,
    Expression<bool>? lessMotion,
    Expression<bool>? musicOn,
    Expression<bool>? wearSalakot,
    Expression<bool>? wearGarland,
    Expression<bool>? wearSunglasses,
    Expression<String>? potPattern,
    Expression<String>? hat,
    Expression<String>? glasses,
    Expression<String>? neck,
    Expression<String>? friend,
    Expression<String>? spot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (grade != null) 'grade': grade,
      if (avatarId != null) 'avatar_id': avatarId,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (onboarded != null) 'onboarded': onboarded,
      if (soundOn != null) 'sound_on': soundOn,
      if (autoRead != null) 'auto_read': autoRead,
      if (speechRate != null) 'speech_rate': speechRate,
      if (voiceId != null) 'voice_id': voiceId,
      if (voiceStyle != null) 'voice_style': voiceStyle,
      if (lessMotion != null) 'less_motion': lessMotion,
      if (musicOn != null) 'music_on': musicOn,
      if (wearSalakot != null) 'wear_salakot': wearSalakot,
      if (wearGarland != null) 'wear_garland': wearGarland,
      if (wearSunglasses != null) 'wear_sunglasses': wearSunglasses,
      if (potPattern != null) 'pot_pattern': potPattern,
      if (hat != null) 'hat': hat,
      if (glasses != null) 'glasses': glasses,
      if (neck != null) 'neck': neck,
      if (friend != null) 'friend': friend,
      if (spot != null) 'spot': spot,
    });
  }

  ProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? grade,
    Value<String>? avatarId,
    Value<DateTime>? joinedAt,
    Value<bool>? onboarded,
    Value<bool>? soundOn,
    Value<bool>? autoRead,
    Value<String>? speechRate,
    Value<String?>? voiceId,
    Value<String>? voiceStyle,
    Value<bool>? lessMotion,
    Value<bool>? musicOn,
    Value<bool>? wearSalakot,
    Value<bool>? wearGarland,
    Value<bool>? wearSunglasses,
    Value<String>? potPattern,
    Value<String?>? hat,
    Value<String?>? glasses,
    Value<String?>? neck,
    Value<String?>? friend,
    Value<String?>? spot,
  }) {
    return ProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      avatarId: avatarId ?? this.avatarId,
      joinedAt: joinedAt ?? this.joinedAt,
      onboarded: onboarded ?? this.onboarded,
      soundOn: soundOn ?? this.soundOn,
      autoRead: autoRead ?? this.autoRead,
      speechRate: speechRate ?? this.speechRate,
      voiceId: voiceId ?? this.voiceId,
      voiceStyle: voiceStyle ?? this.voiceStyle,
      lessMotion: lessMotion ?? this.lessMotion,
      musicOn: musicOn ?? this.musicOn,
      wearSalakot: wearSalakot ?? this.wearSalakot,
      wearGarland: wearGarland ?? this.wearGarland,
      wearSunglasses: wearSunglasses ?? this.wearSunglasses,
      potPattern: potPattern ?? this.potPattern,
      hat: hat ?? this.hat,
      glasses: glasses ?? this.glasses,
      neck: neck ?? this.neck,
      friend: friend ?? this.friend,
      spot: spot ?? this.spot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (soundOn.present) {
      map['sound_on'] = Variable<bool>(soundOn.value);
    }
    if (autoRead.present) {
      map['auto_read'] = Variable<bool>(autoRead.value);
    }
    if (speechRate.present) {
      map['speech_rate'] = Variable<String>(speechRate.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<String>(voiceId.value);
    }
    if (voiceStyle.present) {
      map['voice_style'] = Variable<String>(voiceStyle.value);
    }
    if (lessMotion.present) {
      map['less_motion'] = Variable<bool>(lessMotion.value);
    }
    if (musicOn.present) {
      map['music_on'] = Variable<bool>(musicOn.value);
    }
    if (wearSalakot.present) {
      map['wear_salakot'] = Variable<bool>(wearSalakot.value);
    }
    if (wearGarland.present) {
      map['wear_garland'] = Variable<bool>(wearGarland.value);
    }
    if (wearSunglasses.present) {
      map['wear_sunglasses'] = Variable<bool>(wearSunglasses.value);
    }
    if (potPattern.present) {
      map['pot_pattern'] = Variable<String>(potPattern.value);
    }
    if (hat.present) {
      map['hat'] = Variable<String>(hat.value);
    }
    if (glasses.present) {
      map['glasses'] = Variable<String>(glasses.value);
    }
    if (neck.present) {
      map['neck'] = Variable<String>(neck.value);
    }
    if (friend.present) {
      map['friend'] = Variable<String>(friend.value);
    }
    if (spot.present) {
      map['spot'] = Variable<String>(spot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('avatarId: $avatarId, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('onboarded: $onboarded, ')
          ..write('soundOn: $soundOn, ')
          ..write('autoRead: $autoRead, ')
          ..write('speechRate: $speechRate, ')
          ..write('voiceId: $voiceId, ')
          ..write('voiceStyle: $voiceStyle, ')
          ..write('lessMotion: $lessMotion, ')
          ..write('musicOn: $musicOn, ')
          ..write('wearSalakot: $wearSalakot, ')
          ..write('wearGarland: $wearGarland, ')
          ..write('wearSunglasses: $wearSunglasses, ')
          ..write('potPattern: $potPattern, ')
          ..write('hat: $hat, ')
          ..write('glasses: $glasses, ')
          ..write('neck: $neck, ')
          ..write('friend: $friend, ')
          ..write('spot: $spot')
          ..write(')'))
        .toString();
  }
}

class $LeavesLogTable extends LeavesLog with TableInfo<$LeavesLogTable, LeafEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeavesLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta('attemptId');
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, reason, plantId, attemptId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaves_log';
  @override
  VerificationContext validateIntegrity(Insertable<LeafEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta, reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta, plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(_attemptIdMeta, attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeafEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeafEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      reason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      plantId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plant_id']),
      attemptId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempt_id']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LeavesLogTable createAlias(String alias) {
    return $LeavesLogTable(attachedDatabase, alias);
  }
}

class LeafEntry extends DataClass implements Insertable<LeafEntry> {
  final int id;
  final int amount;

  /// 'explore', 'parts', 'correct', 'perfect', 'game', 'badge', 'gift',
  /// 'water' or 'buy'.
  final String reason;
  final String? plantId;
  final int? attemptId;
  final DateTime createdAt;
  const LeafEntry({
    required this.id,
    required this.amount,
    required this.reason,
    this.plantId,
    this.attemptId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || plantId != null) {
      map['plant_id'] = Variable<String>(plantId);
    }
    if (!nullToAbsent || attemptId != null) {
      map['attempt_id'] = Variable<int>(attemptId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LeavesLogCompanion toCompanion(bool nullToAbsent) {
    return LeavesLogCompanion(
      id: Value(id),
      amount: Value(amount),
      reason: Value(reason),
      plantId: plantId == null && nullToAbsent ? const Value.absent() : Value(plantId),
      attemptId: attemptId == null && nullToAbsent ? const Value.absent() : Value(attemptId),
      createdAt: Value(createdAt),
    );
  }

  factory LeafEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeafEntry(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      plantId: serializer.fromJson<String?>(json['plantId']),
      attemptId: serializer.fromJson<int?>(json['attemptId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'plantId': serializer.toJson<String?>(plantId),
      'attemptId': serializer.toJson<int?>(attemptId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LeafEntry copyWith({
    int? id,
    int? amount,
    String? reason,
    Value<String?> plantId = const Value.absent(),
    Value<int?> attemptId = const Value.absent(),
    DateTime? createdAt,
  }) => LeafEntry(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    plantId: plantId.present ? plantId.value : this.plantId,
    attemptId: attemptId.present ? attemptId.value : this.attemptId,
    createdAt: createdAt ?? this.createdAt,
  );
  LeafEntry copyWithCompanion(LeavesLogCompanion data) {
    return LeafEntry(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeafEntry(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('plantId: $plantId, ')
          ..write('attemptId: $attemptId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, reason, plantId, attemptId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeafEntry &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.plantId == this.plantId &&
          other.attemptId == this.attemptId &&
          other.createdAt == this.createdAt);
}

class LeavesLogCompanion extends UpdateCompanion<LeafEntry> {
  final Value<int> id;
  final Value<int> amount;
  final Value<String> reason;
  final Value<String?> plantId;
  final Value<int?> attemptId;
  final Value<DateTime> createdAt;
  const LeavesLogCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.plantId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LeavesLogCompanion.insert({
    this.id = const Value.absent(),
    required int amount,
    required String reason,
    this.plantId = const Value.absent(),
    this.attemptId = const Value.absent(),
    required DateTime createdAt,
  }) : amount = Value(amount),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<LeafEntry> custom({
    Expression<int>? id,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? plantId,
    Expression<int>? attemptId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (plantId != null) 'plant_id': plantId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LeavesLogCompanion copyWith({
    Value<int>? id,
    Value<int>? amount,
    Value<String>? reason,
    Value<String?>? plantId,
    Value<int?>? attemptId,
    Value<DateTime>? createdAt,
  }) {
    return LeavesLogCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      plantId: plantId ?? this.plantId,
      attemptId: attemptId ?? this.attemptId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeavesLogCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('plantId: $plantId, ')
          ..write('attemptId: $attemptId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlantProgressTable extends PlantProgress with TableInfo<$PlantProgressTable, PlantProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plantIdMeta = const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exploredAtMeta = const VerificationMeta('exploredAt');
  @override
  late final GeneratedColumn<DateTime> exploredAt = GeneratedColumn<DateTime>(
    'explored_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partsFoundMeta = const VerificationMeta('partsFound');
  @override
  late final GeneratedColumn<int> partsFound = GeneratedColumn<int>(
    'parts_found',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allPartsAtMeta = const VerificationMeta('allPartsAt');
  @override
  late final GeneratedColumn<DateTime> allPartsAt = GeneratedColumn<DateTime>(
    'all_parts_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quizDoneAtMeta = const VerificationMeta('quizDoneAt');
  @override
  late final GeneratedColumn<DateTime> quizDoneAt = GeneratedColumn<DateTime>(
    'quiz_done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta('bestScore');
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [plantId, exploredAt, partsFound, allPartsAt, quizDoneAt, bestScore];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_progress';
  @override
  VerificationContext validateIntegrity(Insertable<PlantProgressRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta, plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('explored_at')) {
      context.handle(_exploredAtMeta, exploredAt.isAcceptableOrUnknown(data['explored_at']!, _exploredAtMeta));
    }
    if (data.containsKey('parts_found')) {
      context.handle(_partsFoundMeta, partsFound.isAcceptableOrUnknown(data['parts_found']!, _partsFoundMeta));
    }
    if (data.containsKey('all_parts_at')) {
      context.handle(_allPartsAtMeta, allPartsAt.isAcceptableOrUnknown(data['all_parts_at']!, _allPartsAtMeta));
    }
    if (data.containsKey('quiz_done_at')) {
      context.handle(_quizDoneAtMeta, quizDoneAt.isAcceptableOrUnknown(data['quiz_done_at']!, _quizDoneAtMeta));
    }
    if (data.containsKey('best_score')) {
      context.handle(_bestScoreMeta, bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plantId};
  @override
  PlantProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantProgressRow(
      plantId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      exploredAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}explored_at']),
      partsFound: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}parts_found'])!,
      allPartsAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}all_parts_at']),
      quizDoneAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}quiz_done_at']),
      bestScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}best_score']),
    );
  }

  @override
  $PlantProgressTable createAlias(String alias) {
    return $PlantProgressTable(attachedDatabase, alias);
  }
}

class PlantProgressRow extends DataClass implements Insertable<PlantProgressRow> {
  final String plantId;
  final DateTime? exploredAt;

  /// Bitmask of parts tapped (see PartBits).
  final int partsFound;
  final DateTime? allPartsAt;

  /// Set the first time this plant's quiz is finished: unlocks the next stop.
  final DateTime? quizDoneAt;
  final int? bestScore;
  const PlantProgressRow({
    required this.plantId,
    this.exploredAt,
    required this.partsFound,
    this.allPartsAt,
    this.quizDoneAt,
    this.bestScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plant_id'] = Variable<String>(plantId);
    if (!nullToAbsent || exploredAt != null) {
      map['explored_at'] = Variable<DateTime>(exploredAt);
    }
    map['parts_found'] = Variable<int>(partsFound);
    if (!nullToAbsent || allPartsAt != null) {
      map['all_parts_at'] = Variable<DateTime>(allPartsAt);
    }
    if (!nullToAbsent || quizDoneAt != null) {
      map['quiz_done_at'] = Variable<DateTime>(quizDoneAt);
    }
    if (!nullToAbsent || bestScore != null) {
      map['best_score'] = Variable<int>(bestScore);
    }
    return map;
  }

  PlantProgressCompanion toCompanion(bool nullToAbsent) {
    return PlantProgressCompanion(
      plantId: Value(plantId),
      exploredAt: exploredAt == null && nullToAbsent ? const Value.absent() : Value(exploredAt),
      partsFound: Value(partsFound),
      allPartsAt: allPartsAt == null && nullToAbsent ? const Value.absent() : Value(allPartsAt),
      quizDoneAt: quizDoneAt == null && nullToAbsent ? const Value.absent() : Value(quizDoneAt),
      bestScore: bestScore == null && nullToAbsent ? const Value.absent() : Value(bestScore),
    );
  }

  factory PlantProgressRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantProgressRow(
      plantId: serializer.fromJson<String>(json['plantId']),
      exploredAt: serializer.fromJson<DateTime?>(json['exploredAt']),
      partsFound: serializer.fromJson<int>(json['partsFound']),
      allPartsAt: serializer.fromJson<DateTime?>(json['allPartsAt']),
      quizDoneAt: serializer.fromJson<DateTime?>(json['quizDoneAt']),
      bestScore: serializer.fromJson<int?>(json['bestScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plantId': serializer.toJson<String>(plantId),
      'exploredAt': serializer.toJson<DateTime?>(exploredAt),
      'partsFound': serializer.toJson<int>(partsFound),
      'allPartsAt': serializer.toJson<DateTime?>(allPartsAt),
      'quizDoneAt': serializer.toJson<DateTime?>(quizDoneAt),
      'bestScore': serializer.toJson<int?>(bestScore),
    };
  }

  PlantProgressRow copyWith({
    String? plantId,
    Value<DateTime?> exploredAt = const Value.absent(),
    int? partsFound,
    Value<DateTime?> allPartsAt = const Value.absent(),
    Value<DateTime?> quizDoneAt = const Value.absent(),
    Value<int?> bestScore = const Value.absent(),
  }) => PlantProgressRow(
    plantId: plantId ?? this.plantId,
    exploredAt: exploredAt.present ? exploredAt.value : this.exploredAt,
    partsFound: partsFound ?? this.partsFound,
    allPartsAt: allPartsAt.present ? allPartsAt.value : this.allPartsAt,
    quizDoneAt: quizDoneAt.present ? quizDoneAt.value : this.quizDoneAt,
    bestScore: bestScore.present ? bestScore.value : this.bestScore,
  );
  PlantProgressRow copyWithCompanion(PlantProgressCompanion data) {
    return PlantProgressRow(
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      exploredAt: data.exploredAt.present ? data.exploredAt.value : this.exploredAt,
      partsFound: data.partsFound.present ? data.partsFound.value : this.partsFound,
      allPartsAt: data.allPartsAt.present ? data.allPartsAt.value : this.allPartsAt,
      quizDoneAt: data.quizDoneAt.present ? data.quizDoneAt.value : this.quizDoneAt,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantProgressRow(')
          ..write('plantId: $plantId, ')
          ..write('exploredAt: $exploredAt, ')
          ..write('partsFound: $partsFound, ')
          ..write('allPartsAt: $allPartsAt, ')
          ..write('quizDoneAt: $quizDoneAt, ')
          ..write('bestScore: $bestScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(plantId, exploredAt, partsFound, allPartsAt, quizDoneAt, bestScore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantProgressRow &&
          other.plantId == this.plantId &&
          other.exploredAt == this.exploredAt &&
          other.partsFound == this.partsFound &&
          other.allPartsAt == this.allPartsAt &&
          other.quizDoneAt == this.quizDoneAt &&
          other.bestScore == this.bestScore);
}

class PlantProgressCompanion extends UpdateCompanion<PlantProgressRow> {
  final Value<String> plantId;
  final Value<DateTime?> exploredAt;
  final Value<int> partsFound;
  final Value<DateTime?> allPartsAt;
  final Value<DateTime?> quizDoneAt;
  final Value<int?> bestScore;
  final Value<int> rowid;
  const PlantProgressCompanion({
    this.plantId = const Value.absent(),
    this.exploredAt = const Value.absent(),
    this.partsFound = const Value.absent(),
    this.allPartsAt = const Value.absent(),
    this.quizDoneAt = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantProgressCompanion.insert({
    required String plantId,
    this.exploredAt = const Value.absent(),
    this.partsFound = const Value.absent(),
    this.allPartsAt = const Value.absent(),
    this.quizDoneAt = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : plantId = Value(plantId);
  static Insertable<PlantProgressRow> custom({
    Expression<String>? plantId,
    Expression<DateTime>? exploredAt,
    Expression<int>? partsFound,
    Expression<DateTime>? allPartsAt,
    Expression<DateTime>? quizDoneAt,
    Expression<int>? bestScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plantId != null) 'plant_id': plantId,
      if (exploredAt != null) 'explored_at': exploredAt,
      if (partsFound != null) 'parts_found': partsFound,
      if (allPartsAt != null) 'all_parts_at': allPartsAt,
      if (quizDoneAt != null) 'quiz_done_at': quizDoneAt,
      if (bestScore != null) 'best_score': bestScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantProgressCompanion copyWith({
    Value<String>? plantId,
    Value<DateTime?>? exploredAt,
    Value<int>? partsFound,
    Value<DateTime?>? allPartsAt,
    Value<DateTime?>? quizDoneAt,
    Value<int?>? bestScore,
    Value<int>? rowid,
  }) {
    return PlantProgressCompanion(
      plantId: plantId ?? this.plantId,
      exploredAt: exploredAt ?? this.exploredAt,
      partsFound: partsFound ?? this.partsFound,
      allPartsAt: allPartsAt ?? this.allPartsAt,
      quizDoneAt: quizDoneAt ?? this.quizDoneAt,
      bestScore: bestScore ?? this.bestScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (exploredAt.present) {
      map['explored_at'] = Variable<DateTime>(exploredAt.value);
    }
    if (partsFound.present) {
      map['parts_found'] = Variable<int>(partsFound.value);
    }
    if (allPartsAt.present) {
      map['all_parts_at'] = Variable<DateTime>(allPartsAt.value);
    }
    if (quizDoneAt.present) {
      map['quiz_done_at'] = Variable<DateTime>(quizDoneAt.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantProgressCompanion(')
          ..write('plantId: $plantId, ')
          ..write('exploredAt: $exploredAt, ')
          ..write('partsFound: $partsFound, ')
          ..write('allPartsAt: $allPartsAt, ')
          ..write('quizDoneAt: $quizDoneAt, ')
          ..write('bestScore: $bestScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptsTable extends QuizAttempts with TableInfo<$QuizAttemptsTable, QuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, plantId, total, startedAt, finishedAt, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<QuizAttempt> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta, plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    }
    if (data.containsKey('total')) {
      context.handle(_totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta, startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(_finishedAtMeta, finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('score')) {
      context.handle(_scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttempt(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      plantId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plant_id']),
      total: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      startedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      finishedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      score: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}score']),
    );
  }

  @override
  $QuizAttemptsTable createAlias(String alias) {
    return $QuizAttemptsTable(attachedDatabase, alias);
  }
}

class QuizAttempt extends DataClass implements Insertable<QuizAttempt> {
  final int id;

  /// 'plant', 'sprout', 'sapling' or 'review'.
  final String kind;
  final String? plantId;
  final int total;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? score;
  const QuizAttempt({
    required this.id,
    required this.kind,
    this.plantId,
    required this.total,
    required this.startedAt,
    this.finishedAt,
    this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || plantId != null) {
      map['plant_id'] = Variable<String>(plantId);
    }
    map['total'] = Variable<int>(total);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    return map;
  }

  QuizAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptsCompanion(
      id: Value(id),
      kind: Value(kind),
      plantId: plantId == null && nullToAbsent ? const Value.absent() : Value(plantId),
      total: Value(total),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent ? const Value.absent() : Value(finishedAt),
      score: score == null && nullToAbsent ? const Value.absent() : Value(score),
    );
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttempt(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      plantId: serializer.fromJson<String?>(json['plantId']),
      total: serializer.fromJson<int>(json['total']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      score: serializer.fromJson<int?>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'plantId': serializer.toJson<String?>(plantId),
      'total': serializer.toJson<int>(total),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'score': serializer.toJson<int?>(score),
    };
  }

  QuizAttempt copyWith({
    int? id,
    String? kind,
    Value<String?> plantId = const Value.absent(),
    int? total,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> score = const Value.absent(),
  }) => QuizAttempt(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    plantId: plantId.present ? plantId.value : this.plantId,
    total: total ?? this.total,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    score: score.present ? score.value : this.score,
  );
  QuizAttempt copyWithCompanion(QuizAttemptsCompanion data) {
    return QuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      total: data.total.present ? data.total.value : this.total,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttempt(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('plantId: $plantId, ')
          ..write('total: $total, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, plantId, total, startedAt, finishedAt, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttempt &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.plantId == this.plantId &&
          other.total == this.total &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.score == this.score);
}

class QuizAttemptsCompanion extends UpdateCompanion<QuizAttempt> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String?> plantId;
  final Value<int> total;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> score;
  const QuizAttemptsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.plantId = const Value.absent(),
    this.total = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.score = const Value.absent(),
  });
  QuizAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.plantId = const Value.absent(),
    required int total,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.score = const Value.absent(),
  }) : kind = Value(kind),
       total = Value(total),
       startedAt = Value(startedAt);
  static Insertable<QuizAttempt> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? plantId,
    Expression<int>? total,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (plantId != null) 'plant_id': plantId,
      if (total != null) 'total': total,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (score != null) 'score': score,
    });
  }

  QuizAttemptsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String?>? plantId,
    Value<int>? total,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int?>? score,
  }) {
    return QuizAttemptsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      plantId: plantId ?? this.plantId,
      total: total ?? this.total,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('plantId: $plantId, ')
          ..write('total: $total, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $QuizAnswersTable extends QuizAnswers with TableInfo<$QuizAnswersTable, QuizAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta('attemptId');
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES quiz_attempts (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chosenMeta = const VerificationMeta('chosen');
  @override
  late final GeneratedColumn<String> chosen = GeneratedColumn<String>(
    'chosen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta('correct');
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("correct" IN (0, 1))'),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta('answeredAt');
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, attemptId, questionId, chosen, correct, answeredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_answers';
  @override
  VerificationContext validateIntegrity(Insertable<QuizAnswer> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(_attemptIdMeta, attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta));
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(_questionIdMeta, questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('chosen')) {
      context.handle(_chosenMeta, chosen.isAcceptableOrUnknown(data['chosen']!, _chosenMeta));
    } else if (isInserting) {
      context.missing(_chosenMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta, correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(_answeredAtMeta, answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta));
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {attemptId, questionId},
  ];
  @override
  QuizAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAnswer(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      attemptId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempt_id'])!,
      questionId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      chosen: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}chosen'])!,
      correct: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}correct'])!,
      answeredAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}answered_at'])!,
    );
  }

  @override
  $QuizAnswersTable createAlias(String alias) {
    return $QuizAnswersTable(attachedDatabase, alias);
  }
}

class QuizAnswer extends DataClass implements Insertable<QuizAnswer> {
  final int id;
  final int attemptId;
  final String questionId;
  final String chosen;
  final bool correct;
  final DateTime answeredAt;
  const QuizAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.chosen,
    required this.correct,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_id'] = Variable<int>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    map['chosen'] = Variable<String>(chosen);
    map['correct'] = Variable<bool>(correct);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  QuizAnswersCompanion toCompanion(bool nullToAbsent) {
    return QuizAnswersCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      chosen: Value(chosen),
      correct: Value(correct),
      answeredAt: Value(answeredAt),
    );
  }

  factory QuizAnswer.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAnswer(
      id: serializer.fromJson<int>(json['id']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      chosen: serializer.fromJson<String>(json['chosen']),
      correct: serializer.fromJson<bool>(json['correct']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptId': serializer.toJson<int>(attemptId),
      'questionId': serializer.toJson<String>(questionId),
      'chosen': serializer.toJson<String>(chosen),
      'correct': serializer.toJson<bool>(correct),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  QuizAnswer copyWith({
    int? id,
    int? attemptId,
    String? questionId,
    String? chosen,
    bool? correct,
    DateTime? answeredAt,
  }) => QuizAnswer(
    id: id ?? this.id,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    chosen: chosen ?? this.chosen,
    correct: correct ?? this.correct,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  QuizAnswer copyWithCompanion(QuizAnswersCompanion data) {
    return QuizAnswer(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present ? data.questionId.value : this.questionId,
      chosen: data.chosen.present ? data.chosen.value : this.chosen,
      correct: data.correct.present ? data.correct.value : this.correct,
      answeredAt: data.answeredAt.present ? data.answeredAt.value : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAnswer(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('chosen: $chosen, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attemptId, questionId, chosen, correct, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAnswer &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.chosen == this.chosen &&
          other.correct == this.correct &&
          other.answeredAt == this.answeredAt);
}

class QuizAnswersCompanion extends UpdateCompanion<QuizAnswer> {
  final Value<int> id;
  final Value<int> attemptId;
  final Value<String> questionId;
  final Value<String> chosen;
  final Value<bool> correct;
  final Value<DateTime> answeredAt;
  const QuizAnswersCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.chosen = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuizAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int attemptId,
    required String questionId,
    required String chosen,
    required bool correct,
    required DateTime answeredAt,
  }) : attemptId = Value(attemptId),
       questionId = Value(questionId),
       chosen = Value(chosen),
       correct = Value(correct),
       answeredAt = Value(answeredAt);
  static Insertable<QuizAnswer> custom({
    Expression<int>? id,
    Expression<int>? attemptId,
    Expression<String>? questionId,
    Expression<String>? chosen,
    Expression<bool>? correct,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (chosen != null) 'chosen': chosen,
      if (correct != null) 'correct': correct,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuizAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptId,
    Value<String>? questionId,
    Value<String>? chosen,
    Value<bool>? correct,
    Value<DateTime>? answeredAt,
  }) {
    return QuizAnswersCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      chosen: chosen ?? this.chosen,
      correct: correct ?? this.correct,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (chosen.present) {
      map['chosen'] = Variable<String>(chosen.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAnswersCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('chosen: $chosen, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases with TableInfo<$PurchasesTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boughtAtMeta = const VerificationMeta('boughtAt');
  @override
  late final GeneratedColumn<DateTime> boughtAt = GeneratedColumn<DateTime>(
    'bought_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [item, price, boughtAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item')) {
      context.handle(_itemMeta, item.isAcceptableOrUnknown(data['item']!, _itemMeta));
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('price')) {
      context.handle(_priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('bought_at')) {
      context.handle(_boughtAtMeta, boughtAt.isAcceptableOrUnknown(data['bought_at']!, _boughtAtMeta));
    } else if (isInserting) {
      context.missing(_boughtAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {item};
  @override
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      item: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}item'])!,
      price: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}price'])!,
      boughtAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}bought_at'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  /// An OutfitItem name, e.g. 'salakot'.
  final String item;
  final int price;
  final DateTime boughtAt;
  const PurchaseRow({required this.item, required this.price, required this.boughtAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item'] = Variable<String>(item);
    map['price'] = Variable<int>(price);
    map['bought_at'] = Variable<DateTime>(boughtAt);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(item: Value(item), price: Value(price), boughtAt: Value(boughtAt));
  }

  factory PurchaseRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      item: serializer.fromJson<String>(json['item']),
      price: serializer.fromJson<int>(json['price']),
      boughtAt: serializer.fromJson<DateTime>(json['boughtAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'item': serializer.toJson<String>(item),
      'price': serializer.toJson<int>(price),
      'boughtAt': serializer.toJson<DateTime>(boughtAt),
    };
  }

  PurchaseRow copyWith({String? item, int? price, DateTime? boughtAt}) =>
      PurchaseRow(item: item ?? this.item, price: price ?? this.price, boughtAt: boughtAt ?? this.boughtAt);
  PurchaseRow copyWithCompanion(PurchasesCompanion data) {
    return PurchaseRow(
      item: data.item.present ? data.item.value : this.item,
      price: data.price.present ? data.price.value : this.price,
      boughtAt: data.boughtAt.present ? data.boughtAt.value : this.boughtAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('item: $item, ')
          ..write('price: $price, ')
          ..write('boughtAt: $boughtAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(item, price, boughtAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow && other.item == this.item && other.price == this.price && other.boughtAt == this.boughtAt);
}

class PurchasesCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> item;
  final Value<int> price;
  final Value<DateTime> boughtAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.item = const Value.absent(),
    this.price = const Value.absent(),
    this.boughtAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String item,
    required int price,
    required DateTime boughtAt,
    this.rowid = const Value.absent(),
  }) : item = Value(item),
       price = Value(price),
       boughtAt = Value(boughtAt);
  static Insertable<PurchaseRow> custom({
    Expression<String>? item,
    Expression<int>? price,
    Expression<DateTime>? boughtAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (item != null) 'item': item,
      if (price != null) 'price': price,
      if (boughtAt != null) 'bought_at': boughtAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({Value<String>? item, Value<int>? price, Value<DateTime>? boughtAt, Value<int>? rowid}) {
    return PurchasesCompanion(
      item: item ?? this.item,
      price: price ?? this.price,
      boughtAt: boughtAt ?? this.boughtAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (boughtAt.present) {
      map['bought_at'] = Variable<DateTime>(boughtAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('item: $item, ')
          ..write('price: $price, ')
          ..write('boughtAt: $boughtAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameWinsTable extends GameWins with TableInfo<$GameWinsTable, GameWinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameWinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wonAtMeta = const VerificationMeta('wonAt');
  @override
  late final GeneratedColumn<DateTime> wonAt = GeneratedColumn<DateTime>(
    'won_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [game, plantId, wonAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_wins';
  @override
  VerificationContext validateIntegrity(Insertable<GameWinRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game')) {
      context.handle(_gameMeta, game.isAcceptableOrUnknown(data['game']!, _gameMeta));
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta, plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('won_at')) {
      context.handle(_wonAtMeta, wonAt.isAcceptableOrUnknown(data['won_at']!, _wonAtMeta));
    } else if (isInserting) {
      context.missing(_wonAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {game, plantId};
  @override
  GameWinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameWinRow(
      game: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}game'])!,
      plantId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      wonAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}won_at'])!,
    );
  }

  @override
  $GameWinsTable createAlias(String alias) {
    return $GameWinsTable(attachedDatabase, alias);
  }
}

class GameWinRow extends DataClass implements Insertable<GameWinRow> {
  /// A MiniGame name: 'label', 'grow' or 'match'.
  final String game;
  final String plantId;
  final DateTime wonAt;
  const GameWinRow({required this.game, required this.plantId, required this.wonAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game'] = Variable<String>(game);
    map['plant_id'] = Variable<String>(plantId);
    map['won_at'] = Variable<DateTime>(wonAt);
    return map;
  }

  GameWinsCompanion toCompanion(bool nullToAbsent) {
    return GameWinsCompanion(game: Value(game), plantId: Value(plantId), wonAt: Value(wonAt));
  }

  factory GameWinRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameWinRow(
      game: serializer.fromJson<String>(json['game']),
      plantId: serializer.fromJson<String>(json['plantId']),
      wonAt: serializer.fromJson<DateTime>(json['wonAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'game': serializer.toJson<String>(game),
      'plantId': serializer.toJson<String>(plantId),
      'wonAt': serializer.toJson<DateTime>(wonAt),
    };
  }

  GameWinRow copyWith({String? game, String? plantId, DateTime? wonAt}) =>
      GameWinRow(game: game ?? this.game, plantId: plantId ?? this.plantId, wonAt: wonAt ?? this.wonAt);
  GameWinRow copyWithCompanion(GameWinsCompanion data) {
    return GameWinRow(
      game: data.game.present ? data.game.value : this.game,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      wonAt: data.wonAt.present ? data.wonAt.value : this.wonAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameWinRow(')
          ..write('game: $game, ')
          ..write('plantId: $plantId, ')
          ..write('wonAt: $wonAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(game, plantId, wonAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameWinRow && other.game == this.game && other.plantId == this.plantId && other.wonAt == this.wonAt);
}

class GameWinsCompanion extends UpdateCompanion<GameWinRow> {
  final Value<String> game;
  final Value<String> plantId;
  final Value<DateTime> wonAt;
  final Value<int> rowid;
  const GameWinsCompanion({
    this.game = const Value.absent(),
    this.plantId = const Value.absent(),
    this.wonAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameWinsCompanion.insert({
    required String game,
    required String plantId,
    required DateTime wonAt,
    this.rowid = const Value.absent(),
  }) : game = Value(game),
       plantId = Value(plantId),
       wonAt = Value(wonAt);
  static Insertable<GameWinRow> custom({
    Expression<String>? game,
    Expression<String>? plantId,
    Expression<DateTime>? wonAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (game != null) 'game': game,
      if (plantId != null) 'plant_id': plantId,
      if (wonAt != null) 'won_at': wonAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameWinsCompanion copyWith({Value<String>? game, Value<String>? plantId, Value<DateTime>? wonAt, Value<int>? rowid}) {
    return GameWinsCompanion(
      game: game ?? this.game,
      plantId: plantId ?? this.plantId,
      wonAt: wonAt ?? this.wonAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (wonAt.present) {
      map['won_at'] = Variable<DateTime>(wonAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameWinsCompanion(')
          ..write('game: $game, ')
          ..write('plantId: $plantId, ')
          ..write('wonAt: $wonAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgeWinsTable extends BadgeWins with TableInfo<$BadgeWinsTable, BadgeWinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgeWinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeMeta = const VerificationMeta('badge');
  @override
  late final GeneratedColumn<String> badge = GeneratedColumn<String>(
    'badge',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wonAtMeta = const VerificationMeta('wonAt');
  @override
  late final GeneratedColumn<DateTime> wonAt = GeneratedColumn<DateTime>(
    'won_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [badge, wonAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badge_wins';
  @override
  VerificationContext validateIntegrity(Insertable<BadgeWinRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge')) {
      context.handle(_badgeMeta, badge.isAcceptableOrUnknown(data['badge']!, _badgeMeta));
    } else if (isInserting) {
      context.missing(_badgeMeta);
    }
    if (data.containsKey('won_at')) {
      context.handle(_wonAtMeta, wonAt.isAcceptableOrUnknown(data['won_at']!, _wonAtMeta));
    } else if (isInserting) {
      context.missing(_wonAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badge};
  @override
  BadgeWinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgeWinRow(
      badge: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}badge'])!,
      wonAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}won_at'])!,
    );
  }

  @override
  $BadgeWinsTable createAlias(String alias) {
    return $BadgeWinsTable(attachedDatabase, alias);
  }
}

class BadgeWinRow extends DataClass implements Insertable<BadgeWinRow> {
  /// A Badge name, e.g. 'backyard'.
  final String badge;
  final DateTime wonAt;
  const BadgeWinRow({required this.badge, required this.wonAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge'] = Variable<String>(badge);
    map['won_at'] = Variable<DateTime>(wonAt);
    return map;
  }

  BadgeWinsCompanion toCompanion(bool nullToAbsent) {
    return BadgeWinsCompanion(badge: Value(badge), wonAt: Value(wonAt));
  }

  factory BadgeWinRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgeWinRow(
      badge: serializer.fromJson<String>(json['badge']),
      wonAt: serializer.fromJson<DateTime>(json['wonAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'badge': serializer.toJson<String>(badge), 'wonAt': serializer.toJson<DateTime>(wonAt)};
  }

  BadgeWinRow copyWith({String? badge, DateTime? wonAt}) =>
      BadgeWinRow(badge: badge ?? this.badge, wonAt: wonAt ?? this.wonAt);
  BadgeWinRow copyWithCompanion(BadgeWinsCompanion data) {
    return BadgeWinRow(
      badge: data.badge.present ? data.badge.value : this.badge,
      wonAt: data.wonAt.present ? data.wonAt.value : this.wonAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgeWinRow(')
          ..write('badge: $badge, ')
          ..write('wonAt: $wonAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badge, wonAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BadgeWinRow && other.badge == this.badge && other.wonAt == this.wonAt);
}

class BadgeWinsCompanion extends UpdateCompanion<BadgeWinRow> {
  final Value<String> badge;
  final Value<DateTime> wonAt;
  final Value<int> rowid;
  const BadgeWinsCompanion({
    this.badge = const Value.absent(),
    this.wonAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgeWinsCompanion.insert({required String badge, required DateTime wonAt, this.rowid = const Value.absent()})
    : badge = Value(badge),
      wonAt = Value(wonAt);
  static Insertable<BadgeWinRow> custom({
    Expression<String>? badge,
    Expression<DateTime>? wonAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badge != null) 'badge': badge,
      if (wonAt != null) 'won_at': wonAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgeWinsCompanion copyWith({Value<String>? badge, Value<DateTime>? wonAt, Value<int>? rowid}) {
    return BadgeWinsCompanion(badge: badge ?? this.badge, wonAt: wonAt ?? this.wonAt, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badge.present) {
      map['badge'] = Variable<String>(badge.value);
    }
    if (wonAt.present) {
      map['won_at'] = Variable<DateTime>(wonAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgeWinsCompanion(')
          ..write('badge: $badge, ')
          ..write('wonAt: $wonAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GardenSpotsTable extends GardenSpots with TableInfo<$GardenSpotsTable, GardenSpotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GardenSpotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pieceMeta = const VerificationMeta('piece');
  @override
  late final GeneratedColumn<String> piece = GeneratedColumn<String>(
    'piece',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [piece, x, y];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garden_spots';
  @override
  VerificationContext validateIntegrity(Insertable<GardenSpotRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('piece')) {
      context.handle(_pieceMeta, piece.isAcceptableOrUnknown(data['piece']!, _pieceMeta));
    } else if (isInserting) {
      context.missing(_pieceMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {piece};
  @override
  GardenSpotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GardenSpotRow(
      piece: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}piece'])!,
      x: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}x'])!,
      y: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}y'])!,
    );
  }

  @override
  $GardenSpotsTable createAlias(String alias) {
    return $GardenSpotsTable(attachedDatabase, alias);
  }
}

class GardenSpotRow extends DataClass implements Insertable<GardenSpotRow> {
  /// A GardenLayout piece name, e.g. 'plant_gumamela', 'bed', 'deco_bench'.
  final String piece;
  final double x;
  final double y;
  const GardenSpotRow({required this.piece, required this.x, required this.y});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['piece'] = Variable<String>(piece);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    return map;
  }

  GardenSpotsCompanion toCompanion(bool nullToAbsent) {
    return GardenSpotsCompanion(piece: Value(piece), x: Value(x), y: Value(y));
  }

  factory GardenSpotRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GardenSpotRow(
      piece: serializer.fromJson<String>(json['piece']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'piece': serializer.toJson<String>(piece),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
    };
  }

  GardenSpotRow copyWith({String? piece, double? x, double? y}) =>
      GardenSpotRow(piece: piece ?? this.piece, x: x ?? this.x, y: y ?? this.y);
  GardenSpotRow copyWithCompanion(GardenSpotsCompanion data) {
    return GardenSpotRow(
      piece: data.piece.present ? data.piece.value : this.piece,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GardenSpotRow(')
          ..write('piece: $piece, ')
          ..write('x: $x, ')
          ..write('y: $y')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(piece, x, y);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GardenSpotRow && other.piece == this.piece && other.x == this.x && other.y == this.y);
}

class GardenSpotsCompanion extends UpdateCompanion<GardenSpotRow> {
  final Value<String> piece;
  final Value<double> x;
  final Value<double> y;
  final Value<int> rowid;
  const GardenSpotsCompanion({
    this.piece = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GardenSpotsCompanion.insert({
    required String piece,
    required double x,
    required double y,
    this.rowid = const Value.absent(),
  }) : piece = Value(piece),
       x = Value(x),
       y = Value(y);
  static Insertable<GardenSpotRow> custom({
    Expression<String>? piece,
    Expression<double>? x,
    Expression<double>? y,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (piece != null) 'piece': piece,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GardenSpotsCompanion copyWith({Value<String>? piece, Value<double>? x, Value<double>? y, Value<int>? rowid}) {
    return GardenSpotsCompanion(piece: piece ?? this.piece, x: x ?? this.x, y: y ?? this.y, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (piece.present) {
      map['piece'] = Variable<String>(piece.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GardenSpotsCompanion(')
          ..write('piece: $piece, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyCareTable extends DailyCare with TableInfo<$DailyCareTable, DailyCareData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCareTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [kind, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_care';
  @override
  VerificationContext validateIntegrity(Insertable<DailyCareData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, day};
  @override
  DailyCareData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCareData(
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $DailyCareTable createAlias(String alias) {
    return $DailyCareTable(attachedDatabase, alias);
  }
}

class DailyCareData extends DataClass implements Insertable<DailyCareData> {
  /// A DailyKind name: 'gift' or 'water'.
  final String kind;

  /// "YYYY-MM-DD", local time.
  final String day;
  const DailyCareData({required this.kind, required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['day'] = Variable<String>(day);
    return map;
  }

  DailyCareCompanion toCompanion(bool nullToAbsent) {
    return DailyCareCompanion(kind: Value(kind), day: Value(day));
  }

  factory DailyCareData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCareData(
      kind: serializer.fromJson<String>(json['kind']),
      day: serializer.fromJson<String>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'kind': serializer.toJson<String>(kind), 'day': serializer.toJson<String>(day)};
  }

  DailyCareData copyWith({String? kind, String? day}) => DailyCareData(kind: kind ?? this.kind, day: day ?? this.day);
  DailyCareData copyWithCompanion(DailyCareCompanion data) {
    return DailyCareData(
      kind: data.kind.present ? data.kind.value : this.kind,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCareData(')
          ..write('kind: $kind, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DailyCareData && other.kind == this.kind && other.day == this.day);
}

class DailyCareCompanion extends UpdateCompanion<DailyCareData> {
  final Value<String> kind;
  final Value<String> day;
  final Value<int> rowid;
  const DailyCareCompanion({
    this.kind = const Value.absent(),
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyCareCompanion.insert({required String kind, required String day, this.rowid = const Value.absent()})
    : kind = Value(kind),
      day = Value(day);
  static Insertable<DailyCareData> custom({Expression<String>? kind, Expression<String>? day, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyCareCompanion copyWith({Value<String>? kind, Value<String>? day, Value<int>? rowid}) {
    return DailyCareCompanion(kind: kind ?? this.kind, day: day ?? this.day, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCareCompanion(')
          ..write('kind: $kind, ')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColouringsTable extends Colourings with TableInfo<$ColouringsTable, ColouringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColouringsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plantIdMeta = const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pictureMeta = const VerificationMeta('picture');
  @override
  late final GeneratedColumn<String> picture = GeneratedColumn<String>(
    'picture',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hungAtMeta = const VerificationMeta('hungAt');
  @override
  late final GeneratedColumn<DateTime> hungAt = GeneratedColumn<DateTime>(
    'hung_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [plantId, picture, hungAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'colourings';
  @override
  VerificationContext validateIntegrity(Insertable<ColouringRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta, plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('picture')) {
      context.handle(_pictureMeta, picture.isAcceptableOrUnknown(data['picture']!, _pictureMeta));
    } else if (isInserting) {
      context.missing(_pictureMeta);
    }
    if (data.containsKey('hung_at')) {
      context.handle(_hungAtMeta, hungAt.isAcceptableOrUnknown(data['hung_at']!, _hungAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plantId};
  @override
  ColouringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColouringRow(
      plantId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plant_id'])!,
      picture: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}picture'])!,
      hungAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}hung_at']),
    );
  }

  @override
  $ColouringsTable createAlias(String alias) {
    return $ColouringsTable(attachedDatabase, alias);
  }
}

class ColouringRow extends DataClass implements Insertable<ColouringRow> {
  final String plantId;

  /// The colours as a base64 PNG (text, so backups stay plain JSON).
  final String picture;

  /// When it was last hung on the bahay kubo wall; null while it is only a
  /// draft. The leaves are paid the first time it is set.
  final DateTime? hungAt;
  const ColouringRow({required this.plantId, required this.picture, this.hungAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plant_id'] = Variable<String>(plantId);
    map['picture'] = Variable<String>(picture);
    if (!nullToAbsent || hungAt != null) {
      map['hung_at'] = Variable<DateTime>(hungAt);
    }
    return map;
  }

  ColouringsCompanion toCompanion(bool nullToAbsent) {
    return ColouringsCompanion(
      plantId: Value(plantId),
      picture: Value(picture),
      hungAt: hungAt == null && nullToAbsent ? const Value.absent() : Value(hungAt),
    );
  }

  factory ColouringRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColouringRow(
      plantId: serializer.fromJson<String>(json['plantId']),
      picture: serializer.fromJson<String>(json['picture']),
      hungAt: serializer.fromJson<DateTime?>(json['hungAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plantId': serializer.toJson<String>(plantId),
      'picture': serializer.toJson<String>(picture),
      'hungAt': serializer.toJson<DateTime?>(hungAt),
    };
  }

  ColouringRow copyWith({String? plantId, String? picture, Value<DateTime?> hungAt = const Value.absent()}) =>
      ColouringRow(
        plantId: plantId ?? this.plantId,
        picture: picture ?? this.picture,
        hungAt: hungAt.present ? hungAt.value : this.hungAt,
      );
  ColouringRow copyWithCompanion(ColouringsCompanion data) {
    return ColouringRow(
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      picture: data.picture.present ? data.picture.value : this.picture,
      hungAt: data.hungAt.present ? data.hungAt.value : this.hungAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColouringRow(')
          ..write('plantId: $plantId, ')
          ..write('picture: $picture, ')
          ..write('hungAt: $hungAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(plantId, picture, hungAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColouringRow &&
          other.plantId == this.plantId &&
          other.picture == this.picture &&
          other.hungAt == this.hungAt);
}

class ColouringsCompanion extends UpdateCompanion<ColouringRow> {
  final Value<String> plantId;
  final Value<String> picture;
  final Value<DateTime?> hungAt;
  final Value<int> rowid;
  const ColouringsCompanion({
    this.plantId = const Value.absent(),
    this.picture = const Value.absent(),
    this.hungAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColouringsCompanion.insert({
    required String plantId,
    required String picture,
    this.hungAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : plantId = Value(plantId),
       picture = Value(picture);
  static Insertable<ColouringRow> custom({
    Expression<String>? plantId,
    Expression<String>? picture,
    Expression<DateTime>? hungAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plantId != null) 'plant_id': plantId,
      if (picture != null) 'picture': picture,
      if (hungAt != null) 'hung_at': hungAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColouringsCompanion copyWith({
    Value<String>? plantId,
    Value<String>? picture,
    Value<DateTime?>? hungAt,
    Value<int>? rowid,
  }) {
    return ColouringsCompanion(
      plantId: plantId ?? this.plantId,
      picture: picture ?? this.picture,
      hungAt: hungAt ?? this.hungAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (picture.present) {
      map['picture'] = Variable<String>(picture.value);
    }
    if (hungAt.present) {
      map['hung_at'] = Variable<DateTime>(hungAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColouringsCompanion(')
          ..write('plantId: $plantId, ')
          ..write('picture: $picture, ')
          ..write('hungAt: $hungAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(Insertable<Visit> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!);
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  /// "YYYY-MM-DD", local time.
  final String day;
  const Visit({required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(day: Value(day));
  }

  factory Visit.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(day: serializer.fromJson<String>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<String>(day)};
  }

  Visit copyWith({String? day}) => Visit(day: day ?? this.day);
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(day: data.day.present ? data.day.value : this.day);
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => day.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Visit && other.day == this.day);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> day;
  final Value<int> rowid;
  const VisitsCompanion({this.day = const Value.absent(), this.rowid = const Value.absent()});
  VisitsCompanion.insert({required String day, this.rowid = const Value.absent()}) : day = Value(day);
  static Insertable<Visit> custom({Expression<String>? day, Expression<int>? rowid}) {
    return RawValuesInsertable({if (day != null) 'day': day, if (rowid != null) 'rowid': rowid});
  }

  VisitsCompanion copyWith({Value<String>? day, Value<int>? rowid}) {
    return VisitsCompanion(day: day ?? this.day, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $LeavesLogTable leavesLog = $LeavesLogTable(this);
  late final $PlantProgressTable plantProgress = $PlantProgressTable(this);
  late final $QuizAttemptsTable quizAttempts = $QuizAttemptsTable(this);
  late final $QuizAnswersTable quizAnswers = $QuizAnswersTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $GameWinsTable gameWins = $GameWinsTable(this);
  late final $BadgeWinsTable badgeWins = $BadgeWinsTable(this);
  late final $GardenSpotsTable gardenSpots = $GardenSpotsTable(this);
  late final $DailyCareTable dailyCare = $DailyCareTable(this);
  late final $ColouringsTable colourings = $ColouringsTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profile,
    leavesLog,
    plantProgress,
    quizAttempts,
    quizAnswers,
    purchases,
    gameWins,
    badgeWins,
    gardenSpots,
    dailyCare,
    colourings,
    visits,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('quiz_attempts', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('quiz_answers', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfileTableCreateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> grade,
  Value<String> avatarId,
  required DateTime joinedAt,
  Value<bool> onboarded,
  Value<bool> soundOn,
  Value<bool> autoRead,
  Value<String> speechRate,
  Value<String?> voiceId,
  Value<String> voiceStyle,
  Value<bool> lessMotion,
  Value<bool> musicOn,
  Value<bool> wearSalakot,
  Value<bool> wearGarland,
  Value<bool> wearSunglasses,
  Value<String> potPattern,
  Value<String?> hat,
  Value<String?> glasses,
  Value<String?> neck,
  Value<String?> friend,
  Value<String?> spot,
});
typedef $$ProfileTableUpdateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> grade,
  Value<String> avatarId,
  Value<DateTime> joinedAt,
  Value<bool> onboarded,
  Value<bool> soundOn,
  Value<bool> autoRead,
  Value<String> speechRate,
  Value<String?> voiceId,
  Value<String> voiceStyle,
  Value<bool> lessMotion,
  Value<bool> musicOn,
  Value<bool> wearSalakot,
  Value<bool> wearGarland,
  Value<bool> wearSunglasses,
  Value<String> potPattern,
  Value<String?> hat,
  Value<String?> glasses,
  Value<String?> neck,
  Value<String?> friend,
  Value<String?> spot,
});

class $$ProfileTableFilterComposer extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grade => $composableBuilder(column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get soundOn =>
      $composableBuilder(column: $table.soundOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoRead =>
      $composableBuilder(column: $table.autoRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speechRate =>
      $composableBuilder(column: $table.speechRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceStyle =>
      $composableBuilder(column: $table.voiceStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lessMotion =>
      $composableBuilder(column: $table.lessMotion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get musicOn =>
      $composableBuilder(column: $table.musicOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wearSalakot =>
      $composableBuilder(column: $table.wearSalakot, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wearGarland =>
      $composableBuilder(column: $table.wearGarland, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wearSunglasses =>
      $composableBuilder(column: $table.wearSunglasses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get potPattern =>
      $composableBuilder(column: $table.potPattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hat => $composableBuilder(column: $table.hat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get glasses =>
      $composableBuilder(column: $table.glasses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get neck => $composableBuilder(column: $table.neck, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friend =>
      $composableBuilder(column: $table.friend, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spot => $composableBuilder(column: $table.spot, builder: (column) => ColumnFilters(column));
}

class $$ProfileTableOrderingComposer extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get soundOn =>
      $composableBuilder(column: $table.soundOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoRead =>
      $composableBuilder(column: $table.autoRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speechRate =>
      $composableBuilder(column: $table.speechRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceStyle =>
      $composableBuilder(column: $table.voiceStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lessMotion =>
      $composableBuilder(column: $table.lessMotion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get musicOn =>
      $composableBuilder(column: $table.musicOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wearSalakot =>
      $composableBuilder(column: $table.wearSalakot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wearGarland =>
      $composableBuilder(column: $table.wearGarland, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wearSunglasses =>
      $composableBuilder(column: $table.wearSunglasses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get potPattern =>
      $composableBuilder(column: $table.potPattern, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hat =>
      $composableBuilder(column: $table.hat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get glasses =>
      $composableBuilder(column: $table.glasses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get neck =>
      $composableBuilder(column: $table.neck, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friend =>
      $composableBuilder(column: $table.friend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spot =>
      $composableBuilder(column: $table.spot, builder: (column) => ColumnOrderings(column));
}

class $$ProfileTableAnnotationComposer extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get grade => $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get avatarId => $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt => $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<bool> get onboarded => $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumn<bool> get soundOn => $composableBuilder(column: $table.soundOn, builder: (column) => column);

  GeneratedColumn<bool> get autoRead => $composableBuilder(column: $table.autoRead, builder: (column) => column);

  GeneratedColumn<String> get speechRate => $composableBuilder(column: $table.speechRate, builder: (column) => column);

  GeneratedColumn<String> get voiceId => $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<String> get voiceStyle => $composableBuilder(column: $table.voiceStyle, builder: (column) => column);

  GeneratedColumn<bool> get lessMotion => $composableBuilder(column: $table.lessMotion, builder: (column) => column);

  GeneratedColumn<bool> get musicOn => $composableBuilder(column: $table.musicOn, builder: (column) => column);

  GeneratedColumn<bool> get wearSalakot => $composableBuilder(column: $table.wearSalakot, builder: (column) => column);

  GeneratedColumn<bool> get wearGarland => $composableBuilder(column: $table.wearGarland, builder: (column) => column);

  GeneratedColumn<bool> get wearSunglasses =>
      $composableBuilder(column: $table.wearSunglasses, builder: (column) => column);

  GeneratedColumn<String> get potPattern => $composableBuilder(column: $table.potPattern, builder: (column) => column);

  GeneratedColumn<String> get hat => $composableBuilder(column: $table.hat, builder: (column) => column);

  GeneratedColumn<String> get glasses => $composableBuilder(column: $table.glasses, builder: (column) => column);

  GeneratedColumn<String> get neck => $composableBuilder(column: $table.neck, builder: (column) => column);

  GeneratedColumn<String> get friend => $composableBuilder(column: $table.friend, builder: (column) => column);

  GeneratedColumn<String> get spot => $composableBuilder(column: $table.spot, builder: (column) => column);
}

class $$ProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileTable,
          ProfileRow,
          $$ProfileTableFilterComposer,
          $$ProfileTableOrderingComposer,
          $$ProfileTableAnnotationComposer,
          $$ProfileTableCreateCompanionBuilder,
          $$ProfileTableUpdateCompanionBuilder,
          (ProfileRow, BaseReferences<_$AppDatabase, $ProfileTable, ProfileRow>),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableManager(_$AppDatabase db, $ProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String> avatarId = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                Value<bool> autoRead = const Value.absent(),
                Value<String> speechRate = const Value.absent(),
                Value<String?> voiceId = const Value.absent(),
                Value<String> voiceStyle = const Value.absent(),
                Value<bool> lessMotion = const Value.absent(),
                Value<bool> musicOn = const Value.absent(),
                Value<bool> wearSalakot = const Value.absent(),
                Value<bool> wearGarland = const Value.absent(),
                Value<bool> wearSunglasses = const Value.absent(),
                Value<String> potPattern = const Value.absent(),
                Value<String?> hat = const Value.absent(),
                Value<String?> glasses = const Value.absent(),
                Value<String?> neck = const Value.absent(),
                Value<String?> friend = const Value.absent(),
                Value<String?> spot = const Value.absent(),
              }) => ProfileCompanion(
                id: id,
                name: name,
                grade: grade,
                avatarId: avatarId,
                joinedAt: joinedAt,
                onboarded: onboarded,
                soundOn: soundOn,
                autoRead: autoRead,
                speechRate: speechRate,
                voiceId: voiceId,
                voiceStyle: voiceStyle,
                lessMotion: lessMotion,
                musicOn: musicOn,
                wearSalakot: wearSalakot,
                wearGarland: wearGarland,
                wearSunglasses: wearSunglasses,
                potPattern: potPattern,
                hat: hat,
                glasses: glasses,
                neck: neck,
                friend: friend,
                spot: spot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String> avatarId = const Value.absent(),
                required DateTime joinedAt,
                Value<bool> onboarded = const Value.absent(),
                Value<bool> soundOn = const Value.absent(),
                Value<bool> autoRead = const Value.absent(),
                Value<String> speechRate = const Value.absent(),
                Value<String?> voiceId = const Value.absent(),
                Value<String> voiceStyle = const Value.absent(),
                Value<bool> lessMotion = const Value.absent(),
                Value<bool> musicOn = const Value.absent(),
                Value<bool> wearSalakot = const Value.absent(),
                Value<bool> wearGarland = const Value.absent(),
                Value<bool> wearSunglasses = const Value.absent(),
                Value<String> potPattern = const Value.absent(),
                Value<String?> hat = const Value.absent(),
                Value<String?> glasses = const Value.absent(),
                Value<String?> neck = const Value.absent(),
                Value<String?> friend = const Value.absent(),
                Value<String?> spot = const Value.absent(),
              }) => ProfileCompanion.insert(
                id: id,
                name: name,
                grade: grade,
                avatarId: avatarId,
                joinedAt: joinedAt,
                onboarded: onboarded,
                soundOn: soundOn,
                autoRead: autoRead,
                speechRate: speechRate,
                voiceId: voiceId,
                voiceStyle: voiceStyle,
                lessMotion: lessMotion,
                musicOn: musicOn,
                wearSalakot: wearSalakot,
                wearGarland: wearGarland,
                wearSunglasses: wearSunglasses,
                potPattern: potPattern,
                hat: hat,
                glasses: glasses,
                neck: neck,
                friend: friend,
                spot: spot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfileTable, ProfileRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileTable,
      ProfileRow,
      $$ProfileTableFilterComposer,
      $$ProfileTableOrderingComposer,
      $$ProfileTableAnnotationComposer,
      $$ProfileTableCreateCompanionBuilder,
      $$ProfileTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfileTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$LeavesLogTableCreateCompanionBuilder = LeavesLogCompanion Function({
  Value<int> id,
  required int amount,
  required String reason,
  Value<String?> plantId,
  Value<int?> attemptId,
  required DateTime createdAt,
});
typedef $$LeavesLogTableUpdateCompanionBuilder = LeavesLogCompanion Function({
  Value<int> id,
  Value<int> amount,
  Value<String> reason,
  Value<String?> plantId,
  Value<int?> attemptId,
  Value<DateTime> createdAt,
});

class $$LeavesLogTableFilterComposer extends Composer<_$AppDatabase, $LeavesLogTable> {
  $$LeavesLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LeavesLogTableOrderingComposer extends Composer<_$AppDatabase, $LeavesLogTable> {
  $$LeavesLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LeavesLogTableAnnotationComposer extends Composer<_$AppDatabase, $LeavesLogTable> {
  $$LeavesLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount => $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason => $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get plantId => $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<int> get attemptId => $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LeavesLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeavesLogTable,
          LeafEntry,
          $$LeavesLogTableFilterComposer,
          $$LeavesLogTableOrderingComposer,
          $$LeavesLogTableAnnotationComposer,
          $$LeavesLogTableCreateCompanionBuilder,
          $$LeavesLogTableUpdateCompanionBuilder,
          (LeafEntry, BaseReferences<_$AppDatabase, $LeavesLogTable, LeafEntry>),
          LeafEntry,
          PrefetchHooks Function()
        > {
  $$LeavesLogTableTableManager(_$AppDatabase db, $LeavesLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LeavesLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LeavesLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LeavesLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<int?> attemptId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LeavesLogCompanion(
                id: id,
                amount: amount,
                reason: reason,
                plantId: plantId,
                attemptId: attemptId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amount,
                required String reason,
                Value<String?> plantId = const Value.absent(),
                Value<int?> attemptId = const Value.absent(),
                required DateTime createdAt,
              }) => LeavesLogCompanion.insert(
                id: id,
                amount: amount,
                reason: reason,
                plantId: plantId,
                attemptId: attemptId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LeavesLogTable, LeafEntry>(table),
                  BaseReferences<_$AppDatabase, $LeavesLogTable, LeafEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeavesLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeavesLogTable,
      LeafEntry,
      $$LeavesLogTableFilterComposer,
      $$LeavesLogTableOrderingComposer,
      $$LeavesLogTableAnnotationComposer,
      $$LeavesLogTableCreateCompanionBuilder,
      $$LeavesLogTableUpdateCompanionBuilder,
      (LeafEntry, BaseReferences<_$AppDatabase, $LeavesLogTable, LeafEntry>),
      LeafEntry,
      PrefetchHooks Function()
    >;
typedef $$PlantProgressTableCreateCompanionBuilder = PlantProgressCompanion Function({
  required String plantId,
  Value<DateTime?> exploredAt,
  Value<int> partsFound,
  Value<DateTime?> allPartsAt,
  Value<DateTime?> quizDoneAt,
  Value<int?> bestScore,
  Value<int> rowid,
});
typedef $$PlantProgressTableUpdateCompanionBuilder = PlantProgressCompanion Function({
  Value<String> plantId,
  Value<DateTime?> exploredAt,
  Value<int> partsFound,
  Value<DateTime?> allPartsAt,
  Value<DateTime?> quizDoneAt,
  Value<int?> bestScore,
  Value<int> rowid,
});

class $$PlantProgressTableFilterComposer extends Composer<_$AppDatabase, $PlantProgressTable> {
  $$PlantProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exploredAt =>
      $composableBuilder(column: $table.exploredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get partsFound =>
      $composableBuilder(column: $table.partsFound, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get allPartsAt =>
      $composableBuilder(column: $table.allPartsAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get quizDoneAt =>
      $composableBuilder(column: $table.quizDoneAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => ColumnFilters(column));
}

class $$PlantProgressTableOrderingComposer extends Composer<_$AppDatabase, $PlantProgressTable> {
  $$PlantProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exploredAt =>
      $composableBuilder(column: $table.exploredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get partsFound =>
      $composableBuilder(column: $table.partsFound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get allPartsAt =>
      $composableBuilder(column: $table.allPartsAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get quizDoneAt =>
      $composableBuilder(column: $table.quizDoneAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => ColumnOrderings(column));
}

class $$PlantProgressTableAnnotationComposer extends Composer<_$AppDatabase, $PlantProgressTable> {
  $$PlantProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plantId => $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<DateTime> get exploredAt =>
      $composableBuilder(column: $table.exploredAt, builder: (column) => column);

  GeneratedColumn<int> get partsFound => $composableBuilder(column: $table.partsFound, builder: (column) => column);

  GeneratedColumn<DateTime> get allPartsAt =>
      $composableBuilder(column: $table.allPartsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get quizDoneAt =>
      $composableBuilder(column: $table.quizDoneAt, builder: (column) => column);

  GeneratedColumn<int> get bestScore => $composableBuilder(column: $table.bestScore, builder: (column) => column);
}

class $$PlantProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantProgressTable,
          PlantProgressRow,
          $$PlantProgressTableFilterComposer,
          $$PlantProgressTableOrderingComposer,
          $$PlantProgressTableAnnotationComposer,
          $$PlantProgressTableCreateCompanionBuilder,
          $$PlantProgressTableUpdateCompanionBuilder,
          (PlantProgressRow, BaseReferences<_$AppDatabase, $PlantProgressTable, PlantProgressRow>),
          PlantProgressRow,
          PrefetchHooks Function()
        > {
  $$PlantProgressTableTableManager(_$AppDatabase db, $PlantProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlantProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlantProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlantProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> plantId = const Value.absent(),
                Value<DateTime?> exploredAt = const Value.absent(),
                Value<int> partsFound = const Value.absent(),
                Value<DateTime?> allPartsAt = const Value.absent(),
                Value<DateTime?> quizDoneAt = const Value.absent(),
                Value<int?> bestScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantProgressCompanion(
                plantId: plantId,
                exploredAt: exploredAt,
                partsFound: partsFound,
                allPartsAt: allPartsAt,
                quizDoneAt: quizDoneAt,
                bestScore: bestScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String plantId,
                Value<DateTime?> exploredAt = const Value.absent(),
                Value<int> partsFound = const Value.absent(),
                Value<DateTime?> allPartsAt = const Value.absent(),
                Value<DateTime?> quizDoneAt = const Value.absent(),
                Value<int?> bestScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantProgressCompanion.insert(
                plantId: plantId,
                exploredAt: exploredAt,
                partsFound: partsFound,
                allPartsAt: allPartsAt,
                quizDoneAt: quizDoneAt,
                bestScore: bestScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlantProgressTable, PlantProgressRow>(table),
                  BaseReferences<_$AppDatabase, $PlantProgressTable, PlantProgressRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlantProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantProgressTable,
      PlantProgressRow,
      $$PlantProgressTableFilterComposer,
      $$PlantProgressTableOrderingComposer,
      $$PlantProgressTableAnnotationComposer,
      $$PlantProgressTableCreateCompanionBuilder,
      $$PlantProgressTableUpdateCompanionBuilder,
      (PlantProgressRow, BaseReferences<_$AppDatabase, $PlantProgressTable, PlantProgressRow>),
      PlantProgressRow,
      PrefetchHooks Function()
    >;
typedef $$QuizAttemptsTableCreateCompanionBuilder = QuizAttemptsCompanion Function({
  Value<int> id,
  required String kind,
  Value<String?> plantId,
  required int total,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> score,
});
typedef $$QuizAttemptsTableUpdateCompanionBuilder = QuizAttemptsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String?> plantId,
  Value<int> total,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<int?> score,
});

final class $$QuizAttemptsTableReferences extends BaseReferences<_$AppDatabase, $QuizAttemptsTable, QuizAttempt> {
  $$QuizAttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuizAnswersTable, List<QuizAnswer>> _quizAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.quizAnswers, aliasName: 'quiz_attempts__id__quiz_answers__attempt_id');

  $$QuizAnswersTableProcessedTableManager get quizAnswersRefs {
    final manager = $$QuizAnswersTableTableManager(
      $_db,
      $_db.quizAnswers,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizAnswersRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuizAttemptsTableFilterComposer extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(column: $table.score, builder: (column) => ColumnFilters(column));

  Expression<bool> quizAnswersRefs(Expression<bool> Function($$QuizAnswersTableFilterComposer f) f) {
    final $$QuizAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$QuizAnswersTableFilterComposer(
            $db: $db,
            $table: $db.quizAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuizAttemptsTableOrderingComposer extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => ColumnOrderings(column));
}

class $$QuizAttemptsTableAnnotationComposer extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get plantId => $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<int> get total => $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt => $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt =>
      $composableBuilder(column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<int> get score => $composableBuilder(column: $table.score, builder: (column) => column);

  Expression<T> quizAnswersRefs<T extends Object>(Expression<T> Function($$QuizAnswersTableAnnotationComposer a) f) {
    final $$QuizAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$QuizAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.quizAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuizAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizAttemptsTable,
          QuizAttempt,
          $$QuizAttemptsTableFilterComposer,
          $$QuizAttemptsTableOrderingComposer,
          $$QuizAttemptsTableAnnotationComposer,
          $$QuizAttemptsTableCreateCompanionBuilder,
          $$QuizAttemptsTableUpdateCompanionBuilder,
          (QuizAttempt, $$QuizAttemptsTableReferences),
          QuizAttempt,
          PrefetchHooks Function({bool quizAnswersRefs})
        > {
  $$QuizAttemptsTableTableManager(_$AppDatabase db, $QuizAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$QuizAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$QuizAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$QuizAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
              }) => QuizAttemptsCompanion(
                id: id,
                kind: kind,
                plantId: plantId,
                total: total,
                startedAt: startedAt,
                finishedAt: finishedAt,
                score: score,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<String?> plantId = const Value.absent(),
                required int total,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
              }) => QuizAttemptsCompanion.insert(
                id: id,
                kind: kind,
                plantId: plantId,
                total: total,
                startedAt: startedAt,
                finishedAt: finishedAt,
                score: score,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$QuizAttemptsTable, QuizAttempt>(table), $$QuizAttemptsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({quizAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (quizAnswersRefs) db.quizAnswers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quizAnswersRefs)
                    await $_getPrefetchedData<QuizAttempt, $QuizAttemptsTable, QuizAnswer>(
                      currentTable: table,
                      referencedTable: $$QuizAttemptsTableReferences._quizAnswersRefsTable(db),
                      managerFromTypedResult: (p0) => $$QuizAttemptsTableReferences(db, table, p0).quizAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.attemptId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuizAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizAttemptsTable,
      QuizAttempt,
      $$QuizAttemptsTableFilterComposer,
      $$QuizAttemptsTableOrderingComposer,
      $$QuizAttemptsTableAnnotationComposer,
      $$QuizAttemptsTableCreateCompanionBuilder,
      $$QuizAttemptsTableUpdateCompanionBuilder,
      (QuizAttempt, $$QuizAttemptsTableReferences),
      QuizAttempt,
      PrefetchHooks Function({bool quizAnswersRefs})
    >;
typedef $$QuizAnswersTableCreateCompanionBuilder = QuizAnswersCompanion Function({
  Value<int> id,
  required int attemptId,
  required String questionId,
  required String chosen,
  required bool correct,
  required DateTime answeredAt,
});
typedef $$QuizAnswersTableUpdateCompanionBuilder = QuizAnswersCompanion Function({
  Value<int> id,
  Value<int> attemptId,
  Value<String> questionId,
  Value<String> chosen,
  Value<bool> correct,
  Value<DateTime> answeredAt,
});

final class $$QuizAnswersTableReferences extends BaseReferences<_$AppDatabase, $QuizAnswersTable, QuizAnswer> {
  $$QuizAnswersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuizAttemptsTable _attemptIdTable(_$AppDatabase db) =>
      db.quizAttempts.createAlias('quiz_answers__attempt_id__quiz_attempts__id');

  $$QuizAttemptsTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$QuizAttemptsTableTableManager($_db, $_db.quizAttempts).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuizAnswersTableFilterComposer extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId =>
      $composableBuilder(column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chosen =>
      $composableBuilder(column: $table.chosen, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get answeredAt =>
      $composableBuilder(column: $table.answeredAt, builder: (column) => ColumnFilters(column));

  $$QuizAttemptsTableFilterComposer get attemptId {
    final $$QuizAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$QuizAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizAnswersTableOrderingComposer extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId =>
      $composableBuilder(column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chosen =>
      $composableBuilder(column: $table.chosen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get answeredAt =>
      $composableBuilder(column: $table.answeredAt, builder: (column) => ColumnOrderings(column));

  $$QuizAttemptsTableOrderingComposer get attemptId {
    final $$QuizAttemptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$QuizAttemptsTableOrderingComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizAnswersTableAnnotationComposer extends Composer<_$AppDatabase, $QuizAnswersTable> {
  $$QuizAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get chosen => $composableBuilder(column: $table.chosen, builder: (column) => column);

  GeneratedColumn<bool> get correct => $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt =>
      $composableBuilder(column: $table.answeredAt, builder: (column) => column);

  $$QuizAttemptsTableAnnotationComposer get attemptId {
    final $$QuizAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$QuizAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizAnswersTable,
          QuizAnswer,
          $$QuizAnswersTableFilterComposer,
          $$QuizAnswersTableOrderingComposer,
          $$QuizAnswersTableAnnotationComposer,
          $$QuizAnswersTableCreateCompanionBuilder,
          $$QuizAnswersTableUpdateCompanionBuilder,
          (QuizAnswer, $$QuizAnswersTableReferences),
          QuizAnswer,
          PrefetchHooks Function({bool attemptId})
        > {
  $$QuizAnswersTableTableManager(_$AppDatabase db, $QuizAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$QuizAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$QuizAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$QuizAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> chosen = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => QuizAnswersCompanion(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                chosen: chosen,
                correct: correct,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attemptId,
                required String questionId,
                required String chosen,
                required bool correct,
                required DateTime answeredAt,
              }) => QuizAnswersCompanion.insert(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                chosen: chosen,
                correct: correct,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable<$QuizAnswersTable, QuizAnswer>(table), $$QuizAnswersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attemptId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attemptId,
                        referencedTable: $$QuizAnswersTableReferences._attemptIdTable(db),
                        referencedColumn: $$QuizAnswersTableReferences._attemptIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuizAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizAnswersTable,
      QuizAnswer,
      $$QuizAnswersTableFilterComposer,
      $$QuizAnswersTableOrderingComposer,
      $$QuizAnswersTableAnnotationComposer,
      $$QuizAnswersTableCreateCompanionBuilder,
      $$QuizAnswersTableUpdateCompanionBuilder,
      (QuizAnswer, $$QuizAnswersTableReferences),
      QuizAnswer,
      PrefetchHooks Function({bool attemptId})
    >;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String item,
  required int price,
  required DateTime boughtAt,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> item,
  Value<int> price,
  Value<DateTime> boughtAt,
  Value<int> rowid,
});

class $$PurchasesTableFilterComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get item => $composableBuilder(column: $table.item, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get price => $composableBuilder(column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get boughtAt =>
      $composableBuilder(column: $table.boughtAt, builder: (column) => ColumnFilters(column));
}

class $$PurchasesTableOrderingComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get boughtAt =>
      $composableBuilder(column: $table.boughtAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchasesTableAnnotationComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get item => $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<int> get price => $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get boughtAt => $composableBuilder(column: $table.boughtAt, builder: (column) => column);
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          PurchaseRow,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (PurchaseRow, BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>),
          PurchaseRow,
          PrefetchHooks Function()
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> item = const Value.absent(),
            Value<int> price = const Value.absent(),
            Value<DateTime> boughtAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PurchasesCompanion(item: item, price: price, boughtAt: boughtAt, rowid: rowid),
          createCompanionCallback: ({
            required String item,
            required int price,
            required DateTime boughtAt,
            Value<int> rowid = const Value.absent(),
          }) => PurchasesCompanion.insert(item: item, price: price, boughtAt: boughtAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchasesTable, PurchaseRow>(table),
                  BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      PurchaseRow,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (PurchaseRow, BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>),
      PurchaseRow,
      PrefetchHooks Function()
    >;
typedef $$GameWinsTableCreateCompanionBuilder = GameWinsCompanion Function({
  required String game,
  required String plantId,
  required DateTime wonAt,
  Value<int> rowid,
});
typedef $$GameWinsTableUpdateCompanionBuilder = GameWinsCompanion Function({
  Value<String> game,
  Value<String> plantId,
  Value<DateTime> wonAt,
  Value<int> rowid,
});

class $$GameWinsTableFilterComposer extends Composer<_$AppDatabase, $GameWinsTable> {
  $$GameWinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get game => $composableBuilder(column: $table.game, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get wonAt =>
      $composableBuilder(column: $table.wonAt, builder: (column) => ColumnFilters(column));
}

class $$GameWinsTableOrderingComposer extends Composer<_$AppDatabase, $GameWinsTable> {
  $$GameWinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get wonAt =>
      $composableBuilder(column: $table.wonAt, builder: (column) => ColumnOrderings(column));
}

class $$GameWinsTableAnnotationComposer extends Composer<_$AppDatabase, $GameWinsTable> {
  $$GameWinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get game => $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<String> get plantId => $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<DateTime> get wonAt => $composableBuilder(column: $table.wonAt, builder: (column) => column);
}

class $$GameWinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameWinsTable,
          GameWinRow,
          $$GameWinsTableFilterComposer,
          $$GameWinsTableOrderingComposer,
          $$GameWinsTableAnnotationComposer,
          $$GameWinsTableCreateCompanionBuilder,
          $$GameWinsTableUpdateCompanionBuilder,
          (GameWinRow, BaseReferences<_$AppDatabase, $GameWinsTable, GameWinRow>),
          GameWinRow,
          PrefetchHooks Function()
        > {
  $$GameWinsTableTableManager(_$AppDatabase db, $GameWinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GameWinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GameWinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GameWinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> game = const Value.absent(),
            Value<String> plantId = const Value.absent(),
            Value<DateTime> wonAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => GameWinsCompanion(game: game, plantId: plantId, wonAt: wonAt, rowid: rowid),
          createCompanionCallback: ({
            required String game,
            required String plantId,
            required DateTime wonAt,
            Value<int> rowid = const Value.absent(),
          }) => GameWinsCompanion.insert(game: game, plantId: plantId, wonAt: wonAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameWinsTable, GameWinRow>(table),
                  BaseReferences<_$AppDatabase, $GameWinsTable, GameWinRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameWinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameWinsTable,
      GameWinRow,
      $$GameWinsTableFilterComposer,
      $$GameWinsTableOrderingComposer,
      $$GameWinsTableAnnotationComposer,
      $$GameWinsTableCreateCompanionBuilder,
      $$GameWinsTableUpdateCompanionBuilder,
      (GameWinRow, BaseReferences<_$AppDatabase, $GameWinsTable, GameWinRow>),
      GameWinRow,
      PrefetchHooks Function()
    >;
typedef $$BadgeWinsTableCreateCompanionBuilder = BadgeWinsCompanion Function({
  required String badge,
  required DateTime wonAt,
  Value<int> rowid,
});
typedef $$BadgeWinsTableUpdateCompanionBuilder = BadgeWinsCompanion Function({
  Value<String> badge,
  Value<DateTime> wonAt,
  Value<int> rowid,
});

class $$BadgeWinsTableFilterComposer extends Composer<_$AppDatabase, $BadgeWinsTable> {
  $$BadgeWinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badge =>
      $composableBuilder(column: $table.badge, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get wonAt =>
      $composableBuilder(column: $table.wonAt, builder: (column) => ColumnFilters(column));
}

class $$BadgeWinsTableOrderingComposer extends Composer<_$AppDatabase, $BadgeWinsTable> {
  $$BadgeWinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badge =>
      $composableBuilder(column: $table.badge, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get wonAt =>
      $composableBuilder(column: $table.wonAt, builder: (column) => ColumnOrderings(column));
}

class $$BadgeWinsTableAnnotationComposer extends Composer<_$AppDatabase, $BadgeWinsTable> {
  $$BadgeWinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badge => $composableBuilder(column: $table.badge, builder: (column) => column);

  GeneratedColumn<DateTime> get wonAt => $composableBuilder(column: $table.wonAt, builder: (column) => column);
}

class $$BadgeWinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgeWinsTable,
          BadgeWinRow,
          $$BadgeWinsTableFilterComposer,
          $$BadgeWinsTableOrderingComposer,
          $$BadgeWinsTableAnnotationComposer,
          $$BadgeWinsTableCreateCompanionBuilder,
          $$BadgeWinsTableUpdateCompanionBuilder,
          (BadgeWinRow, BaseReferences<_$AppDatabase, $BadgeWinsTable, BadgeWinRow>),
          BadgeWinRow,
          PrefetchHooks Function()
        > {
  $$BadgeWinsTableTableManager(_$AppDatabase db, $BadgeWinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BadgeWinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BadgeWinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BadgeWinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> badge = const Value.absent(),
            Value<DateTime> wonAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => BadgeWinsCompanion(badge: badge, wonAt: wonAt, rowid: rowid),
          createCompanionCallback: ({
            required String badge,
            required DateTime wonAt,
            Value<int> rowid = const Value.absent(),
          }) => BadgeWinsCompanion.insert(badge: badge, wonAt: wonAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgeWinsTable, BadgeWinRow>(table),
                  BaseReferences<_$AppDatabase, $BadgeWinsTable, BadgeWinRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgeWinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgeWinsTable,
      BadgeWinRow,
      $$BadgeWinsTableFilterComposer,
      $$BadgeWinsTableOrderingComposer,
      $$BadgeWinsTableAnnotationComposer,
      $$BadgeWinsTableCreateCompanionBuilder,
      $$BadgeWinsTableUpdateCompanionBuilder,
      (BadgeWinRow, BaseReferences<_$AppDatabase, $BadgeWinsTable, BadgeWinRow>),
      BadgeWinRow,
      PrefetchHooks Function()
    >;
typedef $$GardenSpotsTableCreateCompanionBuilder = GardenSpotsCompanion Function({
  required String piece,
  required double x,
  required double y,
  Value<int> rowid,
});
typedef $$GardenSpotsTableUpdateCompanionBuilder = GardenSpotsCompanion Function({
  Value<String> piece,
  Value<double> x,
  Value<double> y,
  Value<int> rowid,
});

class $$GardenSpotsTableFilterComposer extends Composer<_$AppDatabase, $GardenSpotsTable> {
  $$GardenSpotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get piece =>
      $composableBuilder(column: $table.piece, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get x => $composableBuilder(column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get y => $composableBuilder(column: $table.y, builder: (column) => ColumnFilters(column));
}

class $$GardenSpotsTableOrderingComposer extends Composer<_$AppDatabase, $GardenSpotsTable> {
  $$GardenSpotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get piece =>
      $composableBuilder(column: $table.piece, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get x => $composableBuilder(column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get y => $composableBuilder(column: $table.y, builder: (column) => ColumnOrderings(column));
}

class $$GardenSpotsTableAnnotationComposer extends Composer<_$AppDatabase, $GardenSpotsTable> {
  $$GardenSpotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get piece => $composableBuilder(column: $table.piece, builder: (column) => column);

  GeneratedColumn<double> get x => $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y => $composableBuilder(column: $table.y, builder: (column) => column);
}

class $$GardenSpotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GardenSpotsTable,
          GardenSpotRow,
          $$GardenSpotsTableFilterComposer,
          $$GardenSpotsTableOrderingComposer,
          $$GardenSpotsTableAnnotationComposer,
          $$GardenSpotsTableCreateCompanionBuilder,
          $$GardenSpotsTableUpdateCompanionBuilder,
          (GardenSpotRow, BaseReferences<_$AppDatabase, $GardenSpotsTable, GardenSpotRow>),
          GardenSpotRow,
          PrefetchHooks Function()
        > {
  $$GardenSpotsTableTableManager(_$AppDatabase db, $GardenSpotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GardenSpotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GardenSpotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GardenSpotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> piece = const Value.absent(),
            Value<double> x = const Value.absent(),
            Value<double> y = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => GardenSpotsCompanion(piece: piece, x: x, y: y, rowid: rowid),
          createCompanionCallback: ({
            required String piece,
            required double x,
            required double y,
            Value<int> rowid = const Value.absent(),
          }) => GardenSpotsCompanion.insert(piece: piece, x: x, y: y, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GardenSpotsTable, GardenSpotRow>(table),
                  BaseReferences<_$AppDatabase, $GardenSpotsTable, GardenSpotRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GardenSpotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GardenSpotsTable,
      GardenSpotRow,
      $$GardenSpotsTableFilterComposer,
      $$GardenSpotsTableOrderingComposer,
      $$GardenSpotsTableAnnotationComposer,
      $$GardenSpotsTableCreateCompanionBuilder,
      $$GardenSpotsTableUpdateCompanionBuilder,
      (GardenSpotRow, BaseReferences<_$AppDatabase, $GardenSpotsTable, GardenSpotRow>),
      GardenSpotRow,
      PrefetchHooks Function()
    >;
typedef $$DailyCareTableCreateCompanionBuilder = DailyCareCompanion Function({
  required String kind,
  required String day,
  Value<int> rowid,
});
typedef $$DailyCareTableUpdateCompanionBuilder = DailyCareCompanion Function({
  Value<String> kind,
  Value<String> day,
  Value<int> rowid,
});

class $$DailyCareTableFilterComposer extends Composer<_$AppDatabase, $DailyCareTable> {
  $$DailyCareTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));
}

class $$DailyCareTableOrderingComposer extends Composer<_$AppDatabase, $DailyCareTable> {
  $$DailyCareTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));
}

class $$DailyCareTableAnnotationComposer extends Composer<_$AppDatabase, $DailyCareTable> {
  $$DailyCareTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$DailyCareTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyCareTable,
          DailyCareData,
          $$DailyCareTableFilterComposer,
          $$DailyCareTableOrderingComposer,
          $$DailyCareTableAnnotationComposer,
          $$DailyCareTableCreateCompanionBuilder,
          $$DailyCareTableUpdateCompanionBuilder,
          (DailyCareData, BaseReferences<_$AppDatabase, $DailyCareTable, DailyCareData>),
          DailyCareData,
          PrefetchHooks Function()
        > {
  $$DailyCareTableTableManager(_$AppDatabase db, $DailyCareTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DailyCareTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DailyCareTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DailyCareTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> kind = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => DailyCareCompanion(kind: kind, day: day, rowid: rowid),
          createCompanionCallback: ({
            required String kind,
            required String day,
            Value<int> rowid = const Value.absent(),
          }) => DailyCareCompanion.insert(kind: kind, day: day, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyCareTable, DailyCareData>(table),
                  BaseReferences<_$AppDatabase, $DailyCareTable, DailyCareData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyCareTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyCareTable,
      DailyCareData,
      $$DailyCareTableFilterComposer,
      $$DailyCareTableOrderingComposer,
      $$DailyCareTableAnnotationComposer,
      $$DailyCareTableCreateCompanionBuilder,
      $$DailyCareTableUpdateCompanionBuilder,
      (DailyCareData, BaseReferences<_$AppDatabase, $DailyCareTable, DailyCareData>),
      DailyCareData,
      PrefetchHooks Function()
    >;
typedef $$ColouringsTableCreateCompanionBuilder = ColouringsCompanion Function({
  required String plantId,
  required String picture,
  Value<DateTime?> hungAt,
  Value<int> rowid,
});
typedef $$ColouringsTableUpdateCompanionBuilder = ColouringsCompanion Function({
  Value<String> plantId,
  Value<String> picture,
  Value<DateTime?> hungAt,
  Value<int> rowid,
});

class $$ColouringsTableFilterComposer extends Composer<_$AppDatabase, $ColouringsTable> {
  $$ColouringsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get picture =>
      $composableBuilder(column: $table.picture, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get hungAt =>
      $composableBuilder(column: $table.hungAt, builder: (column) => ColumnFilters(column));
}

class $$ColouringsTableOrderingComposer extends Composer<_$AppDatabase, $ColouringsTable> {
  $$ColouringsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get picture =>
      $composableBuilder(column: $table.picture, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get hungAt =>
      $composableBuilder(column: $table.hungAt, builder: (column) => ColumnOrderings(column));
}

class $$ColouringsTableAnnotationComposer extends Composer<_$AppDatabase, $ColouringsTable> {
  $$ColouringsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plantId => $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get picture => $composableBuilder(column: $table.picture, builder: (column) => column);

  GeneratedColumn<DateTime> get hungAt => $composableBuilder(column: $table.hungAt, builder: (column) => column);
}

class $$ColouringsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColouringsTable,
          ColouringRow,
          $$ColouringsTableFilterComposer,
          $$ColouringsTableOrderingComposer,
          $$ColouringsTableAnnotationComposer,
          $$ColouringsTableCreateCompanionBuilder,
          $$ColouringsTableUpdateCompanionBuilder,
          (ColouringRow, BaseReferences<_$AppDatabase, $ColouringsTable, ColouringRow>),
          ColouringRow,
          PrefetchHooks Function()
        > {
  $$ColouringsTableTableManager(_$AppDatabase db, $ColouringsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ColouringsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ColouringsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ColouringsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> plantId = const Value.absent(),
            Value<String> picture = const Value.absent(),
            Value<DateTime?> hungAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ColouringsCompanion(plantId: plantId, picture: picture, hungAt: hungAt, rowid: rowid),
          createCompanionCallback: ({
            required String plantId,
            required String picture,
            Value<DateTime?> hungAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ColouringsCompanion.insert(plantId: plantId, picture: picture, hungAt: hungAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ColouringsTable, ColouringRow>(table),
                  BaseReferences<_$AppDatabase, $ColouringsTable, ColouringRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ColouringsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColouringsTable,
      ColouringRow,
      $$ColouringsTableFilterComposer,
      $$ColouringsTableOrderingComposer,
      $$ColouringsTableAnnotationComposer,
      $$ColouringsTableCreateCompanionBuilder,
      $$ColouringsTableUpdateCompanionBuilder,
      (ColouringRow, BaseReferences<_$AppDatabase, $ColouringsTable, ColouringRow>),
      ColouringRow,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({required String day, Value<int> rowid});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({Value<String> day, Value<int> rowid});

class $$VisitsTableFilterComposer extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));
}

class $$VisitsTableOrderingComposer extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));
}

class $$VisitsTableAnnotationComposer extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
          Visit,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => VisitsCompanion(day: day, rowid: rowid),
          createCompanionCallback: ({required String day, Value<int> rowid = const Value.absent()}) =>
              VisitsCompanion.insert(day: day, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, Visit>(table),
                  BaseReferences<_$AppDatabase, $VisitsTable, Visit>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
      Visit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfileTableTableManager get profile => $$ProfileTableTableManager(_db, _db.profile);
  $$LeavesLogTableTableManager get leavesLog => $$LeavesLogTableTableManager(_db, _db.leavesLog);
  $$PlantProgressTableTableManager get plantProgress => $$PlantProgressTableTableManager(_db, _db.plantProgress);
  $$QuizAttemptsTableTableManager get quizAttempts => $$QuizAttemptsTableTableManager(_db, _db.quizAttempts);
  $$QuizAnswersTableTableManager get quizAnswers => $$QuizAnswersTableTableManager(_db, _db.quizAnswers);
  $$PurchasesTableTableManager get purchases => $$PurchasesTableTableManager(_db, _db.purchases);
  $$GameWinsTableTableManager get gameWins => $$GameWinsTableTableManager(_db, _db.gameWins);
  $$BadgeWinsTableTableManager get badgeWins => $$BadgeWinsTableTableManager(_db, _db.badgeWins);
  $$GardenSpotsTableTableManager get gardenSpots => $$GardenSpotsTableTableManager(_db, _db.gardenSpots);
  $$DailyCareTableTableManager get dailyCare => $$DailyCareTableTableManager(_db, _db.dailyCare);
  $$ColouringsTableTableManager get colourings => $$ColouringsTableTableManager(_db, _db.colourings);
  $$VisitsTableTableManager get visits => $$VisitsTableTableManager(_db, _db.visits);
}
