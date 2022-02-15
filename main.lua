-- The size of each cell that defines the grid that is out playing field.
local cellWidth = 32
local cellHeight = 32

-- The size of our grid forming the playing field.
local horizontalCells = 16
local verticalCells = 16

-- Set the size of our window to the total size of our grid.
love.window.setMode(cellWidth * horizontalCells, cellHeight * verticalCells)

-- The position of the snakes head which is what the player controls.
local headX = cellWidth * 8
local headY = cellHeight * 14

-- The list that contains all the parts that makes up the snake.
local snake = {}
snake[1] = { x = headX, y = headY }

-- The direction that the head of the snake will move in at each tick.
local moveX = 0
local moveY = -1

-- The timer that tracks when to update the snakes movement. Starting at -1 to give us a 1 second count down at the start of the program.
local timer = -1
-- Move the snake 8 times per second.
local timeStep = 1 / 8

-- How many apples the player has eaten.
local score = 0

-- The position of the apple.
local appleX = cellWidth * 4
local appleY = cellHeight * 4

local appleImage

function love.load()
	-- Make the apple stay nice and pixely.
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- Load the image to use for the apple.
	appleImage = love.graphics.newImage("apple.png")
end

-- Checks if the player has collided with anything and therefore lost the game.
function ShouldEndGame()
	-- Checks if the head of the snake has collided with the body. The loop starts at 2 so we don't check if the head of the snake has collided with itself.
	for i = 2, #snake do
		if snake[i].x == headX and snake[i].y == headY then
			return true
		end
	end

	-- Checks if the head of the snake is outside of the playing field. 
	return headX < 0 or headY < 0 or headX >= love.graphics.getWidth() or headY >= love.graphics.getHeight()
end

-- This will move the apple to a new position that is guaranteed to not be occupied by the snake.
function MoveAppleToNewPosition()
	-- Loop while the apple is in a invalid position. Eg. a position occupied by a piece of the snake.
	local overlaps = false
	repeat
		-- Move the apple to a random position. 
		appleX = cellWidth * love.math.random(horizontalCells - 1)
		appleY = cellHeight * love.math.random(verticalCells - 1)

		-- Check if the apple is at the same position as a piece of the snake.
		for i = 1, #snake do
			if snake[i].x == appleX and snake[i].y == appleY then
				overlaps = true
			end
		end

	until not overlaps
end

-- A callback provided by love. This function is called (usually) 60 times a second. This is we do our logic for our game.
function love.update(dt)
	-- Update our timer with dt so it counts in seconds.
	timer = timer + dt

	-- Check if we should update the snake this frame.
	if timer >= timeStep then
		-- Reset our timer.
		timer = 0

		-- Move the head of the snake with the direction the player wants to go in.
		headX = headX + moveX * cellWidth
		headY = headY + moveY * cellHeight

		-- Add the heads new position to the front of the list that is our snake.
		table.insert(snake, 1, { x = headX, y = headY })

		-- Check if the Head collides with the apple.
		local hasCollidedWithApple = headX == appleX and headY == appleY

		if hasCollidedWithApple then
			-- Move the apple to a new position and increment our score with 1.
			MoveAppleToNewPosition()
			score = score + 1
		end

		if not hasCollidedWithApple then
			-- If the head does not collide with the apple remove the last piece in the list so the snakes length remains the same. This Gives the illusion of the snakes movement. 
			table.remove(snake, #snake)
		end

		-- Check if the player has lost the game.
		if ShouldEndGame() then
			-- Quit the game.
			love.event.quit()
		end
	end
end

-- A callback provided by love. This function is called directly after love.update has been called. This is were we draw things to the screen.
function love.draw()
	-- Set the color of our paint brush to white.
	love.graphics.setColor(0.85, 0.56, 0.74)

	-- Loop through the pieces of the snake and draw a white rectangle at for each piece.
	for i = 1, #snake do
		love.graphics.rectangle('fill', snake[i].x, snake[i].y, cellWidth, cellHeight)
	end

	-- Draw a red rectangle for our apple.
	-- love.graphics.setColor(1, 0, 0)
	-- love.graphics.rectangle('fill', appleX, appleY, cellWidth, cellHeight)

	-- Draw the apple image for our apple.
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(appleImage, appleX, appleY, 0, 2, 2)

	-- Draw the players score in green.
	love.graphics.setColor(0, 1, 0)
	love.graphics.print(score, love.graphics.getWidth() / 2, 20, 0, 3, 3)
end

-- A callback provided by love. This function is called everytime the player pressed a key.
function love.keypressed(key)
	-- Check which arrow the player has pressed and set the movement of our snake accordingly.
	if key == 'right' then
		moveX = 1
		moveY = 0
	end

	if key == 'left' then
		moveX = -1
		moveY = 0
	end

	if key == 'up' then
		moveX = 0
		moveY = -1
	end

	if key == 'down' then
		moveX = 0
		moveY = 1
	end
end
