import asyncio
import re
import time
from collections import deque

from aiohttp import web
from TikTokLive import TikTokLiveClient
from TikTokLive.events import CommentEvent, GiftEvent

live_link = input("Paste TikTok LIVE link: ").strip()

match = re.search(r"@([A-Za-z0-9_.]+)", live_link)

if not match:
    print("Invalid TikTok LIVE link.")
    input("Press ENTER to close...")
    quit()

TIKTOK_USERNAME = match.group(1)

print("")
print(f"Using TikTok username: {TIKTOK_USERNAME}")
print("")

HOST = "127.0.0.1"
PORT = 8787

GIFT_WINDOW_SECONDS = 60

queue = deque()
already_added = set()
recent_gifters = {}

client = TikTokLiveClient(unique_id=TIKTOK_USERNAME)

def clean_username(text):
    text = text.strip()
    text = text.replace("@", "")
    text = re.sub(r"[^A-Za-z0-9_]", "", text)

    if len(text) < 3 or len(text) > 20:
        return None

    return text

def get_username(comment):
    parts = comment.split()

    if len(parts) >= 2 and parts[0].lower() in ["!join", "!spawn", "join", "spawn"]:
        return clean_username(parts[1])

    if len(parts) == 1:
        return clean_username(parts[0])

    return None

def get_gift_type(gift_name):
    gift_name = gift_name.lower()

    if "rose" in gift_name:
        return "rose"
    elif "galaxy" in gift_name:
        return "galaxy"
    elif "lion" in gift_name:
        return "lion"
    elif "universe" in gift_name:
        return "universe"

    return "gift"

def add_user(roblox_username, gifter=False, gifter_name=None, gift_type=None):
    roblox_username = clean_username(roblox_username)

    if not roblox_username:
        return

    lower = roblox_username.lower()

    if lower in already_added:
        return

    already_added.add(lower)

    queue.append({
        "username": roblox_username,
        "gifter": gifter,
        "gifterName": gifter_name,
        "giftType": gift_type
    })

    if gifter:
        print(f"Queued GIFTER avatar: {roblox_username} | Gifter: {gifter_name} | Gift: {gift_type}")
    else:
        print(f"Queued avatar: {roblox_username}")

@client.on(GiftEvent)
async def on_gift(event):
    try:
        tiktok_name = event.user.unique_id
        gift_name = event.gift.name
        gift_type = get_gift_type(gift_name)

        recent_gifters[tiktok_name.lower()] = {
            "gifterName": tiktok_name,
            "giftType": gift_type,
            "time": time.time()
        }

        print(f"Gift received from {tiktok_name}: {gift_name}")
        print(f"{tiktok_name} has {GIFT_WINDOW_SECONDS} seconds to type a Roblox username.")

    except Exception as e:
        print("Gift Error:")
        print(e)

@client.on(CommentEvent)
async def on_comment(event):
    try:
        comment = event.comment
        tiktok_name = event.user.unique_id

        print(f"{tiktok_name}: {comment}")

        roblox_username = get_username(comment)

        if not roblox_username:
            return

        key = tiktok_name.lower()
        gifter_data = recent_gifters.get(key)

        if gifter_data and time.time() - gifter_data["time"] <= GIFT_WINDOW_SECONDS:
            add_user(
                roblox_username,
                True,
                gifter_data["gifterName"],
                gifter_data["giftType"]
            )
        else:
            add_user(
                roblox_username,
                False,
                None,
                None
            )

    except Exception as e:
        print("Comment Error:")
        print(e)

async def next_user(request):
    if queue:
        return web.json_response(queue.popleft())

    return web.json_response({})

async def health(request):
    return web.json_response({
        "ok": True,
        "queued": len(queue),
        "already_added": len(already_added),
        "recent_gifters": len(recent_gifters)
    })

async def start_server():
    app = web.Application()
    app.router.add_get("/next", next_user)
    app.router.add_get("/health", health)

    runner = web.AppRunner(app)
    await runner.setup()

    site = web.TCPSite(runner, HOST, PORT)
    await site.start()

    print("Roblox bridge running.")
    print(f"http://{HOST}:{PORT}")
    print("")

async def main():
    await start_server()

    print("Connecting to TikTok LIVE...")
    print("")

    try:
        await client.connect()

    except Exception as e:
        print("")
        print("TikTok Connection Error:")
        print(e)
        print("")
        input("Press ENTER to close...")

asyncio.run(main())