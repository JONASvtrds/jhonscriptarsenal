
-- Biblioteca de UI simples para Roblox com menu lateral

local UILibrary = {}

-- Função para criar uma nova tela GUI
function UILibrary:CreateScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomScreenGui"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return screenGui
end

-- Função para criar um quadro arrastável
function UILibrary:CreateDraggableFrame(parent, position, size)
    local frame = Instance.new("Frame")
    frame.Name = "DraggableFrame"
    frame.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
    frame.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = parent
    
    -- Tornar o quadro arrastável
    local UIS = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return frame
end

-- Função para criar um botão configurável
function UILibrary:CreateToggleButton(parent, text, position, size, callback)
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Text = text
    button.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
    button.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho como padrão (desligado)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent

    local toggled = false

    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) -- Verde se ligado, vermelho se desligado
        callback(toggled)
    end)
    
    return button
end

-- Função para criar uma label de texto
function UILibrary:CreateLabel(parent, text, position, size)
    local label = Instance.new("TextLabel")
    label.Name = "CustomLabel"
    label.Text = text
    label.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
    label.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = parent
    return label
end

-- Função para criar ESP
function UILibrary:CreateESP()
    local espEnabled = false
    
    local function toggleESP(enabled)
        espEnabled = enabled
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if espEnabled then
                    if not player.Character:FindFirstChild("ESPBox") then
                        local espBox = Instance.new("BoxHandleAdornment")
                        espBox.Name = "ESPBox"
                        espBox.Adornee = player.Character
                        espBox.Size = player.Character:GetExtentsSize()
                        espBox.Transparency = 0.7
                        espBox.ZIndex = 1
                        espBox.AlwaysOnTop = true
                        
                        if player.Team == game.Players.LocalPlayer.Team then
                            espBox.Color3 = Color3.new(0, 1, 0) -- Verde para aliados
                        else
                            espBox.Color3 = Color3.new(1, 0, 0) -- Vermelho para inimigos
                        end

                        espBox.Parent = player.Character
                    end
                else
                    if player.Character:FindFirstChild("ESPBox") then
                        player.Character:FindFirstChild("ESPBox"):Destroy()
                    end
                end
            end
        end
    end
    
    return toggleESP
end

-- Função para criar o Aimbot
function UILibrary:CreateAimbot()
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Holding = false

    _G.AimbotEnabled = true
    _G.TeamCheck = false -- Se definido como verdadeiro, o script só travará sua mira em membros do time inimigo.
    _G.AimPart = "Head" -- Onde o script de aimbot travará.
    _G.Sensitivity = 0 -- Quantos segundos leva para o script de aimbot travar oficialmente na aimpart do alvo.

    local function GetClosestPlayer()
        local MaximumDistance = math.huge
        local Target = nil

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(_G.AimPart) then
                if _G.TeamCheck and v.Team == LocalPlayer.Team then
                    continue
                end
                local Distance = (LocalPlayer.Character.Head.Position - v.Character.Head.Position).Magnitude
                if Distance < MaximumDistance then
                    MaximumDistance = Distance
                    Target = v
                end
            end
        end

        return Target
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Holding and _G.AimbotEnabled then
            local Target = GetClosestPlayer()
            if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[_G.AimPart].Position)
            end
        end
    end)
end

-- Inicialização da biblioteca
local screenGui = UILibrary:CreateScreenGui()
local draggableFrame = UILibrary:CreateDraggableFrame(screenGui, UDim2.new(0.3, -150, 0.3, -150), UDim2.new(0, 300, 0, 300))

local menuLabel = UILibrary:CreateLabel(draggableFrame, "Main Menu", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 50))
local toggleESPFunction = UILibrary:CreateESP()
local toggleAimbotFunction = UILibrary:CreateAimbot()

local toggleESPButton = UILibrary:CreateToggleButton(draggableFrame, "Toggle ESP", UDim2.new(0, 50, 0, 100), UDim2.new(0, 200, 0, 50), function(state)
    toggleESPFunction(state)
end)

local toggleAimbotButton = UILibrary:CreateToggleButton(draggableFrame, "Toggle Aimbot", UDim2.new(0, 50, 0, 160), UDim2.new(0, 200, 0, 50), function(state)
    toggleAimbotFunction(state)
end)

-- Função para fechar a UI ao pressionar Control esquerdo
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        draggableFrame.Visible = not draggableFrame.Visible
    end
