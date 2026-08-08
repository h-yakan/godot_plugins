shader_type canvas_item;

// --- MEVCUT AYARLAR ---
uniform float lid_value : hint_range(0.0, 1.0) = 0.0;
uniform vec4 lid_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float curve_strength : hint_range(-1.0, 1.0) = 0.5;
uniform float startup_speed : hint_range(0.1, 1.0) = 0.4;

// --- BULANIKLIK AYARLARI ---
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float max_blur : hint_range(0.0, 5.0) = 2.5;

// --- YENİ: AFTERIMAGE (DAMARLI YAPI) AYARLARI ---
// repeat_enable'ı sildik, artık tek resim olacak.
uniform sampler2D vein_texture : hint_default_black, filter_linear_mipmap; 
uniform float afterimage_intensity : hint_range(0.0, 1.0) = 0.0; 
uniform vec4 blood_color : source_color = vec4(0.4, 0.0, 0.0, 1.0); 

// YENİ: Resmin boyutunu ayarlamak için zoom ayarı
// 1.0 = Tam Ekran, 0.5 = Daha Uzak, 2.0 = Yakınlaşmış (Büyük)
uniform vec2 texture_scale = vec2(1.0, 1.0); 

void fragment() {
	if (lid_value <= 0.001) {
		COLOR = vec4(0.0);
	} 
	else {
		vec2 uv = UV;
		
		float adjusted_value = pow(lid_value, startup_speed);
		
		// ORTAK EĞRİ HESABI
		float x_dist = (uv.x - 0.5) * 2.0;
		float parabola = x_dist * x_dist;
		float dynamic_curve = parabola * curve_strength * (1.0 - adjusted_value);
		float safety_margin = abs(curve_strength);

		// 1. ÜST KAPAK
		float upper_start_y = -0.1 - (safety_margin * 1.5);
		float upper_end_y = 0.5;
		float upper_base_y = mix(upper_start_y, upper_end_y, adjusted_value);
		float upper_threshold = upper_base_y - dynamic_curve;
		float upper_alpha = 1.0 - smoothstep(upper_threshold, upper_threshold + 0.01, uv.y);

		// 2. ALT KAPAK
		float lower_start_y = 1.1 + (safety_margin * 1.5);
		float lower_end_y = 0.5;
		float lower_base_y = mix(lower_start_y, lower_end_y, adjusted_value);
		float lower_threshold = lower_base_y + dynamic_curve;
		float lower_alpha = smoothstep(lower_threshold - 0.01, lower_threshold, uv.y);

		// 3. KAPAK ALPHASI
		float total_lid_alpha = max(upper_alpha, lower_alpha);
		total_lid_alpha = clamp(total_lid_alpha, 0.0, 1.0);

		// --- YENİ: DAMARLI GÖRÜNTÜ HESABI (DÜZELTİLDİ) ---
		
		// 1. UV'yi merkeze (0.5, 0.5) taşı
		vec2 centered_uv = UV - 0.5;
		
		// 2. Ölçekle (Büyütmek için UV'yi küçültmemiz gerekir, bu yüzden bölüyoruz)
		// Eğer texture_scale 1.0 ise normal kalır.
		vec2 scaled_uv = centered_uv / texture_scale;
		
		// 3. Tekrar eski yerine taşı
		vec2 final_vein_uv = scaled_uv + 0.5;
		
		// Dokuyu al ama kenarlarda tekrar etmesin (texture fonksiyonu default olarak clamp yapar veya siyah döner)
		vec4 vein_sample = vec4(0.0);
		
		// Sadece 0-1 aralığındaysa dokuyu göster (Böylece kenarlardaki uzamaları/tekrarları önleriz)
		if (final_vein_uv.x >= 0.0 && final_vein_uv.x <= 1.0 && final_vein_uv.y >= 0.0 && final_vein_uv.y <= 1.0) {
			vein_sample = texture(vein_texture, final_vein_uv);
		}
		
		vec3 fleshy_color = mix(blood_color.rgb * 0.5, blood_color.rgb * 2.0, vein_sample.r);
		
		// afterimage_intensity ile damarları görünür yap
		vec3 final_lid_surface_color = mix(lid_color.rgb, fleshy_color, afterimage_intensity);

		// --- 4. SONUÇ ---
		float current_blur = adjusted_value * max_blur;
		vec4 screen_color = textureLod(screen_texture, SCREEN_UV, current_blur);

		vec3 final_rgb = mix(screen_color.rgb, final_lid_surface_color, total_lid_alpha);
		
		COLOR = vec4(final_rgb, 1.0);
	}
}
