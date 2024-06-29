#version 330

// CRT like monitor shaders for hyprland (thanks to https://www.shadertoy.com/user/sprash3)

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

const float DENSITY = 1.3;
const float S_OPASITY = 0.3;
const float N_OPASITY = 0.2;
const float FLICKERING = 0.05;
const float WIDTH = 0.90;
const float HEIGHT = 0.5;
const float CURVE = 3.0;
const float SMOOTH = 0.004;
const float SHINE = 0.12;

const vec2 RESOLUTION = vec2(2240, 1400); // For compatability stuff

const vec3 BEZEL_COL = vec3(0.8, 0.8, 0.6);

// Function to calculate curved surface.
vec2 curvedSurface(vec2 uv, float r)
{
    return r * uv/sqrt(r * r - dot(uv, uv));
}

// Function to calculate CRT curve.
vec2 crtCurve(vec2 uv, float r, bool content, bool shine)
{
    vec2 window_size = RESOLUTION; //textureSize(tex, 0);

    r = CURVE * r;
    uv = (uv / window_size - 0.5) / vec2(window_size.y / window_size.x, 1.) * 2.0;
    uv = curvedSurface(uv, r);
    if(content) uv *= 0.5 / vec2(WIDTH, HEIGHT);
    uv = (uv / 2.0) + 0.5;

    return uv;
}

float random(vec2 st)
{
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float blend(const in float x, const in float y)
{
    return (x < 0.5) ? (2.0 * x * y) : (1.0 - 2.0 * (1.0 - x) * (1.0 - y));
}

vec3 blend(const in vec3 x, const in vec3 y, const in float opacity)
{
    vec3 z = vec3(blend(x.r, y.r), blend(x.g, y.g), blend(x.b, y.b));
    return z * opacity + x * (1.0 - opacity);
}

float roundSquare(vec2 p, vec2 b, float r)
{
    return length(max(abs(p)-b,0.0))-r;
}

float stdRS(vec2 uv, float r)
{
    return roundSquare(uv - 0.5, vec2(WIDTH, HEIGHT) + r, 0.05);
}

vec4 window_shader()
{
    vec3 content = vec3(0.0, 0.0, 0.0);
    vec3 gloss = vec3(0.0, 0.0, 0.0);


    vec2 uvContent = crtCurve(gl_FragCoord.xy, 1., true, false);
    vec2 uvScreen = crtCurve(gl_FragCoord.xy, 1., false, false);
    vec2 uvEnclosure = crtCurve(gl_FragCoord.xy, 1.25, false, false);
    vec2 uvShine = crtCurve(gl_FragCoord.xy, 1., false, true);

    float count = 1400.0 * DENSITY;
    vec2 sl = vec2(sin(uvContent.y * count), cos(uvContent.y * count));
    vec3 scanlines = vec3(sl.x, sl.y, sl.x);

    const float HHW = 0.5 * HEIGHT/WIDTH;

    content += BEZEL_COL * SHINE * 0.7 *
        smoothstep(-SMOOTH, SMOOTH, stdRS(uvScreen, 0.0)) *
        smoothstep(SMOOTH, -SMOOTH, stdRS(uvEnclosure, 0.05));

    content -= (BEZEL_COL) *
        smoothstep(-SMOOTH*2.0, SMOOTH*10.0, stdRS(uvEnclosure, 0.05)) *
        smoothstep(SMOOTH*2.0, -SMOOTH*2.0, stdRS(uvEnclosure, 0.05));

    content += max(0.0, SHINE - 0.3*distance(uvScreen, vec2(0.5,0.5))) *
            smoothstep(SMOOTH, -SMOOTH, stdRS(uvScreen, 0.0));

    uvContent = vec2(uvContent.s, 1.0 - uvContent.t);
    vec3 col = texture2D(tex, uvContent).xyz;
    if (uvContent.x > 0. && uvContent.x < 1. && uvContent.y > 0. && uvContent.y < 1.)
    {
        col += col * scanlines * S_OPASITY;
        col += col * vec3(random(uvContent * time)) * N_OPASITY;
        col += col * sin(110.0 * time) * FLICKERING;
        content += col;
    }

    gl_FragColor = vec4(content, 1.0);

    return gl_FragColor;
}
