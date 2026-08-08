# scenes/

Drop-in pong sahneleri.

## Sahneler

| Sahne | Açıklama |
|-------|----------|
| `ga_pong_court.tscn` | Tam court: duvarlar + otomatik ball/paddle spawn |
| `ga_pong_ball.tscn` | Magnus'lu top (ColorRect görsel) |
| `ga_pong_paddle.tscn` | Yatay paddle (ColorRect görsel) |

## Drop-in kullanım

`ga_pong_court.tscn` instance et — export'lar varsayılan Ricochet boyutlarına ayarlı:

- Court yarı genişlik: 576
- Üst: -320, alt: 192
- Paddle spawn: `(0, 168)`

## Manuel kompozisyon

```
Level
├── GaPongBall
├── GaPongPaddle
└── StaticBody2D × 4   (WorldBoundaryShape2D)
```

## Skor örneği

```gdscript
func _ready() -> void:
    var court := $GaPongCourt
    court.ball_spawned.connect(func(ball: GaPongBall) -> void:
        ball.ball_hit_wall.connect(func(_wall: Node) -> void:
            pass  # skor logic
        )
    )
```

Script detayları: [../scripts/README.md](../scripts/README.md)
