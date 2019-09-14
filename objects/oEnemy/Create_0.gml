/// @description 인공지능 초기화
/*
	믈리 변수 선언
*/
velocity_x = 0
velocity_y = 0
friction_x = 0.6
friction_x_air = 0.1
friction_y = 0
velocity_x_limit = 4
velocity_y_min = -20
velocity_y_max = 30

velocity_gravity_default = 0.6

movement_x = 0
jump_velocity = -13

/*
	공격에 사용될 변수 선언
*/
attacking = false											// 현재 공격 중인지 여부
attacking_period = room_speed * 0.4		// 한 공격을 완료하기까지 걸리는 시간
attacking_time = attacking_period			// 공격 완료 카운터
attack_delay = 0											// 공격 주기 카운터

attack_adjust = false									// 공격 전에 좌우 이동을 해야만 하는지 여부
attack_adjust_jump = false						// 좌우 이동 중에 벽에 닿으면 점프를 해야하는지 여부
attack_enemy = oPlayer								// 공격의 목표가 되는 객체의 종류
attack_target = noone									// 공격의 목표 개체

/*
	 적 객체가 들고 있는 무기를 결정합니다. 4분의 1 확률로 검이, 4분의 3 확률로 활로 결정됩니다.
	무기 종류에 따라 적의 기본적인 공격 속성들이 달라집니다. 하지만 인공지능 작동 방식은 같습니다.
*/
attack_type = choose(weapon.sword, weapon.bow, weapon.bow, weapon.bow)

/*
		검보다 활이 사정거리가 길고
								 더 높이 공격할 수 있으며
								 공격 주기가 더 깁니다.

	attack_sight: 시야
	attack_range: 무기의 사정거리
	attack_angle: 위쪽으로 공격을 시도할 때 가능한 최대 각도
	attack_delay_duration: 공격 주기(쿨타임)
*/
if attack_type == weapon.sword { // 검
	attack_sight = 320
	attack_range = 48
	attack_angle = 45
	attack_delay_duration = room_speed * 0.5
} else if attack_type == weapon.bow  { // 활
	attack_sight = 320
	attack_range = 208
	attack_angle = 80
	attack_delay_duration = room_speed * 1.2
}

/*
	목표를 검색할 때 제한점을 두기 위한 변수들입니다.
	attack_width_max: 사거리 내에 들어온 적을 탐색하고, 공격할 최대 거리
	attack_height_max: 점프하지 않고 적을 검색하고, 공격할 최대 거리
	attack_collide_search_width_max: 적을 발견했으나 접근할 방법이 없을 때 검색에 사용할 최대 거리
*/
attack_width_max = max(32, lengthdir_x(attack_range, attack_angle))
attack_height_max = -lengthdir_y(attack_range, attack_angle)
attack_collide_search_width_max = attack_width_max * 3

/*
	그리기 설정
*/
imxs = 1
image_speed = 0
draw_set_color($0) // 검정색
draw_set_halign(fa_center)
draw_set_valign(fa_bottom)
