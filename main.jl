include("snakegame/pixel.jl")
include("snakegame/border.jl")
include("snakegame/snake.jl")
include("snakegame/berry.jl")

using Dates
using SimpleDirectMediaLayer.LibSDL2


# Configuratio variables
GRID_SIZE  = 32
SNAKE_SIZE = 5
SCALE      = 20
SIZE       = GRID_SIZE*SCALE + GRID_SIZE - 1
TICK_TIME  = 100

# Game colors
gameColors = Dict(
    "background" => SDL_Color(36, 36, 36, 255),
	"snakeHead" => SDL_Color(96, 173, 81, 255),
	"snakeBody" => SDL_Color(170, 121, 193, 255),
	"berry" => SDL_Color(213, 99, 92, 255),
	"border" => SDL_Color(85, 85, 85, 255),
	"gameOver" => SDL_Color(255, 85, 85, 255),
	"score" => SDL_Color(255, 255, 85, 255),
	"scoreNumber" => SDL_Color(255, 170, 0, 255),
)


function setupGame()
	global border = newBorder(GRID_SIZE)
	global snake = newSnake(SNAKE_SIZE)
	global berry = newBerry(snake)
    
	global direction = Right
	global newDirection = direction
	global gameOver = false
end


function setupWindow()
    @assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "Error initializing SDL: $(unsafe_string(SDL_GetError()))"

    # Create window
    window = SDL_CreateWindow("Snake Julia", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SIZE, SIZE, SDL_WINDOW_OPENGL)
    # Create renderer for the window
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)


    # Initialize SDL TTF
    @assert TTF_Init() == 0 "Error initializing SDL TTF: $(unsafe_string(TTF_GetError()))"

    # Load font
    global font = TTF_OpenFont("Arial.ttf", 16 * (SCALE / 10))

    try
        # Game loop
        lastTick = getTimestamp()
        running = true
        while running
            event_ref = Ref{SDL_Event}()
            while Bool(SDL_PollEvent(event_ref))
                event = event_ref[]
                type = event.type
                
                if type == SDL_QUIT
                    running = false
                    break
                elseif type == SDL_KEYDOWN
                    scanCode = event.key.keysym.scancode
                    keyPressed(scanCode)
                    break
                
                break
                end
            end

            # Check if it's time for the next tick
            now = getTimestamp()
            if now - lastTick < TICK_TIME 
                continue
            end
            lastTick = now
            
            # Tick and render the game
            tick()
            render(renderer)
            
        end
    finally
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(window)
        TTF_CloseFont(font)
        TTF_Quit()
        SDL_Quit()
    end
end

function render(r::Ptr{SDL_Renderer})
    global gameOver

    # Clear
    c = gameColors["background"]
    SDL_SetRenderDrawColor(r, c.r, c.g, c.b, c.a)
    SDL_RenderClear(r)

    # Game over screen
    if (gameOver)
        scale = trunc(SCALE * 1.2);
        score = getSize(snake) - SNAKE_SIZE;
        
        drawText(r, "Game over!", SIZE / 2, SIZE / 2 - (scale * 2.3), gameColors["gameOver"]);
        drawText(r, "Score: $score", SIZE / 2, SIZE / 2 - scale, gameColors["scoreNumber"]);
        drawText(r, "Score: " * repeat(" ", length(string(score)) * 2), SIZE / 2, SIZE / 2 - scale, gameColors["score"]);

        render(border, r, gameColors["border"])
        SDL_RenderPresent(r)
        return
    end

    # Render everything
    render(snake, r, gameColors["snakeHead"], gameColors["snakeBody"])
    render(berry, r, gameColors["berry"])
    render(border, r, gameColors["border"])

    SDL_RenderPresent(r)
end

# Draws centered text
function drawText(r::Ptr{SDL_Renderer}, text::String, x::Number, y::Number, color::SDL_Color)
    global font

    # Render text to a surface
    surface = TTF_RenderUTF8_Solid(font, text, color)

    # Create texture from the surface
    texture = SDL_CreateTextureFromSurface(r, surface)


    # Render the texture on the renderer
    s = unsafe_load(surface)
    width = s.w
    height = s.h

    rect = SDL_Rect(convert(Int32, trunc(x - (width / 2))), convert(Int32, trunc(y - (height / 2))), width, height)
    SDL_RenderCopy(r, texture, C_NULL, Ref(rect))

    # Free resources
    SDL_FreeSurface(surface)
    SDL_DestroyTexture(texture)
end

function tick()
    global gameOver, direction, newDirection, snake, berry
    direction = newDirection

    # Move snake and check if it actually moved
    if !move(snake, direction, border)
        # Game over
        gameOver = true
        return;
    end

    # Check if snake got the berry
    if containsBerry(snake, berry)
        berry = newBerry(snake)
        grow(snake)
    end
end

# Handles pressed keys
function keyPressed(key::SDL_Scancode) 
    global direction, newDirection, gameOver

	if gameOver 
		return
    end
    
	if key == SDL_SCANCODE_UP || key == SDL_SCANCODE_W
		if direction == Down return end
		newDirection = Up
		return
    elseif key == SDL_SCANCODE_DOWN || key == SDL_SCANCODE_S
		if direction == Up return end
		newDirection = Down
		return
	elseif key == SDL_SCANCODE_LEFT || key == SDL_SCANCODE_A
		if direction == Right return end
		newDirection = Left
		return
	elseif key == SDL_SCANCODE_RIGHT || key == SDL_SCANCODE_D
		if direction == Left return end
		newDirection = Right
		return
    end
end

function getTimestamp()
    return convert(UInt64, Dates.datetime2unix(Dates.unix2datetime(time())) * 1000)
end


setupGame()
setupWindow()