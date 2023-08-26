using SimpleDirectMediaLayer.LibSDL2

struct Pixel
    x::Integer
    y::Integer

    Pixel() = new(0, 0)
    Pixel(x, y) = new(x, y)
end

function render(p::Pixel, r::Ptr{SDL_Renderer}, c::SDL_Color)
    SDL_SetRenderDrawColor(r, c.r, c.g, c.b, c.a)

    rect = SDL_Rect(p.x * SCALE + p.x, p.y * SCALE + p.y, SCALE, SCALE)
    SDL_RenderFillRect(r, Ref(rect))
end

function equals(p::Pixel, pixel::Pixel)
    return p.x == pixel.x && p.y == pixel.y
end