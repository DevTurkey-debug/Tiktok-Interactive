local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local HOST_USERNAME = "User"
local ANIMATION_ID = "rbxassetid://507771019"
local BRIDGE_URL = "http://127.0.0.1:8787/next"

local PLAYERS_PER_ROW = 5
local SPACING_X = 6
local SPACING_Z = 7
local START_POSITION = Vector3.new(0,5,0)
local DROP_HEIGHT = 18
local POLL_RATE = 0.35

local DANCE_FOLDER = workspace:FindFirstChild("DancePlayers") or Instance.new("Folder")
DANCE_FOLDER.Name = "DancePlayers"
DANCE_FOLDER.Parent = workspace

local cameraRemote = game.ReplicatedStorage:FindFirstChild("CameraTargetEvent") or Instance.new("RemoteEvent")
cameraRemote.Name = "CameraTargetEvent"
cameraRemote.Parent = game.ReplicatedStorage

local spawnedUsers = {}
local animationTracks = {}
local masterTrack = nil

local function hideCharacter(char)
	task.wait(0.5)

	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			v.CanCollide = false
			v.CastShadow = false
		end
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(hideCharacter)
end)

local function face(position)
	return CFrame.new(position) * CFrame.Angles(0, math.rad(180), 0)
end

local function getGiftTitle(giftType)
	if giftType == "rose" then
		return "ROSE GIFTER"
	elseif giftType == "galaxy" then
		return "GALAXY GIFTER"
	elseif giftType == "lion" then
		return "LION GIFTER"
	elseif giftType == "universe" then
		return "UNIVERSE GIFTER"
	else
		return "GIFTER"
	end
end

local function addNameTag(model, username, isGifter, giftType, gifterName)
	local head = model:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.new(0,160,0,55)
	billboard.StudsOffset = Vector3.new(0,2.6,0)
	billboard.MaxDistance = 55
	billboard.AlwaysOnTop = false
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.35
	label.Parent = billboard

	if isGifter then
		label.Text =
			getGiftTitle(giftType)
			.. "\n"
			.. tostring(gifterName or "Unknown")
			.. "\n"
			.. username

		label.TextColor3 = Color3.fromRGB(255,215,0)
	else
		label.Text = username
		label.TextColor3 = Color3.new(1,1,1)
	end
end

local function createCharacter(username, isGifter, giftType, gifterName)
	if not username then return end

	if spawnedUsers[string.lower(username)] then
		return
	end

	local success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(username)
	end)

	if not success then
		return
	end

	local success2, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)

	if not success2 then
		return
	end

	local model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	model.Name = username

	local count = #DANCE_FOLDER:GetChildren()
	local row = math.floor(count / PLAYERS_PER_ROW)
	local column = count % PLAYERS_PER_ROW

	local finalPosition = START_POSITION + Vector3.new(column * SPACING_X,0,row * SPACING_Z)
	local spawnPosition = finalPosition + Vector3.new(0,DROP_HEIGHT,0)

	model:PivotTo(face(spawnPosition))
	model.Parent = DANCE_FOLDER

	addNameTag(model, username, isGifter, giftType, gifterName)

	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.AutoRotate = false

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end

		local anim = Instance.new("Animation")
		anim.AnimationId = ANIMATION_ID

		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action
		track:Play()

		if masterTrack then
			track.TimePosition = masterTrack.TimePosition
		else
			masterTrack = track
		end

		animationTracks[model] = track
	end

	spawnedUsers[string.lower(username)] = true

	cameraRemote:FireAllClients(model)

	print(username .. " spawned")
end

task.delay(2,function()
	createCharacter(HOST_USERNAME, false, nil, nil)
end)

task.spawn(function()
	while true do
		task.wait(POLL_RATE)

		local success, response = pcall(function()
			return HttpService:GetAsync(BRIDGE_URL)
		end)

		if success and response ~= "" then
			local ok, data = pcall(function()
				return HttpService:JSONDecode(response)
			end)

			if ok and data.username then
				createCharacter(
					data.username,
					data.gifter == true,
					data.giftType,
					data.gifterName
				)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(1.5)

		if masterTrack then
			for model,track in pairs(animationTracks) do
				if model.Parent and track then
					local diff = math.abs(track.TimePosition - masterTrack.TimePosition)

					if diff > 0.12 then
						track.TimePosition = masterTrack.TimePosition
					end
				end
			end
		end
	end
end)
