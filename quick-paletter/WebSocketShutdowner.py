#!/usr/bin/env python

import asyncio
from websockets import connect

async def hello(uri):
    async with connect(uri) as websocket:
        await websocket.send("shutdown")
        await websocket.recv()

asyncio.run(hello("ws://localhost:8080"))
