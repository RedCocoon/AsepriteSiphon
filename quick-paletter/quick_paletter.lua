local ws

local target_url
local received_image
local os_slash = app.fs.pathSeparator
local server_started = false

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   str = str:gsub("\\","/")
   return str:match("(.*/)") or "."
end

local path = script_path()

function init(plugin)
  
  plugin:newCommand{
    id="ApiCheck",
    title="Check API Version",
    group="file_scripts",
    onclick=function()
      print(app.version)
      print(app.apiVersion)
      print(WebSocket == nil)
    end
  }
  plugin:newCommand{
    id="FilePaletter",
    title="New Palette from File",
    group="palette_generation",
    onclick=function()
      local data =
        Dialog():label{ id="label", label="Warning!", text="The current palette will be overriden!" }
                :newrow()
                :file{ id="open_file", label="File:", open=true, filetypes={ "png", "jpg", "jpeg" } }
                :button{ id="confirm", text="Confirm" }
                :button{ id="cancel", text="Cancel" }
                :show().data
      if not (data.confirm) then
        return nil
      end
      generate_palette(data.open_file)
    end
  }
  plugin:newCommand{
    id="UrlPaletter",
    title="New Palette from URL",
    group="palette_generation",
    onclick=function()
      local data =
        Dialog():label{ id="label", label="Warning!", text="The current palette will be overriden!" }
                :newrow()
                :entry{ id="url", label="URL:", text="https://lospec.com/palette-list/super-nes-maker-1x.png" }
                :button{ id="confirm", text="Confirm" }
                :button{ id="cancel", text="Cancel" }
                :show().data
      if not (data.confirm) then
        return nil
      end
      if not server_started then
      	-- WINDOWS
      	if os_slash == "\\" then
      		 print("windows")
		 os.execute("start /b /min "..path.."WebSocket.py")
	-- LINUX/MAC
	else
		os.execute("python "..path.."WebSocket.py &")	
	end
      	server_started = true
      end
      get_image(data.url)
    end
  }
  --plugin:newCommand{
  --  id="Shutdown",
  --  title="Shutdown WebSocket",
  --  group="sprite_properties",
  --  onclick=function()
  --    os.execute("start /b "..path.."WebSocketShutdowner.py")
  --  end
  --}
end

function exit(plugin)
  ws:sendText("shutdown")
  ws:close()
end

function set_palette(palette)
  local sprite = app.activeSprite
  sprite:setPalette(palette)
end

function new_sprite(filename)
  sprite = app.open(filename)
  app.activeSprite = sprite
end

function generate_palette(filename)
  --filename = filename:gsub("/","\\")
  if app.activeSprite == nil then
      new_sprite(filename)
  else
    set_palette(Palette{fromFile=filename})
  end
end

function get_image(get_url)
  ws = WebSocket{
      onreceive = ws_receive,
      url = "ws://localhost:8080",
      deflate = false
  }
  target_url = get_url
  ws:connect()
end

function ws_receive(mt, data)
  if mt == WebSocketMessageType.OPEN then
    if target_url == nil then
      return
    end
    ws:sendText(target_url)
    target_url = nil
  elseif mt == WebSocketMessageType.BINARY then
    received_image = temp_file(data)
    generate_palette(path.."image.png")

    -- TODO: Uncomment this when Aseprite support io.tmpname()
    -- os.remove(received_image)
  elseif mt == WebSocketMessageType.CLOSE then
  end
end

function temp_file(data)
  -- TODO: Uncomment this when Aseprite support io.tmpname()
  -- local filename = io.tmpname()
  local filename = path.."image.png"
  local file,err = io.open(filename,"wb")
  if file then
      file:write(data)
      file:close()
  else
      print("error:", err) -- not so hard?
  end
  return filename
end
