-- Jan's UI Library
local UI = {flags = {}, windows = {}, open = true}

--Services
local runService = game:GetService"RunService"
local tweenService = game:GetService"TweenService"
local textService = game:GetService"TextService"
local inputService = game:GetService"UserInputService"

--Locals
local dragging, dragInput, dragStart, startPos, dragObject

local blacklistedKeys = { --add or remove keys if you find the need to
	Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape
}
local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
	Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
}

--Functions
local function round(num, bracket)
	bracket = bracket or 1
	local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
	if a < 0 then
		a = a + bracket
	end
	return a
end

local function keyCheck(x,x1)
	for _,v in next, x1 do
		if v == x then
			return true
		end
	end
end

local function update(input)
	local delta = input.Position - dragStart
	local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
	dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
end

--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
local rainbowTime = 5
spawn(function()
	while wait() do
		chromaColor = Color3.fromHSV(tick() % rainbowTime / rainbowTime, 1, 1)
	end
end)

function UI:Create(class, properties)
	properties = typeof(properties) == "table" and properties or {}
	local inst = Instance.new(class)
	for property, value in next, properties do
		inst[property] = value
	end
	return inst
end

local function createOptionHolder(holderTitle, parent, parentTable, subHolder)
	local size = subHolder and 34 or 40
	parentTable.main = UI:Create("ImageButton", {
		LayoutOrder = subHolder and parentTable.position or 0,
		Position = UDim2.new(0, 20 + (250 * (parentTable.position or 0)), 0, 20),
		Size = UDim2.new(0, 230, 0, size),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.04,
		ClipsDescendants = true,
		Parent = parent
	})
	
	local round
	if not subHolder then
		round = UI:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, size),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = parentTable.open and (subHolder and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)) or (subHolder and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.04,
			Parent = parentTable.main
		})
	end
	
	local title = UI:Create("TextLabel", {
		RichText = true,
		RichText = true,
		Size = UDim2.new(1, 0, 0, size),
		BackgroundTransparency = subHolder and 0 or 1,
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderSizePixel = 0,
		Text = holderTitle,
		TextSize = subHolder and 16 or 17,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = parentTable.main
	})
	
	local closeHolder = UI:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = title
	})
	
	local close = UI:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -size - 10, 1, -size - 10),
		Rotation = parentTable.open and 90 or 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Fit,
		Parent = closeHolder
	})
	
	parentTable.content = UI:Create("Frame", {
		Position = UDim2.new(0, 0, 0, size),
		Size = UDim2.new(1, 0, 1, -size),
		BackgroundTransparency = 1,
		Parent = parentTable.main
	})
	
	local layout = UI:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parentTable.content
	})
	
	layout.Changed:connect(function()
		parentTable.content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		parentTable.main.Size = #parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size)
	end)
	
	if not subHolder then
		UI:Create("UIPadding", {
			Parent = parentTable.content
		})
		
		title.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragObject = parentTable.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
			end
		end)
		title.InputChanged:connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
			title.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end
	
	closeHolder.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			parentTable.open = not parentTable.open
			tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if subHolder then
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
		end
	end)

	function parentTable:SetTitle(newTitle)
		title.Text = tostring(newTitle)
	end
	
	return parentTable
end
	
local function createLabel(option, parent)
	local main = UI:Create("TextLabel", {
		RichText = true,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end

function createToggle(option, parent)
	local main = UI:Create("TextLabel", {
		RichText = true,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local tickboxOutline = UI:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and Color3.fromRGB(21, 100, 191) or Color3.fromRGB(100, 100, 100),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local tickboxInner = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.state and Color3.fromRGB(21, 100, 191) or Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = tickboxOutline
	})
	
	local checkmarkHolder = UI:Create("Frame", {
		Position = UDim2.new(0, 4, 0, 4),
		Size = option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = tickboxOutline
	})
	
	local checkmark = UI:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4919148038",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		Parent = checkmarkHolder
	})
	
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			option:SetState(not option.state)
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	function option:SetState(state)
		UI.flags[self.flag] = state
		self.state = state
		checkmarkHolder:TweenSize(option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
		tweenService:Create(tickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = state and Color3.fromRGB(21, 100, 191) or Color3.fromRGB(20, 20, 20)}):Play()
		if state then
			tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
		else
			if inContact then
				tweenService:Create(tickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			else
				tweenService:Create(tickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
		self.callback(state)
	end

	if option.state then
		delay(1, function() option.callback(true) end)
	end
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			main.Text = " " .. tostring(v)
		end
	end})
end

function createButton(option, parent)
	local main = UI:Create("TextLabel", {
		RichText = true,
		ZIndex = 2,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = parent.content
	})
	
	local round = UI:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local inContact
	local clicking
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UI.flags[option.flag] = true
			clicking = true
			tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
			option.callback()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			clicking = false
			if inContact then
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not clicking then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
end