end)
-- Função para criar o Teleport para Inimigos com Auto Kill
function UILibrary:CreateTeleportAutoKill()
    local teleportEnabled = false
    local keyBind = Enum.KeyCode.P  -- Tecla para ativar o teleporte
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UIS = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local teleportDistanceThreshold = 200  -- Distância máxima aumentada para teletransporte

    local function toggleTeleport(enabled)
        teleportEnabled = enabled
        
        local function teleportToEnemy()
            while teleportEnabled do
                local target = nil
                for _, player in ipairs(Players:GetPlayers()) do
                    local character = player.Character
                    if player.Team ~= LocalPlayer.Team and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= teleportDistanceThreshold then
                            target = player
                            break
                        end
                    end
                end
                
                while teleportEnabled and target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 do
                    local humanoidRootPart = target.Character.HumanoidRootPart
                    LocalPlayer.Character:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(0, 5, 0))  -- Ficar em cima da cabeça do inimigo
                    ReplicatedStorage.Events.Shoot:FireServer(target.Character)
                    wait(0.1)
                end

                wait(0.5)
            end
        end
        
        if teleportEnabled then
            spawn(teleportToEnemy)
        end
    end
    
    -- Conectar o evento de pressionar a tecla
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == keyBind then
            teleportEnabled = true
            toggleTeleport(true)
        end
    end)

    UIS.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == keyBind then
            teleportEnabled = false
            toggleTeleport(false)
        end
    end)
    
    return toggleTeleport
end

-- Adicione esta parte no local onde você cria os botões na interface
local toggleTeleportAutoKillFunction = UILibrary:CreateTeleportAutoKill()

local toggleTeleportAutoKillButton = UILibrary:CreateToggleButton(draggableFrame, "Ativar Auto Kill", UDim2.new(0, 50, 0, 220), UDim2.new(0, 200, 0, 50), function(state)
    toggleTeleportAutoKillFunction(state)
end)
-- Função para ativar o Fly
local function enableFly()
    local character = game.Players.LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChildOfClass("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
        humanoidRootPart.BrickColor = BrickColor.new("Bright red")
    end
end

-- Função para desativar o Fly
local function disableFly()
    local character = game.Players.LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChildOfClass("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Anchored = true
        humanoidRootPart.BrickColor = BrickColor.new("Bright blue")
    end
end

-- Adicionar botão "Fly" ao UI
local flyButton = UILibrary:CreateToggleButton(draggableFrame, "Fly", UDim2.new(0, 50, 0, 330), UDim2.new(0, 200, 0, 50), function(state)
    if state then
        enableFly()
    else
        disableFly()
    end
end)
-- Função para criar o Aimbot com FOV e Team Check
local function createAimbot()
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Holding = false
    local FOV = 50 -- Campo de visão padrão

    _G.AimbotEnabled = true
    _G.TeamCheck = true -- Se definido como verdadeiro, o script só travará sua mira em membros do time inimigo.
    _G.AimPart = "Head" -- Onde o script de aimbot travará.
    _G.Sensitivity = 0.1 -- Quantos segundos leva para o script de aimbot travar oficialmente na aimpart do alvo.

    local function GetClosestPlayer()
        local MaximumDistance = FOV
        local Target = nil

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(_G.AimPart) then
                if _G.TeamCheck and v.Team == LocalPlayer.Team then
                    continue
                end
                local Distance = (Camera.CFrame.Position - v.Character[_G.AimPart].Position).Magnitude
                local ScreenPoint = Camera:WorldToScreenPoint(v.Character[_G.AimPart].Position)
                local MousePosition = UserInputService:GetMouseLocation()
                local DistanceFromMouse = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - MousePosition).Magnitude
                if DistanceFromMouse < MaximumDistance then
                    MaximumDistance = DistanceFromMouse
                    Target = v
                end
            end
        end

        return Target
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Holding and _G.AimbotEnabled then
            local Target = GetClosestPlayer()
            if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[_G.AimPart].Position)
            end
        end
    end)

    -- Adicionar função para ajustar o FOV
    local function createFOVInputFrame(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 100)
        frame.Position = UDim2.new(0.5, -100, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.Parent = parent

        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(1, -20, 0, 30)
        textBox.Position = UDim2.new(0, 10, 0, 10)
        textBox.PlaceholderText = "Digite o FOV"
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        textBox.Parent = frame

        local submitButton = Instance.new("TextButton")
        submitButton.Size = UDim2.new(1, -20, 0, 30)
        submitButton.Position = UDim2.new(0, 10, 0, 50)
        submitButton.Text = "Aplicar"
        submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        submitButton.Parent = frame

        submitButton.MouseButton1Click:Connect(function()
            local newFOV = tonumber(textBox.Text)
            if newFOV then
                FOV = newFOV
            end
            frame:Destroy() -- Fechar a UI após aplicar o FOV
        end)
    end

    -- Adicionar botão "Ajustar FOV" ao UI
    local changeFOVButton = UILibrary:CreateToggleButton(draggableFrame, "Ajustar FOV", UDim2.new(0, 50, 0, 390), UDim2.new(0, 200, 0, 50), function(state)
        if state then
            createFOVInputFrame(draggableFrame)
        end
    end)
end

-- Inicialização do Aimbot
createAimbot()
-- Função para adicionar a funcionalidade de scroll
local function createScrollableFrame(parent, position, size)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
    scrollingFrame.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Ajuste conforme necessário
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.Parent = parent

    return scrollingFrame
end

-- Inicialização do Scroll no Menu Lateral
local scrollableFrame = createScrollableFrame(draggableFrame, UDim2.new(0, 0, 0, 50), UDim2.new(1, 0, 1, -50))

-- Exemplo de uso: adicionando elementos ao frame rolável
local exampleLabel = UILibrary:CreateLabel(scrollableFrame, "Exemplo de Texto Rolável", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 50))

