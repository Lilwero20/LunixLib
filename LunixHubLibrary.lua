local LunixLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local windowCount = 0

local BG_THEME = Color3.fromRGB(10, 14, 28)
local COL_CYAN = Color3.fromRGB(0, 255, 255)

local sg = Instance.new("ScreenGui")
sg.Name = "LunixLibrary"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999

pcall(function()
	sg.Parent = CoreGui
end)

if not sg.Parent then
	sg.Parent = PlayerGui
end

local notifHolder = Instance.new("Frame")
notifHolder.Name = "NotifHolder"
notifHolder.Parent = sg
notifHolder.Size = UDim2.new(0, 220, 1, -40)
notifHolder.Position = UDim2.new(0, 10, 0, 10)
notifHolder.BackgroundTransparency = 1

local notifLayout = Instance.new("UIListLayout")
notifLayout.Parent = notifHolder
notifLayout.Padding = UDim.new(0, 8)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeStroke(parent)
	local st = Instance.new("UIStroke")
	st.Parent = parent
	st.Thickness = 2.5
	st.Color = COL_CYAN
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.15, Color3.fromRGB(0, 120, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 255))
	})
	g.Parent = st

	task.spawn(function()
		while st.Parent do
			for i = 0, 360, 2 do
				if not st.Parent then
					return
				end
				g.Rotation = i
				task.wait(0.01)
			end
		end
	end)

	return st
end

local attachAnimStroke = makeStroke

