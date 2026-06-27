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
camera.CameraSubject = nil

-------------------------------------------------
-- TARGET
-------------------------------------------------

local currentTarget = nil

local token = 0

remote.OnClientEvent:Connect(function(model)

	token += 1

	local current = token

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local connection

	connection = humanoid.StateChanged:Connect(function(old,new)

		if current ~= token then

			connection:Disconnect()

			return

		end

		if new == Enum.HumanoidStateType.Landed
		or new == Enum.HumanoidStateType.Running then

			currentTarget = model

			connection:Disconnect()

		end

	end)

	task.delay(3,function()

		if current == token then

			currentTarget = model

		end

		if connection then
			connection:Disconnect()
		end

	end)

end)

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

	local desired =

		CFrame.new(
			pos + Vector3.new(0,8,14),
			pos + Vector3.new(0,3,0)
		)

	camera.CFrame =
		camera.CFrame:Lerp(desired,0.08)

end)
