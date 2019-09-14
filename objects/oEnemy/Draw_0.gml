draw_sprite_ext(sprite_index, 0, x, y, imxs, 1, 0, $ffffff, 1)

/*
	적이 공격 중이라면 노란색으로 반짝입니다.
	여기서 사용하는 투명도 식은 (1 - attacking_time / attacking_period) 입니다.

	1. 맨 처음에는 공격 중이 아니므로
		(식) == (1 - 1) == 0 이 되어 그려지지 않습니다.

	2. 공격을 시도한 순간에는 attacking = true; attacking_time = 0 이 되어
		(식) == (1 - 0) == 1 이 됩니다.

	3. 이후 attacking_time 이 증가함에 따라 attacking_time / attacking_period 는 1로 수렴합니다.

	4. 공격이 끝나면 다시
		(식) == (1 - 1) == 0 이 됩니다.
*/
draw_sprite_ext(sprite_index, 1, x, y, imxs, 1, 0, $ffffff, 1 - attacking_time / attacking_period)

// 들고있는 무기의 종류를 표시합니다.
draw_text(x, bbox_top - 2, (attack_type == weapon.none) ? "None" : ((attack_type == weapon.sword) ? "Sword" : ((attack_type == weapon.bow) ? "Bow" : "Error!")))
