local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

local HOST_USERNAME = "brozplay3"

local ANIMATION_ID = "rbxassetid://507771019"

local BRIDGE_URL = "http://127.0.0.1:8787/next"

local PLAYERS_PER_ROW = 5

local SPACING_X = 6
local SPACING_Z = 7

local START_POSITION = Vector3.new(0,5,0)

local DROP_HEIGHT = 18

local POLL_RATE = 0.35

local CAMERA_CYCLE_SECONDS = 6

-------------------------------------------------
-- FOLDER
-------------------------------------------------

local DANCE_FOLDER =
	workspace:FindFirstChild("DancePlayers")

if not DANCE_FOLDER then

	DANCE_FOLDER = Instance.new("Folder")
	DANCE_FOLDER.Name = "DancePlayers"
	DANCE_FOLDER.Parent = workspace

end

-------------------------------------------------
-- REMOTES
-------------------------------------------------

local cameraRemote =
	game.ReplicatedStorage:FindFirstChild(
		"CameraTargetEvent"
	)

if not cameraRemote then

	cameraRemote = Instance.new("RemoteEvent")

	cameraRemote.Name = "CameraTargetEvent"

	cameraRemote.Parent = game.ReplicatedStorage

end

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local spawnedUsers = {}

local animationTracks = {}

local masterTrack = nil

local cameraIndex = 0

-------------------------------------------------
-- HIDE PLAYERS
-------------------------------------------------

local function hideCharacter(char)

	task.wait(0.5)

	for _,v in pairs(char:GetDescendants()) do

		if v:IsA("BasePart") then

			v.Transparency = 1
			v.CanCollide = false
			v.CastShadow = false

		end

	end

	local humanoid =
		char:FindFirstChildOfClass("Humanoid")

	if humanoid then

		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false

	end

end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(hideCharacter)

end)

-------------------------------------------------
-- FACE CAMERA
-------------------------------------------------

local function face(position)

	return
		CFrame.new(position)
		* CFrame.Angles(0, math.rad(180), 0)

end

-------------------------------------------------
-- CREATE CHARACTER
-------------------------------------------------

local function createCharacter(username)

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

	local model =
		Players:CreateHumanoidModelFromDescription(
			desc,
			Enum.HumanoidRigType.R15
		)

	model.Name = username

	local count = #DANCE_FOLDER:GetChildren()

	local row = math.floor(count / PLAYERS_PER_ROW)

	local column = count % PLAYERS_PER_ROW

	local x = column * SPACING_X
	local z = row * SPACING_Z

	local finalPosition =
		START_POSITION + Vector3.new(x,0,z)

	local spawnPosition =
		finalPosition + Vector3.new(0,DROP_HEIGHT,0)

	model:PivotTo(face(spawnPosition))

	model.Parent = DANCE_FOLDER

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	local hrp =
		model:FindFirstChild("HumanoidRootPart")

	if humanoid then

		humanoid.DisplayDistanceType =
			Enum.HumanoidDisplayDistanceType.None

		humanoid.AutoRotate = false

		local animator =
			humanoid:FindFirstChildOfClass("Animator")

		if not animator then

			animator = Instance.new("Animator")
			animator.Parent = humanoid

		end

		local anim = Instance.new("Animation")

		anim.AnimationId = ANIMATION_ID

		local track =
			animator:LoadAnimation(anim)

		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action

		track:Play()

		if masterTrack then

			track.TimePosition =
				masterTrack.TimePosition

		else

			masterTrack = track

		end

		animationTracks[model] = track

	end

	spawnedUsers[string.lower(username)] = true

	cameraRemote:FireAllClients(model)

	print(username .. " spawned")

end

-------------------------------------------------
-- HOST
-------------------------------------------------

task.delay(2,function()

	createCharacter(HOST_USERNAME)

end)

-------------------------------------------------
-- ROBLOX BRIDGE POLLING
-------------------------------------------------

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

				createCharacter(data.username)

			end

		end

	end

end)

-------------------------------------------------
-- AUTO CAMERA CYCLE
-------------------------------------------------

task.spawn(function()

	while true do

		task.wait(CAMERA_CYCLE_SECONDS)

		local chars = {}

		for _,v in pairs(DANCE_FOLDER:GetChildren()) do

			if v:IsA("Model") then

				table.insert(chars,v)

			end

		end

		if #chars > 0 then

			cameraIndex += 1

			if cameraIndex > #chars then
				cameraIndex = 1
			end

			cameraRemote:FireAllClients(
				chars[cameraIndex]
			)

		end

	end

end)

-------------------------------------------------
-- AUTO SYNC
-------------------------------------------------

task.spawn(function()

	while true do

		task.wait(1.5)

		if masterTrack then

			for model,track in pairs(animationTracks) do

				if model.Parent and track then

					local diff =
						math.abs(
							track.TimePosition
							-
							masterTrack.TimePosition
						)

					if diff > 0.12 then

						track.TimePosition =
							masterTrack.TimePosition

					end

				end

			end

		end

	end

end)
