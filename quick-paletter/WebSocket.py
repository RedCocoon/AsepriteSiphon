import asyncio
import websockets
from PIL import Image
import requests
from io import BytesIO
import base64

async def server(websocket, path):
    # Get received data from websocket
    data = await websocket.recv()
    if data == "shutdown":
        websocket.close()
        return
    response = requests.get(str(data))
    buffered = BytesIO()
    img = Image.open(BytesIO(response.content))
    img.save(buffered, format="PNG")

    img_str = buffered.getvalue()
    # Send response back to client to acknowledge receiving message
    await websocket.send(img_str)

# Create websocket server
start_server = websockets.serve(server, "localhost", 8080)

# Start and run websocket server forever
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
