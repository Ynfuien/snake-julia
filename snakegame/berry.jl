using SimpleDirectMediaLayer.LibSDL2

mutable struct Berry 
	position::Pixel
end

function newBerry(snake::Snake)
	b = Berry(Pixel())

	while true 
		b.position = Pixel(rand(1:GRID_SIZE-2), rand(1:GRID_SIZE-2))

		if !contains(snake, b.position) break end
	end
    
	return b
end

function render(b::Berry, r::Ptr{SDL_Renderer}, color::SDL_Color) 
	render(b.position, r, color)
end