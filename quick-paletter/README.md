## OwO What's this?
Quick Paletter is an Aseprite extension that allows you to generate a palette by selecting a file or entering an URL. 

## IMPORTANT!!!
When you first install the extension and used the "Palette from URL" function, allow the script full access on the security pop up. Otherwise, the app will crash. Also before you use that function, make sure to save everything, as there seems to be rare crashes? Idk, if someone else can help me debug and fix my code it would be great.


## Pre-requisites
- Python 3.9
- And install the following dependencies using command line
- pip install asyncio
- pip install websockets
- pip install Pillow
- pip install requests


## User Guide
- A new option under File for "Check API Version"
- Click the first option "Check API Version" and make sure the last output is false
- Two new palette generation options under the palette drop-down menu
- New Palette from File generate new palette from the selected files
- New Palette from URL generate new palette from the image linked
- Please do not put non-image url in there, I don't even know what will happen owo
- Run WebSocketShutdowner.py incase for whatever reason the websocket is still open after closing Aseprite

## Known problems
- "Websocket Error" Popup: as far as I can tell, it is completely fine.
- If the plugin doesn't work, try changing the port where the code says "localhost:[PORT]"