-- Adicionar mais botões e funcionalidades ao `scrollableFrame` conforme necessário
local toggleESPButton = UILibrary:CreateToggleButton(scrollableFrame, "Toggle ESP", UDim2.new(0, 50, 0, 100), UDim2.new(0, 200, 0, 50), function(state)
    toggleESPFunction(state)
end)

local toggleAimbotButton = UILibrary:CreateToggleButton(scrollableFrame, "Toggle Aimbot", UDim2.new(0, 50, 0, 160), UDim2.new(0, 200, 0, 50), function(state)
    toggleAimbotFunction(state)
end)
-- Função para adicionar a funcionalidade de scroll
local function createScrollableFrame(parent, position, size)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
    scrollingFrame.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Ajuste conforme necessário
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.Parent = parent

    return scrollingFrame
end

-- Inicialização do Scroll no Menu Lateral
local scrollableFrame = createScrollableFrame(draggableFrame, UDim2.new(0, 0, 0, 50), UDim2.new(1, 0, 1, -50))

-- Exemplo de uso: adicionando elementos ao frame rolável
local exampleLabel = UILibrary:CreateLabel(scrollableFrame, "Exemplo de Texto Rolável", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 50))

-- Adicionar os botões ao frame rolável
local toggleESPButton = UILibrary:CreateToggleButton(scrollableFrame, "Toggle ESP", UDim2.new(0, 50, 0, 60), UDim2.new(0, 200, 0, 50), function(state)
    toggleESPFunction(state)
end)

local toggleAimbotButton = UILibrary:CreateToggleButton(scrollableFrame, "Toggle Aimbot", UDim2.new(0, 50, 0, 120), UDim2.new(0, 200, 0, 50), function(state)
    toggleAimbotFunction(state)
end)

local flyButton = UILibrary:CreateToggleButton(scrollableFrame, "Fly", UDim2.new(0, 50, 0, 180), UDim2.new(0, 200, 0, 50), function(state)
    if state then
        enableFly()
    else
        disableFly()
    end
end)

local changeFOVButton = UILibrary:CreateToggleButton(scrollableFrame, "Ajustar FOV", UDim2.new(0, 50, 0, 240), UDim2.new(0, 200, 0, 50), function(state)
    if state then
        createFOVInputFrame(scrollableFrame)
    end
end)
-- Função para ativar o Infinite Jump
local function enableInfiniteJump()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.JumpRequest:Connect(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Adicionar botão "Infinite Jump" ao UI
local infiniteJumpButton = UILibrary:CreateToggleButton(scrollableFrame, "Infinite Jump", UDim2.new(0, 50, 0, 300), UDim2.new(0, 200, 0, 50), function(state)
    if state then
        enableInfiniteJump()
    end
end)