local function createBind(option, parent)
	local binding
	local holding
	local loop
	local text = string.match(option.key, "Mouse") and string.sub(option.key, 1, 5) .. string.sub(option.key, 12, 13) or option.key

	local main = UI:Create("TextLabel", {
		RichText = true,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 33),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local round = UI:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -textService:GetTextSize(text, 16, Enum.Font.Gotham, Vector2.new(9e9, 9e9)).X - 16, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local bindinput = UI:Create("TextLabel", {
		RichText = true,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 16,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = round
	})
	
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not binding then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	 
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			binding = true
			bindinput.Text = "..."
			tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not binding then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
	
	inputService.InputBegan:connect(function(input)
		if inputService:GetFocusedTextBox() then return end
		if (input.KeyCode.Name == option.key or input.UserInputType.Name == option.key) and not binding then
			if option.hold then
				loop = runService.Heartbeat:connect(function()
					if binding then
						option.callback(true)
						loop:Disconnect()
						loop = nil
					else
						option.callback()
					end
				end)
			else
				option.callback()
			end
		elseif binding then
			local key
			pcall(function()
				if not keyCheck(input.KeyCode, blacklistedKeys) then
					key = input.KeyCode
				end
			end)
			pcall(function()
				if keyCheck(input.UserInputType, whitelistedMouseinputs) and not key then
					key = input.UserInputType
				end
			end)
			key = key or option.key
			option:SetKey(key)
		end
	end)
	
	inputService.InputEnded:connect(function(input)
		if input.KeyCode.Name == option.key or input.UserInputType.Name == option.key or input.UserInputType.Name == "MouseMovement" then
			if loop then
				loop:Disconnect()
				loop = nil
				option.callback(true)
			end
		end
	end)
	
	function option:SetKey(key)
		binding = false
		if loop then
			loop:Disconnect()
			loop = nil
		end
		self.key = key or self.key
		self.key = self.key.Name or self.key
		UI.flags[self.flag] = self.key
		if string.match(self.key, "Mouse") then
			bindinput.Text = string.sub(self.key, 1, 5) .. string.sub(self.key, 12, 13)
		else
			bindinput.Text = self.key
		end
		tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
		round.Size = UDim2.new(0, -textService:GetTextSize(bindinput.Text, 15, Enum.Font.Gotham, Vector2.new(9e9, 9e9)).X - 16, 1, -10)	
	end
end

local function createSlider(option, parent)
	local main = UI:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local title = UI:Create("TextLabel", {
		RichText = true,
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local slider = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 10, 0, 34),
		Size = UDim2.new(1, -20, 0, 5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local fill = UI:Create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = slider
	})
	
	local circle = UI:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 0.5, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 1,
		Parent = slider
	})
	
	local valueRound = UI:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -60, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local inputvalue = UI:Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = option.value,
		TextColor3 = Color3.fromRGB(235, 235, 235),
		TextSize = 15,
		TextWrapped = true,
		Font = Enum.Font.Gotham,
		Parent = valueRound
	})
	
	if option.min >= 0 then
		fill.Size = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 1, 0)
	else
		fill.Position = UDim2.new((0 - option.min) / (option.max - option.min), 0, 0, 0)
		fill.Size = UDim2.new(option.value / (option.max - option.min), 0, 1, 0)
	end
	
	local sliding
	local inContact
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
			tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(3.5, 0, 3.5, 0), ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
			sliding = true
			option:SetValue(option.min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (option.max - option.min))
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	inputService.InputChanged:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
			option:SetValue(option.min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (option.max - option.min))
		end
	end)

	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
			if inContact then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			else
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			inputvalue:ReleaseFocus()
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)

	inputvalue.FocusLost:connect(function()
		tweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		option:SetValue(tonumber(inputvalue.Text) or option.value)
	end)

	function option:SetValue(value)
		value = round(value, option.float)
		value = math.clamp(value, self.min, self.max)
		circle:TweenPosition(UDim2.new((value - self.min) / (self.max - self.min), 0, 0.5, 0), "Out", "Quad", 0.1, true)
		if self.min >= 0 then
			fill:TweenSize(UDim2.new((value - self.min) / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		else
			fill:TweenPosition(UDim2.new((0 - self.min) / (self.max - self.min), 0, 0, 0), "Out", "Quad", 0.1, true)
			fill:TweenSize(UDim2.new(value / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		end
		UI.flags[self.flag] = value
		self.value = value
		inputvalue.Text = value
		self.callback(value)
	end
end

local function createList(option, parent, holder)
	local valueCount = 0
	
	local main = UI:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local round = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local title = UI:Create("TextLabel", {
		RichText = true,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local listvalue = UI:Create("TextLabel", {
		RichText = true,
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = option.value,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	UI:Create("ImageLabel", {
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(-1, 32, 1, -32),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 90,
		Image = "rbxassetid://4918373417",
		ImageColor3 = Color3.fromRGB(140, 140, 140),
		ScaleType = Enum.ScaleType.Fit,
		Parent = round
	})
	
	option.mainHolder = UI:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, 240, 0, 52),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Visible = false,
		Parent = UI.base
	})
	
	local content = UI:Create("ScrollingFrame", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.fromRGB(),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = option.mainHolder
	})
	
	UI:Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		Parent = content
	})
	
	local layout = UI:Create("UIListLayout", {
		Parent = content
	})
	
	layout.Changed:connect(function()
		option.mainHolder.Size = UDim2.new(0, 240, 0, (valueCount > 4 and (4 * 40) or layout.AbsoluteContentSize.Y) + 12)
		content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)
	
	local inContact
	round.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if UI.activePopup then
				UI.activePopup:Close()
			end
			local position = main.AbsolutePosition
			option.mainHolder.Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)
			option.open = true
			option.mainHolder.Visible = true
			UI.activePopup = option
			content.ScrollBarThickness = 6
			tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, position.X - 5, 0, position.Y - 4)}):Play()
			tweenService:Create(option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, position.X - 5, 0, position.Y + 1)}):Play()
			for _,label in next, content:GetChildren() do
				if label:IsA"TextLabel" then
					tweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	
	round.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
	
	function option:AddValue(value)
		valueCount = valueCount + 1
		local label = UI:Create("TextLabel", {
			RichText = true,
			ZIndex = 3,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Text = "    " .. value,
			TextSize = 14,
			TextTransparency = self.open and 0 or 1,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = content
		})
		
		local inContact
		local clicking
		label.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				clicking = true
				tweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}):Play()
				self:SetValue(value)
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				inContact = true
				if not clicking then
					tweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
				end
			end
		end)
		
		label.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				clicking = false
				tweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = inContact and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(30, 30, 30)}):Play()
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				inContact = false
				if not clicking then
					tweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
				end
			end
		end)
	end

	if not table.find(option.values, option.value) then
		option:AddValue(option.value)
	end
	
	for _, value in next, option.values do
		option:AddValue(tostring(value))
	end
	
	function option:RemoveValue(value)
		for _,label in next, content:GetChildren() do
			if label:IsA"TextLabel" and label.Text == "	" .. value then
				label:Destroy()
				valueCount = valueCount - 1
				break
			end
		end
		if self.value == value then
			self:SetValue("")
		end
	end
	
	function option:SetValue(value)
		UI.flags[self.flag] = tostring(value)
		self.value = tostring(value)
		listvalue.Text = self.value
		self.callback(value)
		option:Close()
	end
	
	function option:Close()
		UI.activePopup = nil
		self.open = false
		content.ScrollBarThickness = 0
		local position = main.AbsolutePosition
		tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
		tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, position.X - 5, 0, position.Y -10)}):Play()
		for _,label in next, content:GetChildren() do
			if label:IsA"TextLabel" then
				tweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			end
		end
		wait(0.3)
		--delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end
		--end)
	end

	return option
