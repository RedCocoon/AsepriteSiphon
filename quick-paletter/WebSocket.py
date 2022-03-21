#!/usr/bin/env python3
import asyncio
import websockets
from PIL import Image
import requests
from io import BytesIO
import base64
import os

current_file_path = os.path.dirname(__file__).replace("\\","/") + "/"

async def server(websocket, path):
    # Get received data from websocket
    data = await websocket.recv()
    print(data)
    ## shutdown the server if the message is shutdown
    if data == "shutdown":
        ## close the websocket
        websocket.close()
        ## stop the async loop
        asyncio.get_event_loop().call_soon_threadsafe(asyncio.get_event_loop().stop)
    ## else, proccess the url and spit out the image back to lua
    else:
    	## get the data
        response = requests.get(str(data)).content
        ## create a buffer to store the image
        buffered = BytesIO()
        ## open the image in response
        img = Image.open(BytesIO(response))
        ## save the image to the created buffer, using PNG to avoid quality lost
        img.save(current_file_path+"image.png", format="PNG")
        # Send response back to client to convert back to an image
        await websocket.send("image_received")

# Create websocket server
start_server = websockets.serve(server, "localhost", 8080)

# Start and run websocket server forever
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
