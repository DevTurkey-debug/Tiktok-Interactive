# Tiktok-Interactive
DIRECT SETUP
===================================


-----------------------------------
INSTALL PYTHON PACKAGES
-----------------------------------

Open Command Prompt in this folder:

python -m pip install TikTokLive aiohttp

-----------------------------------
SET YOUR TIKTOK USERNAME
-----------------------------------

Open:
tiktok.py

Change:

TIKTOK_USERNAME = "YOUR_TIKTOK_USERNAME"

to your LIVE username.

-----------------------------------
RUN THE BRIDGE
-----------------------------------

python tiktok_bridge.py

-----------------------------------
ROBLOX STUDIO SETUP
-----------------------------------

1. Open Roblox Studio

2. ENABLE HTTP REQUESTS

Home
→ Game Settings
→ Security
→ Allow HTTP Requests = ON

3. Put:

DanceSystem.lua

inside:

ServerScriptService

4. Put:

SpectatorCamera.lua

inside:

StarterPlayer
→ StarterPlayerScripts

-----------------------------------
ANIMATION
-----------------------------------

Inside DanceSystem.lua

replace:

local ANIMATION_ID = "rbxassetid://"

with your own emote animation.

-----------------------------------
TESTING
-----------------------------------

Press Play in Roblox Studio.

Go LIVE on TikTok.

Type in chat:

builderman

OR:

!join builderman


-----------------------------------
Cookies
-----------------------------------
Open Microsoft Edge

Download the Extention Called Cookie Editor (https://microsoftedge.microsoft.com/addons/detail/cookieeditor/neaplmfkghagebokkhpjpoebhdledlfi)

Go to tiktok and log in, then use the cookie editor and click export as json and then add the cookies to cookies.json

----------------------------------
IMPORTANT: THIS SYSTEM ONLY WORKS IN ROBLOX STUDIO
