#!/usr/bin/env python3
import asyncio
import websockets
from PIL import Image
import requests
from io import BytesIO
import base64

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
        response = requests.get(str(data))
        ## create a buffer to store the image
        buffered = BytesIO()
        ## open the image in response
        img = Image.open(BytesIO(response.content))
        ## save the image to the created buffer, using PNG to avoid quality lost
        img.save(buffered, format="PNG")
        
        ## Get the buffer image's byte values
        img_str = buffered.getvalue()
        # Send response back to client to convert back to an image
        await websocket.send(img_str)

# Create websocket server
start_server = websockets.serve(server, "localhost", 8080)

# Start and run websocket server forever
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
