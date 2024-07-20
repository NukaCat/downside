#version 330 core
in vec2 tex_coord;
in vec3 color;
in vec3 normal;
in vec3 world_coord;

out vec4 FragColor;

uniform sampler2D aTexture;
uniform vec3 light_dir;
uniform vec3 view_pos;

void main()
{
   //vec3 object_color = texture(aTexture, tex_coord).rgb + color;
   vec3 object_color = texture(aTexture, tex_coord).rgb;

   float ambient_strength = 0.6;
   float diffuse_strength = 0.6;
   float specular_strength = 0.5;

   float diffuse = max(dot(normal, -light_dir), 0.0);
   
   vec3 view_dir = normalize(view_pos - world_coord);
   vec3 reflect_dir = reflect(-light_dir, normal);
   
   float spec = pow(max(dot(-view_dir, reflect_dir), 0.0), 4);
   float specular = specular_strength * spec;  

   vec3 result_color = (diffuse * diffuse_strength + ambient_strength + specular) * object_color;
   FragColor = vec4(result_color.rgb, 1.0);
}