local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local remote =
	game.ReplicatedStorage:WaitForChild(
		"CameraTargetEvent"
	)

-------------------------------------------------
-- HIDE PLAYER
-------------------------------------------------

local character =
	player.Character or player.CharacterAdded:Wait()

local humanoid =
	character:WaitForChild("Humanoid")

humanoid.WalkSpeed = 0
humanoid.JumpPower = 0
humanoid.AutoRotate = false

for _,v in pairs(character:GetDescendants()) do

	if v:IsA("BasePart") then

		v.Transparency = 1
		v.CanCollide = false
		v.CastShadow = false

	end

end

-------------------------------------------------
-- CAMERA
-------------------------------------------------

camera.CameraType = Enum.CameraType.Scriptable

-------------------------------------------------
-- TARGETS
-------------------------------------------------

local newestTarget = nil
local currentTarget = nil

-------------------------------------------------
-- REMOTE
-------------------------------------------------

remote.OnClientEvent:Connect(function(model)

	newestTarget = model
	currentTarget = model

end)

-------------------------------------------------
-- SPECIAL FOCUS FUNCTION
-------------------------------------------------

local function FocusPlayer(username)

	local folder =
		workspace:FindFirstChild(
			"DancePlayers"
		)

	if not folder then
		return
	end

	local model =
		folder:FindFirstChild(username)

	if not model then
		return
	end

	currentTarget = model

	task.delay(5,function()

		currentTarget = newestTarget

	end)

end

-------------------------------------------------
-- GLOBAL COMMAND
-------------------------------------------------

_G.FocusPlayer = FocusPlayer

-------------------------------------------------
-- CAMERA LOOP
-------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not currentTarget then
		return
	end

	local hrp =
		currentTarget:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hrp then
		return
	end

	local pos = hrp.Position

	local sideMovement =
		math.sin(tick() * 0.5) * 5

	local desired =

		CFrame.new(
			pos + Vector3.new(sideMovement,8,14),
			pos + Vector3.new(0,3,0)
		)

	camera.CFrame =
		camera.CFrame:Lerp(desired,0.05)

end)
