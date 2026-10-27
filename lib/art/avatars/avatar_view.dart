import 'package:flutter/widgets.dart';

import 'animal_avatar.dart';
import 'avatar_painter.dart';
import 'avatar_spec.dart';

export 'animal_avatar.dart' show AnimalAvatar, AnimalIds;
export 'avatar_painter.dart' show AvatarLook;
export 'avatar_spec.dart';

/// A round avatar portrait. Static, so it is cached in its own layer.
class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.avatarId, this.size = 64, this.look = AvatarLook.outfits});

  final String? avatarId;
  final double size;
  final AvatarLook look;

  @override
  Widget build(BuildContext context) {
    final animal = AnimalIds.parse(avatarId);
    if (animal != null) return RepaintBoundary(child: AnimalAvatarView(animal, size: size));
    final spec = AvatarSpec.byId(avatarId);
    return Semantics(
      label: spec.label,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: AvatarPainter(spec, look: look),
        ),
      ),
    );
  }
}
