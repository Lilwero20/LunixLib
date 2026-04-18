local LunixLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local COL_BLUE = Color3.fromRGB(0, 80, 255)
local COL_CYAN = Color3.fromRGB(0, 210, 255)
local BG_THEME = Color3.fromRGB(10, 5, 18)

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local UI = {
    WindowSize = isMobile and UDim2.new(0.9,0,0.75,0) or UDim2.fromOffset(230,250),
    ButtonHeight = isMobile and 42 or 30,
    Padding = isMobile and 12 or 8,
    TextSize = isMobile and 14 or 12,
    TitleSize = isMobile and 18 or 15,
    Corner = isMobile and 14 or 10,
    Scroll = isMobile and 4 or 2
}

local sg = Instance.new("ScreenGui")
sg.Name = "LunixLib"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local function attachAnimStroke(parent)
    local s = Instance.new("UIStroke", parent)
    s.Thickness = 2
    s.Color = Color3.fromRGB(255,255,255)

    local g = Instance.new("UIGradient", s)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COL_BLUE),
        ColorSequenceKeypoint.new(0.5, COL_CYAN),
        ColorSequenceKeypoint.new(1, COL_BLUE)
    })

    task.spawn(function()
        while s and s.Parent do
            g.Rotation = (g.Rotation + 2) % 360
            task.wait(0.01)
        end
    end)

    return s
end

local function makeDrag(frame)
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function LunixLib:CreateWindow(title)
    local win = {}

    local main = Instance.new("Frame", sg)
    main.Size = UI.WindowSize
    main.BackgroundColor3 = BG_THEME
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0
    main.ClipsDescendants = true

    if isMobile then
        main.AnchorPoint = Vector2.new(0.5,0.5)
        main.Position = UDim2.new(0.5,0,0.5,0)
    else
        main.Position = UDim2.new(0,100,0,100)
    end

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, UI.Corner)
    attachAnimStroke(main)
    makeDrag(main)

    local titleLbl = Instance.new("TextLabel", main)
    titleLbl.Size = UDim2.new(1,0,0,30)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title:upper()
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = COL_CYAN
    titleLbl.TextSize = UI.TitleSize

    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1,-10,1,-40)
    container.Position = UDim2.new(0,5,0,35)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = UI.Scroll
    container.ScrollBarImageColor3 = COL_CYAN
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, UI.Padding)

    function win:Button(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1,-10,0,UI.ButtonHeight)
        btn.BackgroundColor3 = Color3.fromRGB(14,20,46)
        btn.TextColor3 = COL_CYAN
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = UI.TextSize
        btn.Text = text

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = COL_CYAN
            btn.TextColor3 = BG_THEME
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(14,20,46),
                TextColor3 = COL_CYAN
            }):Play()
        end)
    end

    function win:Toggle(text, default, callback)
        local state = default or false

        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1,-10,0,UI.ButtonHeight)
        btn.BackgroundColor3 = Color3.fromRGB(14,20,46)
        btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150,150,150)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = UI.TextSize

        local function refresh()
            btn.Text = (state and "●  " or "○  ") .. text
        end

        refresh()

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            callback(state)
        end)
    end

    function win:Slider(text, min, max, default, callback)
        local holder = Instance.new("Frame", container)
        holder.Size = UDim2.new(1,-10,0,isMobile and 50 or 40)
        holder.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(1,0,0,15)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.Font = Enum.Font.GothamBold
        label.TextSize = UI.TextSize
        label.TextColor3 = Color3.fromRGB(200,220,255)

        local bar = Instance.new("Frame", holder)
        bar.Size = UDim2.new(1,-10,0,6)
        bar.Position = UDim2.new(0.5,0,0,25)
        bar.AnchorPoint = Vector2.new(0.5,0)
        bar.BackgroundColor3 = Color3.fromRGB(12,16,32)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.fromScale((default-min)/(max-min),1)
        fill.BackgroundColor3 = COL_CYAN
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.fromOffset(12,12)
        knob.AnchorPoint = Vector2.new(0.5,0.5)
        knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local dragging = false

        local function update(input)
            local x = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            local rel = math.clamp(x,0,1)
            local val = math.floor(min + (max-min)*rel)

            fill.Size = UDim2.fromScale(rel,1)
            knob.Position = UDim2.new(rel,0,0.5,0)
            label.Text = text .. ": " .. val

            callback(val)
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    function win:Label(text)
        local l = Instance.new("TextLabel", container)
        l.Size = UDim2.new(1,-10,0,20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = Color3.new(1,1,1)
        l.TextSize = UI.TextSize
        l.TextXAlignment = 0
    end

    return win
end

return LunixLib
