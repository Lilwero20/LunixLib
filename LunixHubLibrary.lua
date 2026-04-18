local LunixLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.Name = "LunixLibrary"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
if not pcall(function() sg.Parent = CoreGui end) then
    sg.Parent = PlayerGui
end

local notifHolder = Instance.new("Frame")
notifHolder.Name = "NotifHolder"
notifHolder.Parent = sg
notifHolder.Size = UDim2.new(0, 220, 1, -40)
notifHolder.Position = UDim2.new(0, 10, 0, 10)
notifHolder.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", notifHolder)
layout.Padding = UDim.new(0, 8)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeStroke(parent)
    local st = Instance.new("UIStroke", parent)
    st.Thickness = 2.5
    st.Color = Color3.fromRGB(0, 255, 255)
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(0, 120, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 255))
    })
    g.Parent = st
    task.spawn(function()
        while task.wait() do
            for i = 0, 360, 2 do
                g.Rotation = i
                task.wait(0.01)
            end
        end
    end)
    return st
end

local function makeDrag(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    frame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

function LunixLib:Notify(title, text, duration)
    local item = Instance.new("Frame")
    item.Name = "Notification"
    item.Parent = notifHolder
    item.BackgroundColor3 = Color3.fromRGB(10, 15, 35)
    item.Size = UDim2.new(1, 0, 0, 62)
    item.BackgroundTransparency = 1
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", item)
    s.Thickness = 1.5; s.Color = Color3.fromRGB(0, 255, 255); s.Transparency = 1

    local top = Instance.new("TextLabel", item)
    top.BackgroundTransparency = 1; top.Position = UDim2.new(0, 10, 0, 8); top.Size = UDim2.new(1, -20, 0, 18)
    top.Font = Enum.Font.GothamBold; top.Text = title or "LUNIX HUB"; top.TextColor3 = Color3.fromRGB(0, 255, 255); top.TextSize = 13; top.TextXAlignment = 0; top.TextTransparency = 1

    local body = Instance.new("TextLabel", item)
    body.BackgroundTransparency = 1; body.Position = UDim2.new(0, 10, 0, 28); body.Size = UDim2.new(1, -20, 0, 28)
    body.Font = Enum.Font.Gotham; body.Text = text or ""; body.TextColor3 = Color3.fromRGB(255, 255, 255); body.TextSize = 11; body.TextWrapped = true; body.TextXAlignment = 0; body.TextTransparency = 1

    TweenService:Create(item, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 0.4}):Play()
    TweenService:Create(top, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(body, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(duration or 4, function()
        local out = TweenService:Create(item, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)})
        out:Play()
        out.Completed:Wait()
        item:Destroy()
    end)
end

function LunixLib:CreateWindow(title, sizeX, sizeY)
    local win = {}
    sizeX = sizeX or 180
    sizeY = sizeY or 200

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window_" .. title
    mainFrame.Size = UDim2.new(0, sizeX, 0, sizeY)
    mainFrame.Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = sg
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    makeStroke(mainFrame)
    makeDrag(mainFrame)

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    titleLabel.Text = title:upper()
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = 0

    local container = Instance.new("ScrollingFrame", mainFrame)
    container.Size = UDim2.new(1, -10, 1, -45)
    container.Position = UDim2.new(0, 5, 0, 35)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    
    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, 6)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    function win:Button(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 255, 255), TextColor3 = Color3.fromRGB(10, 15, 35)}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(15, 25, 50), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            callback()
        end)
    end

    function win:Toggle(text, default, callback)
        local enabled = default or false
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
        btn.TextColor3 = enabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(120, 120, 120)
        btn.Text = (enabled and "●  " or "○  ") .. text
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            btn.TextColor3 = enabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(120, 120, 120)
            btn.Text = (enabled and "●  " or "○  ") .. text
            callback(enabled)
        end)
    end

    -- Función Slider
    function win:Slider(text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame", container)
        sliderFrame.Size = UDim2.new(1, -10, 0, 45)
        sliderFrame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", sliderFrame)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = text .. ": " .. default; label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham; label.TextSize = 11; label.BackgroundTransparency = 1

        local bar = Instance.new("Frame", sliderFrame)
        bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 25)
        bar.BackgroundColor3 = Color3.fromRGB(20, 30, 60)
        Instance.new("UICorner", bar)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        Instance.new("UICorner", fill)

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. val
            callback(val)
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    return win
end

return LunixLib
