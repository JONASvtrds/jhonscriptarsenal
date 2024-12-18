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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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

-- Função para criar a função Lepanza
function UILibrary:CreateLepanza()
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local Holding = false

    _G.AimbotEnabled = true
    _G.TeamCheck = false -- Se definido como verdadeiro, o script só travará sua mira em membros do time inimigo.
    _G.AimPart = "Head" -- Onde o script de aimbot travará.
    _G.Sensitivity = 0 -- Quantos segundos leva para o script de aimbot travar oficialmente na aimpart do alvo.

    _G.CircleSides = 64 -- Quantos lados o círculo FOV terá.
    _G.CircleColor = Color3.fromRGB(255, 255, 255) -- Cor (RGB) que o círculo FOV aparecerá.
    _G.CircleTransparency = 0.7 -- Transparência do círculo.
    _G.CircleRadius = 80 -- O raio do círculo / FOV.
    _G.CircleFilled = false -- Determina se o círculo é preenchido ou não.
    _G.CircleVisible = true -- Determina se o círculo é visível ou não.
    _G.CircleThickness = 0 -- A espessura do círculo.

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Visible = _G.CircleVisible
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    local function GetClosestPlayer()
        local MaximumDistance = _G.CircleRadius
        local Target = nil

        for _, v in next, Players:GetPlayers() do
            if v.Name ~= LocalPlayer.Name then
                if _G.TeamCheck == true then
                    if v.Team ~= LocalPlayer.Team then
                        if v.Character ~= nil then
                            if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                                if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                                    local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                    local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                                    
                                    if VectorDistance < MaximumDistance then
                                        Target = v
                                    end
                                end
                            end
                        end
                    end
                else
                    if v.Character ~= nil then
                        if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
                                local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
                                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                                
                                if VectorDistance < MaximumDistance then
                                    Target = v
                                end
                            end
                        end
                    end
                end
            end
        end

        return Target
    end

    UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = true
        end
    end)

[_{{{CITATION{{{_1{](https://github.com/cjdjmj/aaa42/tree/43ef68a79bec18dc8f122bba912145517cfbb80f/README.md)[_{{{CITATION{{{_2{](https://github.com/RageFnAdmin/sgfgdggderg/tree/03b73b9c98fb51d48b5c4ef9e871f063c3a06d71/README.md)[_{{{CITATION{{{_3{](https://github.com/Green-bit1/aimbot/tree/7e786f9327cfb07db64f7d475f1046bde36adca8/README.md)[_{{{CITATION{{{_4{](https://github.com/gavinE312/hack/tree/88890a4a0f49cbf565616ac9ae46eeaf18a83b22/README.md)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            Holding = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        FOVCircle.Radius = _G.CircleRadius
        FOVCircle.Filled = _G.CircleFilled
        FOVCircle.Color = _G.CircleColor
        FOVCircle.Visible = _G.CircleVisible
        FOVCircle.Radius = _G.CircleRadius
        FOVCircle.Transparency = _G.CircleTransparency
        FOVCircle.NumSides = _G.CircleSides
        FOVCircle.Thickness = _G.CircleThickness

        if Holding == true and _G.AimbotEnabled == true then
            local closestPlayer = GetClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(_G.AimPart) then
                TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character[_G.AimPart].Position)}):Play()
            end
        end
    end)
end

return toggleLepanza
end

-- Inicialização da biblioteca
local screenGui = UILibrary:CreateScreenGui()
local draggableFrame = UILibrary:CreateDraggableFrame(screenGui, UDim2.new(0.3, -150, 0.3, -150), UDim2.new(0, 300, 0, 300))

local menuLabel = UILibrary:CreateLabel(draggableFrame, "Main Menu", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 50))
local toggleESPFunction = UILibrary:CreateESP()
local toggleLepanzaFunction = UILibrary:CreateLepanza()

local toggleESPButton = UILibrary:CreateToggleButton(draggableFrame, "Toggle ESP", UDim2.new(0, 50, 0, 100), UDim2.new(0, 200, 0, 50), function(state)
    toggleESPFunction(state)
end)

local toggleLepanzaButton = UILibrary:CreateToggleButton(draggableFrame, "Toggle Lepanza", UDim2.new(0, 50, 0, 160), UDim2.new(0, 200, 0, 50), function(state)
    toggleLepanzaFunction(state)
end)

-- Função para fechar a UI ao pressionar Control esquerdo
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        draggableFrame.Visible = not draggableFrame.Visible
    end
end)
