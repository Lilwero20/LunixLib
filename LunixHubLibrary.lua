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
    windowCount = windowCount + 1
    sizeX = sizeX or 220
    sizeY = sizeY or 250
    
    local win = {}
    
    -- Auto-posicionamiento (Evita que se encimen)
    local offsetX = (windowCount - 1) * (sizeX + 20)
    local main = Instance.new("Frame", sg)
    main.Name = title
    main.Size = UDim2.fromOffset(sizeX, sizeY)
    main.Position = UDim2.new(0, 50 + offsetX, 0, 100)
    main.BackgroundColor3 = BG_THEME
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    attachAnimStroke(main)
    makeDrag(main)

    local titleLbl = Instance.new("TextLabel", main)
    titleLbl.Size = UDim2.new(1, 0, 0, 35); titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title:upper(); titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextColor3 = COL_CYAN; titleLbl.TextSize = 15

    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1, -15, 1, -45); container.Position = UDim2.new(0, 7, 0, 40)
    container.BackgroundTransparency = 1; container.BorderSizePixel = 0; container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = COL_CYAN
    
    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, 8); list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- BOTÓN
    function win:Button(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
        btn.TextColor3 = COL_CYAN; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.Text = text
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = COL_CYAN; btn.TextColor3 = BG_THEME
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 25, 45), TextColor3 = COL_CYAN}):Play()
        end)
    end

    -- TOGGLE
    function win:Toggle(text, default, callback)
        local state = default or false
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
        btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150, 150, 150)
        btn.Text = (state and "●  " or "○  ") .. text
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150, 150, 150)
            btn.Text = (state and "●  " or "○  ") .. text
            callback(state)
        end)
    end

    -- SLIDER (Estilo Steal Speed con Knob)
    function win:Slider(text, min, max, default, callback)
        local holder = Instance.new("Frame", container)
        holder.Size = UDim2.new(1, -10, 0, 40); holder.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(1, 0, 0, 15); label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default; label.Font = Enum.Font.GothamBold; label.TextSize = 11; label.TextColor3 = Color3.fromRGB(200, 220, 255)

        local bar = Instance.new("Frame", holder)
        bar.Size = UDim2.new(1, -10, 0, 6); bar.Position = UDim2.new(0.5, 0, 0, 25); bar.AnchorPoint = Vector2.new(0.5, 0)
        bar.BackgroundColor3 = Color3.fromRGB(12, 16, 32); bar.BorderSizePixel = 0
        Instance.new("UICorner", bar)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.fromScale((default-min)/(max-min), 1); fill.BackgroundColor3 = COL_CYAN; fill.BorderSizePixel = 0
        Instance.new("UICorner", fill)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.fromOffset(12, 12); knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", knob)

        local dragging = false
        local function update(input)
            local x = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            local rel = math.clamp(x, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.fromScale(rel, 1)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            label.Text = text .. ": " .. val
            callback(val)
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end

    -- LABEL / TEXTO
    function win:Label(text)
        local l = Instance.new("TextLabel", container)
        l.Size = UDim2.new(1, -10, 0, 20); l.BackgroundTransparency = 1
        l.Text = text; l.Font = Enum.Font.Gotham; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 11; l.TextXAlignment = 0
    end

    return win
end

return LunixLib

return LunixLib