end

local function createBox(option, parent)
	local main = UI:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local outline = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local round = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0, 6),
		Size = UDim2.new(1, -16, 1, -14),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.01,
		Parent = main
	})
	
	local title = UI:Create("TextLabel", {
		RichText = true,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(100, 100, 100),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local inputvalue = UI:Create("TextBox", {
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = option.value,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = main
	})
	
	local inContact
	local focused
	main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not focused then inputvalue:CaptureFocus() end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	
	inputvalue.Focused:connect(function()
		focused = true
		tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(21, 100, 191)}):Play()
	end)
	
	inputvalue.FocusLost:connect(function(enter)
		focused = false
		tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		option:SetValue(inputvalue.Text, enter)
	end)
	
	function option:SetValue(value, enter)
		UI.flags[self.flag] = tostring(value)
		self.value = tostring(value)
		inputvalue.Text = self.value
		self.callback(value, enter)
	end
end

local function createColorPickerWindow(option)
	option.mainHolder = UI:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, 240, 0, 180),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = UI.base
	})
		
	local hue, sat, val = Color3.toHSV(option.color)
	hue, sat, val = hue == 0 and 1 or hue, sat + 0.005, val - 0.005
	local editinghue
	local editingsatval
	local currentColor = option.color
	local previousColors = {[1] = option.color}
	local originalColor = option.color
	local rainbowEnabled
	local rainbowLoop
	
	function option:updateVisuals(Color)
		currentColor = Color
		self.visualize2.ImageColor3 = Color
		hue, sat, val = Color3.toHSV(Color)
		hue = hue == 0 and 1 or hue
		self.satval.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		self.hueSlider.Position = UDim2.new(1 - hue, 0, 0, 0)
		self.satvalSlider.Position = UDim2.new(sat, 0, 1 - val, 0)
	end
	
	option.hue = UI:Create("ImageLabel", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -100, 0, 22),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	local Gradient = UI:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.157, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.323, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.488, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.817, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = option.hue
	})
	
	option.hueSlider = UI:Create("Frame", {
		ZIndex = 3,
		Position = UDim2.new(1 - hue, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.hue
	})
	
	option.hue.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editinghue = true
			X = (option.hue.AbsolutePosition.X + option.hue.AbsoluteSize.X) - option.hue.AbsolutePosition.X
			X = (Input.Position.X - option.hue.AbsolutePosition.X) / X
			X = X < 0 and 0 or X > 0.995 and 0.995 or X
			option:updateVisuals(Color3.fromHSV(1 - X, sat, val))
		end
	end)
	
	inputService.InputChanged:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and editinghue then
			X = (option.hue.AbsolutePosition.X + option.hue.AbsoluteSize.X) - option.hue.AbsolutePosition.X
			X = (Input.Position.X - option.hue.AbsolutePosition.X) / X
			X = X <= 0 and 0 or X >= 0.995 and 0.995 or X
			option:updateVisuals(Color3.fromHSV(1 - X, sat, val))
		end
	end)
	
	option.hue.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editinghue = false
		end
	end)
	
	option.satval = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -100, 1, -42),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://4155801252",
		ImageTransparency = 1,
		ClipsDescendants = true,
		Parent = option.mainHolder
	})
	
	option.satvalSlider = UI:Create("Frame", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(sat, 0, 1 - val, 0),
		Size = UDim2.new(0, 4, 0, 4),
		Rotation = 45,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.satval
	})
	
	option.satval.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editingsatval = true
			X = (option.satval.AbsolutePosition.X + option.satval.AbsoluteSize.X) - option.satval.AbsolutePosition.X
			Y = (option.satval.AbsolutePosition.Y + option.satval.AbsoluteSize.Y) - option.satval.AbsolutePosition.Y
			X = (Input.Position.X - option.satval.AbsolutePosition.X) / X
			Y = (Input.Position.Y - option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			option:updateVisuals(Color3.fromHSV(hue, X, 1 - Y))
		end
	end)
	
	inputService.InputChanged:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and editingsatval then
			X = (option.satval.AbsolutePosition.X + option.satval.AbsoluteSize.X) - option.satval.AbsolutePosition.X
			Y = (option.satval.AbsolutePosition.Y + option.satval.AbsoluteSize.Y) - option.satval.AbsolutePosition.Y
			X = (Input.Position.X - option.satval.AbsolutePosition.X) / X
			Y = (Input.Position.Y - option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			option:updateVisuals(Color3.fromHSV(hue, X, 1 - Y))
		end
	end)
	
	option.satval.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			editingsatval = false
		end
	end)
	
	option.visualize2 = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.new(0, -80, 0, 80),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = currentColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.resetColor = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.resetText = UI:Create("TextLabel", {
		RichText = true,
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Reset",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.resetColor
	})
	
	option.resetColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			previousColors = {originalColor}
			option:SetColor(originalColor)
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	option.resetColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	option.undoColor = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 112),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.undoText = UI:Create("TextLabel", {
		RichText = true,
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Undo",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.undoColor
	})
	
	option.undoColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			local Num = #previousColors == 1 and 0 or 1
			option:SetColor(previousColors[#previousColors - Num])
			if #previousColors ~= 1 then
				table.remove(previousColors, #previousColors)
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	option.undoColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	option.setColor = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 132),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.setText = UI:Create("TextLabel", {
		RichText = true,
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Set",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.setColor
	})
	
	option.setColor.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not rainbowEnabled then
			table.insert(previousColors, currentColor)
			option:SetColor(currentColor)
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	option.setColor.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	option.rainbow = UI:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 152),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	option.rainbowText = UI:Create("TextLabel", {
		RichText = true,
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Rainbow",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = option.rainbow
	})
	
	option.rainbow.InputBegan:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			rainbowEnabled = not rainbowEnabled
			if rainbowEnabled then
				rainbowLoop = runService.Heartbeat:connect(function()
					option:SetColor(chromaColor)
					option.rainbowText.TextColor3 = chromaColor
				end)
			else
				rainbowLoop:Disconnect()
				option:SetColor(previousColors[#previousColors])
				option.rainbowText.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	option.rainbow.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not dragging then
			tweenService:Create(option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	return option
end

local function createColor(option, parent, holder)
	option.main = UI:Create("TextLabel", {
		RichText = true,
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local colorBoxOutline = UI:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(100, 100, 100),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.main
	})
	
	option.visualize = UI:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = colorBoxOutline
	})
	
	local inContact
	option.main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not option.mainHolder then createColorPickerWindow(option) end
			if UI.activePopup then
				UI.activePopup:Close()
			end
			local position = option.main.AbsolutePosition
			option.mainHolder.Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)
			option.open = true
			option.mainHolder.Visible = true
			UI.activePopup = option
			tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, position.X - 5, 0, position.Y - 4)}):Play()
			tweenService:Create(option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, position.X - 5, 0, position.Y + 1)}):Play()
			tweenService:Create(option.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			for _,object in next, option.mainHolder:GetDescendants() do
				if object:IsA"TextLabel" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif object:IsA"ImageLabel" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
				elseif object:IsA"Frame" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			end
		end
	end)
	
	option.main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	function option:SetColor(newColor)
		if self.mainHolder then
			self:updateVisuals(newColor)
		end
		self.visualize.ImageColor3 = newColor
		UI.flags[self.flag] = newColor
		self.color = newColor
		self.callback(newColor)
	end
	
	function option:Close()
		UI.activePopup = nil
		self.open = false
		local position = self.main.AbsolutePosition
		tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)}):Play()
		tweenService:Create(self.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		for _,object in next, self.mainHolder:GetDescendants() do
			if object:IsA"TextLabel" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			elseif object:IsA"ImageLabel" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			elseif object:IsA"Frame" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end
		delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end 
		end)
	end
