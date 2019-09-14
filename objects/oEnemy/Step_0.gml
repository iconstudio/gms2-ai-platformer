/// @description 동작
/*
	이 적 객체는 일반적인 공격 주기 외에도 하나의 공격을 끝내는데 걸리는 동작 시전 시간을 갖고 있습니다.
	많은 사람들이 고려하는 부분은 아니지만 더 재미있는 행동을 보여줄 수 있을 것 같아서 넣었습니다.
*/
if attack_delay > 0
	attack_delay--
if attacking {
	if attacking_time < attacking_period { // 공격 동작 시전 중
		attacking_time++
	} else { // 공격 지연 시간 시작
		attacking = false
		attack_delay = attack_delay_duration
	}
}


// 가장 가까운 적을 찾아냅니다.
attack_target = instance_nearest(x, y, attack_enemy)
attack_adjust = false
attack_adjust_jump = false
if instance_exists(attack_target) {
	var distance = distance_to_point(attack_target.x, attack_target.y)

	// 기본적으로 적과 플레이어 사이의 거리는 시야보다 짧아야 합니다.
	//
	if distance <= attack_sight {
		// 플레이어와 자신 사이에 장애물이 있는지, 거리가 사정거리보다 긴지를 검사합니다.
		//
		var check_linec = collision_line(x, y, attack_target.x, attack_target.y, oBlock, false, true)
		var check_range = distance > attack_range

		// 만약 장애물이 있거나 멀리 있다면 이동을 시작합니다.
		if check_linec or check_range
			attack_adjust = true

		// 공격 중이 아닐 때에만 이동합니다.
		if attack_adjust and !attacking {
			if !check_linec {
				// 중간에 장애물이 없을 때
				//
				movement_x = 0
				if attack_target.y < y - attack_height_max {
					// 플레이어가 너무 높이 있을 때

					if !place_free(x, y + 1) and place_free(x, y - 1) {
						// 점프 공격 시도
						velocity_y = jump_velocity
						attack_adjust_jump = true
					}

					event_user(0) // 좌우 이동을 사용자 이벤트에 넣어 언제라도 쓸 수 있게끔 간소화 시켰습니다.
				} else if attack_target.y < y + 16 {
					// 플레이어가 적당한 위치에 있을 때

					/*
						 자연스러운 공격 패턴을 위해 지상으로 수직하는 직선과 자신과 목표 사이의 벡터를 내적하여
						정보를 알아냅니다. 내적은 목표와 자신 사이의 각도에 의해 결정됩니다. 내적의 값이 작아지면
						사이 각도가 커지고, 0 일때는 직각이며, 0 초과면 예각입니다. 이 각도는 attack_angle 보다 
						커질 수 없습니다. 커지면 목표가 더 멀리 있다는 뜻입니다.

						 attack_angle에 의해 결정된 최대 탐색 거리 attack_width_max에 맞춰서 이동을 해줘야 하는데, 
						가장 큰 문제는 이 attack_width_max가 attack_angle으로 결정된 사잇각의 현이지만 정작
						-1 ~ 1 사이의 값이 아닌 어떤 양수이기에 비교가 불가능합니다. 그러나 이 값은 attack_range를
						삼각함수에 넣은 값이기 때문에 무조건 사정거리 attack_range보다 작을 수 밖에 없습니다.
						그래서 정규화를 시켜주어 0 ~ 1 사이의 값으로 만들어주면 이제서야 적이 목표를 공격하기 위해
						접근해야하는 가장 짧은 각도를 알 수 있게 됩니다.
					*/
					var vx1 = 0 // == lengthdir_x(1, 270)
					var vy1 = -1 // == lengthdir_y(1, 270)
					var vx2 = attack_target.x - x
					var vy2 = attack_target.y - y
					// 적절한 거리까지만 이동
					if abs(dot_product(vx1, vy1, vx2, vy2)) > attack_width_max / attack_range
						event_user(0)

				} else if check_range {
					// 플레이어가 너무 낮은 위치에 있을 때
					event_user(0)
				}

			} else {
				// 중간에 장애물이 있을 때에는 가로 이동속도 moment_x 를 0으로 초기화 시키지 않습니다.
				// 조건부로만 초기화 시켜야합니다.
				//
				if attack_target.y < y - attack_height_max {
					// 너무 높은 곳에 플레이어가 있다면 탐색하지 않습니다.

				} else if attack_target.y < y + attack_range * 0.4 {
					/*
						좌우로 일정하게 각을 벌리며 트인 공간을 찾아냅니다.
					*/

					var check_left, check_right, check_left_distance, check_right_distance
					for (var i = 8; i <= attack_collide_search_width_max; i += 8) {
						// 좌우로 벌린 끝자락 범위에서 목표까지 선 충돌 검사를 시행합니다.

						check_left = collision_line(x - i, y, attack_target.x, attack_target.y, oBlock, false, true)
						check_right = collision_line(x + i, y, attack_target.x, attack_target.y, oBlock, false, true)
						if check_left and !check_right {
							// 오른쪽에 장애물이 없다면 오른쪽으로 이동합니다.

							movement_x = 1
							break // 한 방향으로만 이동해도 사이에 장애물로 가려진 상황을 피할 수 있습니다.
						} else if !check_left and check_right {
							// 왼쪽에 장애물이 없다면 왼쪽으로 이동합니다.

							movement_x = -1
							break
						} else if !check_left and !check_right {
							// 양 쪽 다 장애물이 없다면 가까운 쪽으로 이동합니다.
							// 좌우로 벌린 끝자락 좌표에서 목표까지의 거리를 잽니다.

							check_left_distance = point_distance(x - i, y, attack_target.x, attack_target.y)
							check_right_distance = point_distance(x + i, y, attack_target.x, attack_target.y)
							if check_left_distance > check_right_distance
								movement_x = 1
							else if check_left_distance < check_right_distance
								movement_x = -1
							else
								movement_x = choose(-1, -1, 0, 1, 1)
							break
						} else {
							// 모든 경우에 장애물로 가로막혀 있습니다.
						}
					}
				}

				// 점프 시에는 무작위 확률을 섞어 적들이 겹쳐서 움직이는 현상을 방지합니다.
				if !place_free(x, y + 1) and place_free(x, y - 1) and irandom(15) == 0 and attack_target.y < y + attack_range * 0.5 // 점프
					velocity_y = jump_velocity
				attack_adjust_jump = true // 항상 점프를 시도합니다.
			}

		} else {
			// 공격할 때는 정지해야 합니다.
			movement_x = 0

			if !attacking and attack_delay <= 0 { // 공격 주기(쿨타임)가 모두 소진되었을 때
				if attack_type == weapon.sword {
					// 특별히 구현하지는 않았습니다.

				} else if attack_type == weapon.bow {
					// 플레이어를 향해 화살 객체를 발사합니다.

					with instance_create_layer(x, y, oArrow, layer) {
						direction = point_direction(x, y, other.attack_target.x, other.attack_target.y)
						image_angle = direction
						speed = 8
					}
				}
				attacking = true
				attacking_time = 0
			}
		}
	} else {
		// 목표와 너무 멀리 떨어져 있다면 정지합니다.

		movement_x = 0
	}

	// 그냥 image_xscale을 바꿔버리면 벽과 충돌 시엔 껴버리므로 가변수를 두고 조정합니다.
	if x < attack_target.x
		imxs = 1
	else if x > attack_target.x
		imxs = -1
}

