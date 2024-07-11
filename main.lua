--[[ 
food generation method breakdown
1. foodPosition table defined
2. moveFood() to position not occupied by snake

if snakePosition[1] == foodPosition --> moveFood()
if reset() --> moveFood()

3. draw food
]]

function love.load()
    gridXCount = 40
    gridYCount = 40
    cellSize = 20

    speed = 0.15

    -- locks game window to gridX and gridY values
    love.window.setMode(gridXCount * cellSize, gridYCount * cellSize)

    -- determines where food generates
    foodPosition = {
        x = love.math.random(1, gridXCount), 
        y = love.math.random(1, gridYCount),
    }

    -- food instance 2
    food2Position = {
        x = love.math.random(1, gridXCount), 
        y = love.math.random(1, gridYCount),
    }

    -- moves food to positions not occupied by snake
    function moveFood(food)
        local possibleFoodPositions = {}
        for foodX = 1, gridXCount do 
            for foodY = 1, gridYCount do 
                local possible = true

                for segmentIndex, segment in ipairs(snakeSegments) do 
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end

            end
        end

        local newPosition = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]
        food.x = newPosition.x 
        food.y = newPosition.y 
        -- foodPosition = possibleFoodPositions[
        --     love.math.random(#possibleFoodPositions)
        -- ]
    end

    -- moves food2 to positions not occupied by snake
    -- function moveFood2()
    --     local possibleFoodPositions = {}
    --     for foodX = 1, gridXCount do 
    --         for foodY = 1, gridYCount do 
    --             local possible = true

    --             for segmentIndex, segment in ipairs(snakeSegments) do 
    --                 if foodX == segment.x and foodY == segment.y then
    --                     possible = false
    --                 end
    --             end

    --             if possible then
    --                 table.insert(possibleFoodPositions, {x = foodX, y = foodY})
    --             end

    --         end
    --     end

    --     food2Position = possibleFoodPositions[
    --         love.math.random(#possibleFoodPositions)
    --     ]
    -- end

    function reset()
        snakeSegments = {
            {x = 3, y = gridYCount/2},
            {x = 2, y = gridYCount/2},
            {x = 1, y = gridYCount/2},
        }
        directionQueue = {'d'}
        snakeAlive = true
        speed = 0.15
        timer = 0
        moveFood(foodPosition)
        moveFood(food2Position)
    end

    reset()
end

function love.update(dt)
    timer = timer + dt

    if snakeAlive then
        interval = 0

        if #snakeSegments < 10 then
            interval = 0.15
            -- add another fruit
        elseif #snakeSegments < 20 then
            interval = 0.10
        elseif #snakeSegments < 30 then
            interval = 0.05
        else
            interval = 0.05
        end

        if timer >= interval then
            timer = 0

            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end

            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y

            if directionQueue[1] == 'd' then
                nextXPosition = nextXPosition + 1
                if nextXPosition > gridXCount then
                    nextXPosition = 1
                end
            elseif directionQueue[1] == 'a' then
                nextXPosition = nextXPosition - 1
                if nextXPosition < 1 then
                    nextXPosition = gridXCount
                end
            elseif directionQueue[1] == 's' then
                nextYPosition = nextYPosition + 1
                if nextYPosition > gridYCount then
                    nextYPosition = 1
                end
            elseif directionQueue[1] == 'w' then
                nextYPosition = nextYPosition - 1
                if nextYPosition < 1 then
                    nextYPosition = gridYCount
                end
            end

            local canMove = true

            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                and nextXPosition == segment.x
                and nextYPosition == segment.y then
                    canMove = false
                end
            end

            if canMove then
                table.insert(snakeSegments, 1, {
                    x = nextXPosition, y = nextYPosition
                })

                if snakeSegments[1].x == foodPosition.x
                and snakeSegments[1].y == foodPosition.y then
                    moveFood(foodPosition)
                elseif snakeSegments[1].x == food2Position.x
                and snakeSegments[1].y == food2Position.y then
                    moveFood(food2Position)
                else
                    table.remove(snakeSegments)
                end

            else
                snakeAlive = false
            end
        end

    elseif timer >= 2 then
        love.load()
    end
end

function love.keypressed(key)
    if key == 'd'
    and directionQueue[#directionQueue] ~= 'd'
    and directionQueue[#directionQueue] ~= 'a' then
        table.insert(directionQueue, 'd')

    elseif key == 'a'
    and directionQueue[#directionQueue] ~= 'a'
    and directionQueue[#directionQueue] ~= 'd' then
        table.insert(directionQueue, 'a')

    elseif key == 'w'
    and directionQueue[#directionQueue] ~= 'w'
    and directionQueue[#directionQueue] ~= 's' then
        table.insert(directionQueue, 'w')

    elseif key == 's'
    and directionQueue[#directionQueue] ~= 's'
    and directionQueue[#directionQueue] ~= 'w' then
        table.insert(directionQueue, 's')
    end
end

function love.draw()
    local cellSize = 20

    -- draw grid
    love.graphics.setColor(.28, .28, .28)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        gridYCount * cellSize
    )

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1)*cellSize, 
            (y - 1)*cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    -- draw snake
    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(love.math.colorFromBytes(196, 138, 255))
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        drawCell(segment.x, segment.y)
    end

    -- DEBUG: display directionQueue
    -- for directionIndex, direction in ipairs(directionQueue) do
    --     love.graphics.setColor(1, 1, 1)
    --     love.graphics.print(
    --         'directionQueue['..directionIndex..']: '..direction,
    --         15, 10
    --     )
    -- end

    -- DEBUG: display snakeSegments
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        'snakeSegments: '..tostring(#snakeSegments),
        15, 30
    )

    -- DEBUG: display food position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        'Food Position: ('..foodPosition.x..', '..foodPosition.y..')',
        15, 50
    )

    -- DEBUG: display food2 position
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        'Food2 Position: ('..food2Position.x..', '..food2Position.y..')',
        15, 65
    )

    -- draw  (1 instance) food
    love.graphics.setColor(1, 0.3, 0.3) 
    drawCell(foodPosition.x, foodPosition.y)
    drawCell(food2Position.x, food2Position.y)
end