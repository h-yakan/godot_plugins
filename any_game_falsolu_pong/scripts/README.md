# scripts/

Falsolu pong fizik script'leri.

## Dosyalar

| Dosya | Sınıf | Rol |
|-------|-------|-----|
| `ga_pong_ball.gd` | `GaPongBall` | RigidBody2D: hız rampası, Magnus eğrisi, spin |
| `ga_pong_paddle.gd` | `GaPongPaddle` | Eksen kilitli paddle hareketi |
| `ga_pong_court.gd` | `GaPongCourt` | 4 duvar + ball/paddle spawn |

## GaPongBall export'ları

- `initial_ball_speed`, `speed_multiplier`, `max_ball_speed`
- `multiplier_angular_velocity`, `curve_multiplier`, `max_curve_angle`

Paddle algısı: `pong_paddle` grubu (node adı değil).

## GaPongBall sinyalleri

- `ball_launched(velocity)`
- `ball_hit_paddle(paddle)`
- `ball_hit_wall(wall)`

## GaPongPaddle export'ları

- `speed`, `move_axis` (`X` / `Y`)
- `input_negative`, `input_positive` — InputMap action adları

Otomatik grup: `pong_paddle`

## GaPongCourt export'ları

- `court_half_width`, `court_top`, `court_bottom`
- `ball_scene`, `paddle_scene`
- `auto_spawn_ball`, `auto_spawn_paddle`
- `default_paddle_position`, `default_ball_position`

Sinyaller: `ball_spawned`, `paddle_spawned`