local function makeDrag(frame)
	local dragging = false
	local dragStart
	local startPos

	frame.Active = true

	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = frame.Position
		end
	end)

	frame.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + d.X,
				startPos.Y.Scale,
				startPos.Y.Offset + d.Y
			)
		end
	end)

	frame.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function LunixLib:Notify(title, text, duration)
	duration = duration or 4

	local item = Instance.new("Frame")
	item.Name = "Notification"
	item.Parent = notifHolder
	item.BackgroundColor3 = Color3.fromRGB(10, 15, 35)
	item.Size = UDim2.new(1, 0, 0, 62)
	item.BackgroundTransparency = 1
	item.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = item

	local s = Instance.new("UIStroke")
	s.Parent = item
	s.Thickness = 1.5
	s.Color = COL_CYAN
	s.Transparency = 1

	local top = Instance.new("TextLabel")
	top.Parent = item
	top.BackgroundTransparency = 1
	top.Position = UDim2.new(0, 10, 0, 8)
	top.Size = UDim2.new(1, -20, 0, 18)
	top.Font = Enum.Font.GothamBold
	top.Text = title or "LUNIX HUB"
	top.TextColor3 = COL_CYAN
	top.TextSize = 13
	top.TextXAlignment = Enum.TextXAlignment.Left
	top.TextTransparency = 1

	local body = Instance.new("TextLabel")
	body.Parent = item
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 10, 0, 28)
	body.Size = UDim2.new(1, -20, 0, 28)
	body.Font = Enum.Font.Gotham
	body.Text = text or ""
	body.TextColor3 = Color3.fromRGB(255, 255, 255)
	body.TextSize = 11
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextTransparency = 1

	TweenService:Create(item, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 0.4 }):Play()
	TweenService:Create(top, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	TweenService:Create(body, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

	task.delay(duration, function()
		if not item.Parent then
			return
		end

		local out = TweenService:Create(item, TweenInfo.new(0.25), {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		})
		out:Play()
		out.Completed:Wait()

		if item then
			item:Destroy()
		end
	end)
end

function LunixLib:CreateWindow(title, sizeX, sizeY)
	windowCount = windowCount + 1
	sizeX = tonumber(sizeX) or 220
	sizeY = tonumber(sizeY) or 250
	title = tostring(title or "Window")

	local win = {}

	local offsetX = (windowCount - 1) * (sizeX + 20)

	local main = Instance.new("Frame")
	main.Parent = sg
	main.Name = title
	main.Size = UDim2.fromOffset(sizeX, sizeY)
	main.Position = UDim2.new(0, 50 + offsetX, 0, 100)
	main.BackgroundColor3 = BG_THEME
	main.BorderSizePixel = 0

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = main

	attachAnimStroke(main)
	makeDrag(main)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Parent = main
	titleLbl.Size = UDim2.new(1, 0, 0, 35)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title:upper()
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextColor3 = COL_CYAN
	titleLbl.TextSize = 15
	titleLbl.TextXAlignment = Enum.TextXAlignment.Center

	local container = Instance.new("ScrollingFrame")
	container.Parent = main
	container.Size = UDim2.new(1, -15, 1, -45)
	container.Position = UDim2.new(0, 7, 0, 40)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 2
	container.ScrollBarImageColor3 = COL_CYAN
	container.ClipsDescendants = true
	container.CanvasSize = UDim2.new(0, 0, 0, 0)

	local list = Instance.new("UIListLayout")
	list.Parent = container
	list.Padding = UDim.new(0, 8)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
	end)

	local function safeCallback(cb, ...)
		if typeof(cb) == "function" then
			local ok, err = pcall(cb, ...)
			if not ok then
				warn("[LunixLib] Callback error:", err)
			end
		end
	end

	function win:Button(text, callback)
		local btn = Instance.new("TextButton")
		btn.Parent = container
		btn.Size = UDim2.new(1, -10, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
		btn.TextColor3 = COL_CYAN
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Text = tostring(text or "Button")
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = btn

		btn.MouseButton1Click:Connect(function()
			safeCallback(callback)
			btn.BackgroundColor3 = COL_CYAN
			btn.TextColor3 = BG_THEME
			task.wait(0.1)
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(20, 25, 45),
				TextColor3 = COL_CYAN
			}):Play()
		end)
	end

	function win:Toggle(text, default, callback)
		local state = default == true

		local btn = Instance.new("TextButton")
		btn.Parent = container
		btn.Size = UDim2.new(1, -10, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
		btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150, 150, 150)
		btn.Text = (state and "●  " or "○  ") .. tostring(text or "Toggle")
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = btn

		btn.MouseButton1Click:Connect(function()
			state = not state
			btn.TextColor3 = state and COL_CYAN or Color3.fromRGB(150, 150, 150)
			btn.Text = (state and "●  " or "○  ") .. tostring(text or "Toggle")
			safeCallback(callback, state)
		end)
	end

	function win:Slider(text, min, max, default, callback)
		min = tonumber(min) or 0
		max = tonumber(max) or 100
		if max <= min then
			max = min + 1
		end

		default = tonumber(default)
		if default == nil then
			default = min
		end
		default = math.clamp(default, min, max)

		local holder = Instance.new("Frame")
		holder.Parent = container
		holder.Size = UDim2.new(1, -10, 0, 40)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel")
		label.Parent = holder
		label.Size = UDim2.new(1, 0, 0, 15)
		label.BackgroundTransparency = 1
		label.Text = tostring(text or "Slider") .. ": " .. tostring(default)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 11
		label.TextColor3 = Color3.fromRGB(200, 220, 255)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("Frame")
		bar.Parent = holder
		bar.Size = UDim2.new(1, -10, 0, 6)
		bar.Position = UDim2.new(0.5, 0, 0, 25)
		bar.AnchorPoint = Vector2.new(0.5, 0)
		bar.BackgroundColor3 = Color3.fromRGB(12, 16, 32)
		bar.BorderSizePixel = 0

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		local fill = Instance.new("Frame")
		fill.Parent = bar
		fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
		fill.BackgroundColor3 = COL_CYAN
		fill.BorderSizePixel = 0

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill

		local knob = Instance.new("Frame")
		knob.Parent = bar
		knob.Size = UDim2.fromOffset(12, 12)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0

		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		local dragging = false

		local function update(input)
			local x = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			local rel = math.clamp(x, 0, 1)
			local val = math.floor(min + (max - min) * rel + 0.5)

			fill.Size = UDim2.fromScale(rel, 1)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			label.Text = tostring(text or "Slider") .. ": " .. tostring(val)

			safeCallback(callback, val)
		end

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(i)
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

		safeCallback(callback, default)
	end

	function win:Label(text)
		local l = Instance.new("TextLabel")
		l.Parent = container
		l.Size = UDim2.new(1, -10, 0, 20)
		l.BackgroundTransparency = 1
		l.Text = tostring(text or "")
		l.Font = Enum.Font.Gotham
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextSize = 12
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.BorderSizePixel = 0
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.TextWrapped = true

		return l
	end

	return win
end

return LunixLib
