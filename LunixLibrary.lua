local LunixLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local COL_BLUE = Color3.fromRGB(0, 80, 255)
local COL_CYAN = Color3.fromRGB(0, 210, 255)
local BG_THEME = Color3.fromRGB(10, 5, 18)

local sg = Instance.new("ScreenGui")
sg.Name = "LunixLibrary_V2"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() sg.Parent = CoreGui end) then
    sg.Parent = player:WaitForChild("PlayerGui")
end

local windowCount = 0
local activeWindows = {}

local notifHolder = Instance.new("Frame", sg)
notifHolder.Size = UDim2.new(0, 220, 1, -40)
notifHolder.Position = UDim2.new(0, 10, 0, 10)
notifHolder.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", notifHolder)
layout.Padding = UDim.new(0, 8)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function attachAnimStroke(parent)
    local s = Instance.new("UIStroke", parent)
    s.Thickness = 2
    s.Color = Color3.fromRGB(255,255,255)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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

function LunixLib:Notify(title, text, duration)
    local item = Instance.new("Frame", notifHolder)
    item.BackgroundColor3 = BG_THEME
    item.BackgroundTransparency = 0.08
    item.Size = UDim2.new(1, 0, 0, 60)

    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 10)
    attachAnimStroke(item)

    local tLabel = Instance.new("TextLabel", item)
    tLabel.Size = UDim2.new(1, -20, 0, 20)
    tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Text = title
    tLabel.TextColor3 = COL_CYAN
    tLabel.TextSize = 13
    tLabel.TextXAlignment = 0

    local bLabel = Instance.new("TextLabel", item)
    bLabel.Size = UDim2.new(1, -20, 0, 30)
    bLabel.Position = UDim2.new(0, 10, 0, 25)
    bLabel.BackgroundTransparency = 1
    bLabel.Font = Enum.Font.Gotham
    bLabel.Text = text
    bLabel.TextColor3 = Color3.new(1,1,1)
    bLabel.TextSize = 11
    bLabel.TextWrapped = true
    bLabel.TextXAlignment = 0

    task.delay(duration or 4, function()
        TweenService:Create(item, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0,0,0,0)
        }):Play()
        task.wait(0.5)
        item:Destroy()
    end)
end

function LunixLib:CreateWindow(title, sizeX, sizeY)
    windowCount += 1
    sizeX = sizeX or 220
    sizeY = sizeY or 250

    local win = {}

    local offsetX = (windowCount - 1) * (sizeX + 20)

    local main = Instance.new("Frame", sg)
    main.Name = title
    main.Size = UDim2.fromOffset(sizeX, sizeY)
    main.Position = UDim2.new(0, 50 + offsetX, 0, 100)
    main.BackgroundColor3 = BG_THEME
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    attachAnimStroke(main)
    makeDrag(main)

    local titleLbl = Instance.new("TextLabel", main)
    titleLbl.Size = UDim2.new(1, 0, 0, 35)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title:upper()
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = COL_CYAN
    titleLbl.TextSize = 15

    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1, -15, 1, -45)
    container.Position = UDim2.new(0, 7, 0, 40)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 2
    container.ScrollBarImageColor3 = COL_CYAN

    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, 8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    function win:Button(text, callback)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(14, 20, 46)
        btn.TextColor3 = COL_CYAN
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Text = text
        btn.AutoButtonColor = false

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = COL_CYAN
            btn.TextColor3 = BG_THEME
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(14, 20, 46),
                TextColor3 = COL_CYAN
            }):Play()
        end)
    end

    function win:Toggle(text, default, callback)
        local state = default or false

        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(14, 20, 46)
        btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150,150,150)
        btn.Text = (state and "●  " or "○  ") .. text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150,150,150)
            btn.Text = (state and "●  " or "○  ") .. text
            callback(state)
        end)
    end

    function win:Slider(text, min, max, default, callback)
        local holder = Instance.new("Frame", container)
        holder.Size = UDim2.new(1, -10, 0, 40)
        holder.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(1, 0, 0, 15)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = Color3.fromRGB(200,220,255)

        local bar = Instance.new("Frame", holder)
        bar.Size = UDim2.new(1, -10, 0, 6)
        bar.Position = UDim2.new(0.5, 0, 0, 25)
        bar.AnchorPoint = Vector2.new(0.5, 0)
        bar.BackgroundColor3 = Color3.fromRGB(12,16,32)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.fromScale((default-min)/(max-min), 1)
        fill.BackgroundColor3 = COL_CYAN
        fill.BorderSizePixel = 0
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
            local val = math.floor(min + (max - min) * rel)

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
        l.Size = UDim2.new(1, -10, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = Color3.new(1,1,1)
        l.TextSize = 11
        l.TextXAlignment = 0
    end

    return win
end

return LunixLib