/*
	x 좌표가 변하는 부분입니다.
*/
velocity_x += movement_x
if velocity_x != 0 {
	if place_free(x + velocity_x + sign(velocity_x), y) {
		x += velocity_x
	} else {
		if velocity_x > 0
			move_contact_solid(0, abs(velocity_x) + 1)
		else if velocity_x < 0
			move_contact_solid(180, abs(velocity_x) + 1)

		if attack_adjust_jump and movement_x != 0 and irandom(9) == 0 { // 실제로 인공지능이 움직여야만 할 때
			if !place_free(x, y + 1) and place_free(x, y - 1) // 점프
				velocity_y = jump_velocity
		}
		velocity_x = 0
	}
}

/*
	y 좌표가 변하는 부분입니다.
*/
var check_y
if velocity_y < 0
	check_y = y + velocity_y - 1
else
	check_y = y + velocity_y + 1

if !place_free(x, check_y) {
	if velocity_y > 0 {
		move_contact_solid(270, abs(velocity_y) + 1)
		move_outside_solid(90, 1)
	} else if velocity_y < 0 {
		move_contact_solid(90, abs(velocity_y) + 1)
	}
	velocity_y = 0
} else {
	y += velocity_y
	velocity_y += velocity_gravity_default
}

if abs(velocity_x) > velocity_x_limit
	velocity_x = velocity_x_limit * sign(velocity_x)
if velocity_y > velocity_y_max
	velocity_y = velocity_y_max
else if velocity_y < velocity_y_min
	velocity_y = velocity_y_min

if movement_x == 0 and velocity_x != 0 and friction_x != 0 {
	if !place_free(x, y + 1)
		velocity_x -= friction_x * velocity_x
	else
		velocity_x -= friction_x_air * velocity_x
}
if velocity_y != 0 and friction_y != 0
	velocity_y -= friction_y * velocity_y
