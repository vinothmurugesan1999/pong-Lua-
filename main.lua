local push = require("src.push")

class = require('src.class')

require('src.scripts.ball')
require('src.scripts.paddle')

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

-- love.load is set the window to our game 
function love.load()

    -- helps to non blury texture
    love.graphics.setDefaultFilter('nearest', 'nearest')
     
    love.window.setTitle('pong')

    math.random(os.time())

   

    smallFont = love.graphics.newFont('src/assets/font/PressStart2P-Regular.ttf', 8)

    largeFont = love.graphics.newFont('src/assets/font/PressStart2P-Regular.ttf', 16)

    scoreFont = love.graphics.newFont('src/assets/font/PressStart2P-Regular.ttf', 32)
    
    sounds = {
        ['paddlehit'] = love.audio.newSource('src/assets/sounds/paddlehit.wav', 'static'),
        ['scorechange'] = love.audio.newSource('src/assets/sounds/scorechange.wav', 'static'),
        ['wallhit'] = love.audio.newSource('src/assets/sounds/wallhit.wav', 'static')
    }   

    love.graphics.setFont(smallFont)
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
player1Score =0
player2Score =0
winningPlayer=0
servingPlayer = 1

player1 = Paddle(10, 30, 5, 20)
player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT- 30, 5, 20)

ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)


gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve'then
        local direction = math.random(2) == 1 and -1 or 1
        ball.dy = direction * math.random(40, 120)
        if servingPlayer ==1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    end
   if gameState=='play' then
      if ball:collides(player1) then 
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + 5

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
        sounds['paddlehit']:play()
     end
      if ball:collides(player2) then 
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
        sounds['paddlehit']:play()
     end
     if ball.y <= 0 then 
        ball.y = 0
        ball.dy = -ball.dy
        sounds['wallhit']:play()
     end
     if ball.y >= VIRTUAL_HEIGHT-4 then
        ball.y = VIRTUAL_HEIGHT -4
        ball.dy = -ball.dy
        sounds['wallhit']:play()
     end
   end
if ball.x < 0 then
    servingPlayer = 1
    player2Score = player2Score + 1

    sounds['scorechange']:play()

    if player2Score == 10 then
        winningPlayer = 2
        gameState = 'done'
        ball:reset() 
    else
        gameState = 'serve'
        ball:reset()
    end
end

if ball.x > VIRTUAL_WIDTH then
    servingPlayer = 2
    player1Score = player1Score + 1

    sounds['scorechange']:play()

    if player1Score == 10 then
        winningPlayer = 1
        gameState = 'done'
        ball:reset() 
    else
        gameState = 'serve'
        ball:reset()
    end
end

    --player1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    --player2 movement
     if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
       player2.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    
    end
     
    if gameState == 'play'then
      ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
    
end


-- this fuction is help to kepress event 
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
   elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
        gameState = 'serve'

    elseif gameState == 'serve' then
        -- Set ball direction only once before play starts
        local direction = math.random(2) == 1 and -1 or 1
        ball.dy = direction * math.random(40, 120)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end

        gameState = 'play'

    elseif gameState == 'done' then
        gameState = 'serve'
        ball:reset()
        if winningPlayer == 1 then
            servingPlayer = 2
        else
            servingPlayer = 1
        end
        player1Score = 0
        player2Score = 0
        winningPlayer = 0
    end
end

end


function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)
    love.graphics.setFont(smallFont)

    displayScore()
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('plyer '..tostring(servingPlayer).."'s serve", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    elseif gameState == 'done' then
         love.graphics.setFont(largeFont)
    if winningPlayer ~= 0 then
        love.graphics.printf('Player '..tostring(winningPlayer)..' wins!', 0, 10, VIRTUAL_WIDTH, 'center')

    end
    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center') 
    end
   
      player1:render()
      player2:render()

      ball:render()
      displayFPS()
      push:apply('end')
end
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)  -- green color in normalized format
    love.graphics.printf('FPS: '..tostring(love.timer.getFPS()), 10, 10, VIRTUAL_WIDTH)
    love.graphics.setColor(1, 1, 1, 1)  -- reset color to white
end

function displayScore()
     love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/3)
end
