class_name PartyFollowAI

## Shared movement logic for any party member (including the Player, when
## benched) that isn't currently under direct player control. Kept as a
## static, stateless function so both player.gd and party_member.gd can call
## the same behavior instead of duplicating it.

const FOLLOW_DISTANCE := 40.0   ## how far behind the leader before catching up
const ENGAGE_RANGE := 16.0      ## how close to a hostile target before holding position to fight

## Returns a normalized direction (or Vector2.ZERO to hold position).
## target: the character's own Vision.entity (already faction-filtered - see vision.gd),
## or null if nothing hostile is in sight.
static func get_direction(self_pos: Vector2, leader_pos: Vector2, target) -> Vector2:
	if target != null and is_instance_valid(target):
		var to_target: Vector2 = target.global_position - self_pos
		if to_target.length() > ENGAGE_RANGE:
			return to_target.normalized()
		return Vector2.ZERO  # close enough - contact damage handles the rest

	var to_leader: Vector2 = leader_pos - self_pos
	if to_leader.length() > FOLLOW_DISTANCE:
		return to_leader.normalized()
	return Vector2.ZERO
