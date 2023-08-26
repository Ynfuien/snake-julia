include("pixel.jl")
include("border.jl")

using SimpleDirectMediaLayer.LibSDL2

@enum SnakeDirection begin
    Up
    Right
    Down
    Left
end


mutable struct Snake 
	bodyPixels::Vector{Pixel}
	headPixel::Pixel
end

function newSnake(size::Integer) 
	s = Snake([], Pixel())

    s.headPixel = Pixel(trunc(GRID_SIZE / 2 + (size / 2)), trunc(GRID_SIZE / 2 - 1));
    for i=size-1:-1:1
        push!(s.bodyPixels, Pixel(s.headPixel.x - i, s.headPixel.y));
    end

	return s
end

function render(s::Snake, r::Ptr{SDL_Renderer}, headColor::SDL_Color, bodyColor::SDL_Color) 
	render(s.headPixel, r, headColor)

	for p in s.bodyPixels 
		render(p, r, bodyColor)
	end
end

function move(s::Snake, direction::SnakeDirection, border::Border) 
	x = s.headPixel.x
	y = s.headPixel.y

	if direction == Up
		y -= 1
	elseif direction == Right
		x += 1
	elseif direction == Down
		y += 1
	elseif direction == Left
		x -= 1
	end

	newHead = Pixel(x, y)
	if contains(s, newHead) return false end
	if contains(border, newHead) return false end

    push!(s.bodyPixels, s.headPixel)
    popfirst!(s.bodyPixels)
	s.headPixel = newHead
	return true
end

function grow(s::Snake) 
	newBody = Pixel(s.bodyPixels[1].x, s.bodyPixels[1].y)
    pushfirst!(s.bodyPixels, newBody)
end

function getSize(s::Snake) 
	return length(s.bodyPixels) + 1
end

function contains(s::Snake, pixel::Pixel) 
	if equals(s.headPixel, pixel) 
		return true
	end

	for p in s.bodyPixels 
		if equals(p, pixel) 
			return true
		end
	end

	return false
end

# Separate method for checking for berry,
#because only head pixel can move onto berry position
function containsBerry(s::Snake, berry)
    return equals(s.headPixel, berry.position)
end