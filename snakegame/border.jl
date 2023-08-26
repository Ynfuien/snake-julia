using SimpleDirectMediaLayer.LibSDL2

mutable struct Border
	borderPixels::Vector{Pixel}
end

function newBorder(size::Integer)
    b = Border([])

	for i in 0:size-1
		# Border in width
        push!(b.borderPixels, Pixel(i, 0))
        push!(b.borderPixels, Pixel(i, size - 1))

		# Border in height
		if i == 0 || i == size - 1 continue end
        push!(b.borderPixels, Pixel(0, i))
        push!(b.borderPixels, Pixel(size - 1, i))
	end

	return b
end

function render(b::Border, r::Ptr{SDL_Renderer}, color::SDL_Color) 
	for p in b.borderPixels
		render(p, r, color)
	end
end

function contains(b::Border, pixel::Pixel) 
	for p in b.borderPixels 
		if equals(p, pixel) 
			return true
		end
	end

	return false
end