end

local function loadOptions(option, holder)
	for _,newOption in next, option.options do
		if newOption.type == "label" then
			createLabel(newOption, option)
		elseif newOption.type == "toggle" then
			createToggle(newOption, option)
		elseif newOption.type == "button" then
			createButton(newOption, option)
		elseif newOption.type == "list" then
			createList(newOption, option, holder)
		elseif newOption.type == "box" then
			createBox(newOption, option)
		elseif newOption.type == "bind" then
			createBind(newOption, option)
		elseif newOption.type == "slider" then
			createSlider(newOption, option)
		elseif newOption.type == "color" then
			createColor(newOption, option, holder)
		elseif newOption.type == "folder" then
			newOption:init()
		end
	end
end

local function getFnctions(parent)
	function parent:AddLabel(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.type = "label"
		option.position = #self.options
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddToggle(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.state = typeof(option.state) == "boolean" and option.state or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "toggle"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.state
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddButton(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "button"
		option.position = #self.options
		option.flag = option.flag or option.text
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBind(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.key = (option.key and option.key.Name) or option.key or "F"
		option.hold = typeof(option.hold) == "boolean" and option.hold or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "bind"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.key
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddSlider(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.min = typeof(option.min) == "number" and option.min or 0
		option.max = typeof(option.max) == "number" and option.max or 0
		option.dual = typeof(option.dual) == "boolean" and option.dual or false
		option.value = math.clamp(typeof(option.value) == "number" and option.value or option.min, option.min, option.max)
		option.value2 = typeof(option.value2) == "number" and option.value2 or option.max
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.float = typeof(option.value) == "number" and option.float or 1
		option.type = "slider"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddList(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.values = typeof(option.values) == "table" and option.values or {}
		option.value = tostring(option.value or option.values[1] or "")
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "list"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBox(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.value = tostring(option.value or "")
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "box"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddColor(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.color = typeof(option.color) == "table" and Color3.new(tonumber(option.color[1]), tonumber(option.color[2]), tonumber(option.color[3])) or option.color or Color3.new(255, 255, 255)
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "color"
		option.position = #self.options
		option.flag = option.flag or option.text
		UI.flags[option.flag] = option.color
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddFolder(title)
		local option = {}
		option.title = tostring(title)
		option.options = {}
		option.open = false
		option.type = "folder"
		option.position = #self.options
		table.insert(self.options, option)
		
		getFnctions(option)
		
		function option:init()
			createOptionHolder(self.title, parent.content, self, true)
			loadOptions(self, parent)
		end
		
		return option
	end
end

function UI:CreateWindow(title)
	local window = {title = tostring(title), options = {}, open = true, canInit = true, init = false, position = #self.windows}
	getFnctions(window)
	
	table.insert(UI.windows, window)
	
	return window
end

local UIToggle
local UnlockMouse
function UI:Init()
	
	self.base = self:Create("ScreenGui")
	self.base.Parent = game:GetService("CoreGui")
	
	self.cursor = self.cursor or self:Create("Frame", {
		ZIndex = 100,
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.new(0, 5, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Visible = false,
		Parent = self.base
	})
	
	for _, window in next, self.windows do
		if window.canInit and not window.init then
			window.init = true
			createOptionHolder(window.title, self.base, window)
			loadOptions(window)
		end
	end
end

function UI:Close()
	self.open = not self.open
	self.cursor.Visible = false --self.open
	if self.activePopup then
		self.activePopup:Close()
	end
	for _, window in next, self.windows do
		if window.main then
			window.main.Visible = self.open
		end
	end
end

inputService.InputBegan:connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UI.activePopup then
			if input.Position.X < UI.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < UI.activePopup.mainHolder.AbsolutePosition.Y then
				UI.activePopup:Close()
			end
		end
		if UI.activePopup then
			if input.Position.X > UI.activePopup.mainHolder.AbsolutePosition.X + UI.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > UI.activePopup.mainHolder.AbsolutePosition.Y + UI.activePopup.mainHolder.AbsoluteSize.Y then
				UI.activePopup:Close()
			end
		end
	end
end)

inputService.InputChanged:connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and UI.cursor then
		local mouse = inputService:GetMouseLocation() + Vector2.new(0, -36)
		UI.cursor.Position = UDim2.new(0, mouse.X - 2, 0, mouse.Y - 2)
	end
	if input == dragInput and dragging then
		update(input)
	end
end)

--[[
    Developers: Aviansie6
    Scripter, Designer & Owner
    
    Helpers: NotLoshe & Gia
    Testers & Supporters
]]--

-- Start Loading Timer
local StartTick = tick()

-- Roblox Services
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ChatService = game:GetService("Chat")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Environment Variables
local setupvalue = debug.setupvalue
local getupvalue = debug.getupvalue
local getupvalues = debug.getupvalues
local setstack = debug.setstack
local getstack = debug.getstack
local getreg = getreg or debug.getreg
local getgc = getgc
local require = require or syn.require

-- Settings
Settings = {
    License = _G.Key or "",
    Discord = "T6GrGzYCjR",
    DragSpeed = TweenInfo.new(0.1),
    Whitelist = {},
    Captions = {
        'The <b>best</b> <font color="rgb(196, 40, 28)">ROBLOX</font> Multi-Tool and Hub'
    },
    Saved = {
        TOS = false,
        ["Skip Loading"] = false,
        Scripts = {
            Car = {
                Speed = 70,
                Stick = 0.05,
                Height = -1.03,
            },
        },
        Games = {
            MM2 = {},
            Arsenal = {},
        },
    },
    TOS = [[By clicking <font color="rgb(40, 196, 28)">Agree</font>, you acknowledge that
    <font color="#1564BF">Avian</font>Hub does NOT log player data, user data
    or IP addresses. <font color="#1564BF">Avian</font>Hub is a private script and 
    eaking it will result in a <font color="rgb(196, 40, 28)">Blacklist</font> meaning you can
    NOT use the script anymore, the same as if you
    attempt to crack the script, or reverse it.]],
}

function Settings:Save()
    writefile("Aviansie.json", HttpService:JSONEncode(Settings.Saved))
end

-- Check Saved
pcall(function()
    Settings.Saved = HttpService:JSONDecode(readfile("Aviansie.json"))
end)

-- Instance.new Minified
local Make = function(Name, Props)
    local Inst = Instance.new(Name)
    for i,v in next, Props do
        Inst[i] = v
    end
    return Inst
end

-- Drawing.new Minified
local Draw = function(Name, Props)
    local Inst = Drawing.new(Name)
    for i,v in next, Props do
        Inst[i] = v
    end
    return Inst
end

-- Event UI
local Event = {}
function Event:Bind(Signal, Callback)
    local Functions = {}
    local Connection = Signal:Connect(function(...)
        Callback(tostring(Signal):split(" ")[2], ...)
    end)
    function Functions:UnBind()
        return Connection:Disconnect()
    end
    return Functions
end

-- Join Discord Method
local JoinDiscord = function(Invite)
    if request then
        request({
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/j/local/son',
                ['Origin'] = 'https://discord.com'
            },
            Body = game:GetService('HttpService'):JSONEncode({
                ["cmd"] = "INVITE_BROWSER",
                ["nonce"] = 1,
                ["args"] = {
                    ["code"] = Settings.Invite or Invite
                },
            }),
        })
    end
end

-- Get Player By Partial Name
local GetPlayerPartial = function(Target)
    for i,v in next, Players:GetChildren() do
        if v.Name:match(string.sub()) then
            return v.Name
        end
    end
end

-- Visual UI
local Visual = {}
function Visual:Create()
    local Element = {}
    
    return Element
end

-- Create Gui
local ScreenGui = Make("ScreenGui", {
    Parent = CoreGui,
    DisplayOrder = 100,
    ResetOnSpawn = false,
})

-- Show Loading Sequence
local Main
local Title
local Caption
if not Settings.Saved["Skip Loading"] then
    Main = Make("Frame", {
        Parent = ScreenGui,
        Position = UDim2.new(.5,-175,.5,0),
        Size = UDim2.new(0,350,0,0),
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        BorderSizePixel = 0,
    })
    Make("UICorner", {
        Parent = Main,
        CornerRadius = UDim.new(0,4)
    })
    TweenService:Create(Main, TweenInfo.new(1), {
        Position = UDim2.new(.5,-175,.5,-100),
        Size = UDim2.new(0,350,0,200),
    }):Play()
    
    wait(1)
    
    Title = Make("TextLabel", {
    	RichText = true,
        Parent = Main,
        RichText = true,
        Position = UDim2.new(.5,0,.4,0),
        Size = UDim2.new(0),
        Text = '<font color="#1564BF">Avian</font>Hub',
        TextSize = 40,
        BackgroundTransparency = 1,
        Font = "SourceSansLight",
        TextColor3 = Color3.fromRGB(200,200,200),
        TextTransparency = 1
    })
    TweenService:Create(Title, TweenInfo.new(.5), {
        Position = UDim2.new(.5,0,.45,0),
        TextTransparency = 0
    }):Play()
    
    wait(1)
    
    local RandomCaption = Settings.Captions[math.random(#Settings.Captions)]
    Caption = Make("TextLabel", {
    	RichText = true,
        Parent = Main,
        RichText = true,
        Position = UDim2.new(.5,0,.55,0),
        Size = UDim2.new(0),
        Text = RandomCaption,
        TextSize = 20,
        BackgroundTransparency = 1,
        Font = "SourceSans",
        TextColor3 = Color3.fromRGB(200,200,200),
        TextTransparency = 1
    })
    
    TweenService:Create(Caption, TweenInfo.new(.5), {
        Position = UDim2.new(.5,0,.6,0),
        TextTransparency = 0
    }):Play()
    wait(2)
    TweenService:Create(Caption, TweenInfo.new(.5), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 1
    }):Play()
    wait(1)
    Title.Text = 'Loading <font color="#1564BF">Scripts</font>.'
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(Title, TweenInfo.new(.5), {
        Position = UDim2.new(.5,0,.5,0),
    }):Play()
    
    -- Finish Timer
    local EndTick = tick() - StartTick
    local LoadTime = string.format("%d.0", EndTick)
    
    wait(2)
    
    wait(1)
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 1
    }):Play()
    wait(1)
    Title.Position = UDim2.new(.5,0,.45,0)
    Title.Text = "<b>Thank You</b>"
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 0
    }):Play()
    wait(1)
    Caption.Position = UDim2.new(.5,0,.6,0)
    Caption.Text = 'For choosing <font color="#1564BF">Avian</font>Hub.'
    TweenService:Create(Caption, TweenInfo.new(.5), {
        TextTransparency = 0
    }):Play()
    wait(1)
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(Caption, TweenInfo.new(.5), {
        TextTransparency = 1
    }):Play()
end

if not Settings.Saved.TOS then
    wait(1)
    Title.TextXAlignment = "Left"
    Title.Font = "SourceSansSemibold"
    Title.Text = "Terms Of Service"
    Title.TextSize = 30
    Title.Position = UDim2.new(0,10,0,25)
    TweenService:Create(Title, TweenInfo.new(.5), {
        TextTransparency = 0
    }):Play()

    Caption.Position = UDim2.new(.5,-5,.5,0)
    Caption.TextSize = 18
    Caption.Text = Settings.TOS
    TweenService:Create(Caption, TweenInfo.new(.5), {
        TextTransparency = 0
    }):Play()
    
    local Agree = Make("TextButton", {
        Parent = Main,
        AutoButtonColor = false,
        Text = "Agree",
        TextColor3 = Color3.fromRGB(40, 196, 28),
        Position = UDim2.new(.5,-25,1,-40),
        Size = UDim2.new(0,50,0,30),
        BackgroundColor3 = Color3.fromRGB(17,17,17)
    })
    Make("UICorner", {
        Parent = Agree,
        CornerRadius = UDim.new(0,4)
    })
    Agree.MouseEnter:Connect(function()
        TweenService:Create(Agree, TweenInfo.new(.5), {
        BackgroundColor3 = Color3.fromRGB(25,25,25)
        }):Play()
    end)
    Agree.MouseLeave:Connect(function()
        TweenService:Create(Agree, TweenInfo.new(.5), {
        BackgroundColor3 = Color3.fromRGB(17,17,17)
        }):Play()
    end)
    Agree.MouseButton1Click:Connect(function()
        Settings.Saved.TOS = true
        Settings:Save()
        TweenService:Create(Agree, TweenInfo.new(.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        wait(1)
        TweenService:Create(Caption, TweenInfo.new(.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        TweenService:Create(Title, TweenInfo.new(.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        wait(1)
        TweenService:Create(Main, TweenInfo.new(1), {
            Position = UDim2.new(.5,0,.5,0),
            Size = UDim2.new(0,0,0,0),
        }):Play()
        wait(1)
        ScreenGui:Destroy()
    end)
else
    ScreenGui:Destroy()
end

repeat wait() until Settings.Saved.TOS

wait(1)

-- Universal Tabs
local Tab_Universal = UI:CreateWindow("Universal")
local FEScripts = function()
    local Folder_FE = Tab_Universal:AddFolder('FE Scripts')
    local Folder_R15 = Folder_FE:AddFolder('R15 Scripts')
    local Folder_Scaling = Folder_R15:AddFolder("Body Scaling")
    Folder_Scaling:AddButton({
        text = "Huge Head",
        callback = function()
            local Character = LocalPlayer.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local rm = function()
            	for i,v in pairs(Character:GetDescendants()) do
            		if v:IsA("BasePart") then
            			if v.Name == "Handle" or v.Name == "Head" then
            				if Character.Head:FindFirstChild("OriginalSize") then
            					Character.Head.OriginalSize:Destroy()
            				end
            			else
            				for i,cav in pairs(v:GetDescendants()) do
            					if cav:IsA("Attachment") then
            						if cav:FindFirstChild("OriginalPosition") then
            							cav.OriginalPosition:Destroy()  
            						end
            					end
            				end
            				v:FindFirstChild("OriginalSize"):Destroy()
            				if v:FindFirstChild("AvatarPartScaleType") then
            					v:FindFirstChild("AvatarPartScaleType"):Destroy()
            				end
            			end
            		end
            	end
            end
            rm()
            wait(0.5)
            Humanoid:FindFirstChild("BodyProportionScale"):Destroy()
            wait(1)
            rm()
            wait(0.5)
            Humanoid:FindFirstChild("BodyHeightScale"):Destroy()
            wait(1)
            rm()
            wait(0.5)
            Humanoid:FindFirstChild("BodyWidthScale"):Destroy()
            wait(1)
            rm()
            wait(0.5)
            Humanoid:FindFirstChild("BodyDepthScale"):Destroy()
            wait(1)
            rm()
            wait(0.5)
            Humanoid:FindFirstChild("HeadScale"):Destroy()
            wait(1)
        end
    })
    local Folder_R6 = Folder_FE:AddFolder('R6 Scripts')
    local Folder_Car = Folder_R6:AddFolder('Car Accessory')
    Folder_Car:AddButton({
        text = "Activate",
        callback = function()
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Saved.Scripts.Car.Speed
            LocalPlayer.Character.Humanoid.JumpPower = 0.0001
            local Animation = Instance.new("Animation")
            Animation.AnimationId="rbxassetid://129342287"
            local Track = LocalPlayer.Character.Humanoid:LoadAnimation(Animation)
            Track:Play()
            Track:AdjustSpeed(1)
            for i,v in next, LocalPlayer.Character:GetDescendants() do
                if v.ClassName == "Part" then
                    v.CustomPhysicalProperties = PhysicalProperties.new(Settings.Saved.Scripts.Car.Stick,0,0)
                end
            end
            local Character = LocalPlayer.Character
            Character:FindFirstChild("Humanoid").HipHeight = Settings.Saved.Scripts.Car.Height
            wait(1.5)
            for i=1, 1 do
                repeat Character:FindFirstChild("Humanoid").HipHeight = Settings.Saved.Scripts.Car.Height - n
                    wait(.4)
                    Character:FindFirstChild("Humanoid").HipHeight = Settings.Saved.Scripts.Car.Height + n
                    wait(.4)
                until Character:FindFirstChild("Humanoid").Health == 0
            end
        end
    })
    Folder_Car:AddBox({
        text = "Stick",
        callback = function(state)
            Settings.Saved.Scripts.Car.Stick = state
            for i,v in next, LocalPlayer.Character:GetDescendants() do
                if v.ClassName == "Part" then
                    v.CustomPhysicalProperties = PhysicalProperties.new(state,0,0)
                end
            end
        end
    })
    Folder_Car:AddBox({
        text = "Speed",
        callback = function(state)
            Settings.Saved.Scripts.Car.Speed = state
        end
    })
    Folder_Car:AddBox({
        text = "Height",
        callback = function(state)
            Settings.Saved.Scripts.Car.Height = state
            local Character = LocalPlayer.Character
            Character:FindFirstChild("Humanoid").HipHeight = state
            wait(1.5)
            repeat Character:FindFirstChild("Humanoid").HipHeight = state - n
                wait(.4)
                Character:FindFirstChild("Humanoid").HipHeight = state + n
                wait(.4)
            until Character:FindFirstChild("Humanoid").Health == 0
        end
    })
end
local UniversalVisuals = function()
    local Folder_Visuals = Tab_Universal:AddFolder('Visuals')
    Folder_Visuals:AddToggle({
        text = "ESP",
        state = Settings.Saved["ESP"] or false,
        callback = function(state)
            Settings.Saved["ESP"] = state
        end
    })
    Folder_Visuals:AddToggle({
        text = "CHAMS",
        state = Settings.Saved["CHAMS"] or false,
        callback = function(state)
            Settings.Saved["CHAMS"] = state
        end
    })
    Folder_Visuals:AddToggle({
        text = "Names",
        state = Settings.Saved["Names"] or false,
        callback = function(state)
            Settings.Saved["Names"] = state
        end
    })
    Folder_Visuals:AddToggle({
        text = "Distance",
        state = Settings.Saved["Distance"] or false,
        callback = function(state)
            Settings.Saved["Distance"] = state
        end
    })
    Folder_Visuals:AddToggle({
        text = "Tracers",
        state = Settings.Saved["Tracers"] or false,
        callback = function(state)
            Settings.Saved["Tracers"] = state
        end
    })
end
FEScripts()
UniversalVisuals()
local Folder_Settings = Tab_Universal:AddFolder('Whitelist')
Folder_Settings:AddBox({
    text = "Add Player",
    callback = function(target)
        table.remove(Settings.Saved.Whitelist, target)
    end
})
Folder_Settings:AddBox({
    text = "Remove Player",
    callback = function(target)
        table.insert(Settings.Saved.Whitelist, target)
    end
})
local Folder_Settings = Tab_Universal:AddFolder('Settings')
Folder_Settings:AddToggle({
    text = "Skip Loading",
    state = Settings.Saved["Skip Loading"] or false,
    callback = function(state)
        Settings.Saved["Skip Loading"] = state
    end
})
Folder_Settings:AddButton({
    text = "Save",
    callback = Settings.Save
})

if game.PlaceId == 142823291 then -- Murder Mystery 2
    local GetData = function()
        return ReplicatedStorage.GetPlayerData:InvokeServer()
    end
    local GetRoles = function()
        local Data = GetData()
        local Sheriff, Murderer, Hero
        for i,v in next, Data do
            if v.Role == "Murderer" then
                Murderer = v
            end
            if v.Role == "Sheriff" then
                Sheriff = v
            end
            if v.Role == "Hero" then
                Hero = v
            end
        end
    end
    
    local Murderer, Sheriff, Hero = GetRoles()
    
end

UI:Init()
