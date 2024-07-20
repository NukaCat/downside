#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;
layout (location = 2) in vec3 aColor;
layout (location = 3) in vec3 aNormal;

out vec2 tex_coord;
out vec3 color;
out vec3 world_coord;
out vec3 normal;

uniform mat4 transform;
uniform mat4 model;

void main()
{
   gl_Position = transform * vec4(aPos, 1.0);

   world_coord = vec3(model * vec4(aPos, 1.0));
   normal = mat3(model) * aNormal;  
   tex_coord = aTexCoord.xy;
   color = aColor;
};