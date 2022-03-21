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
  -- plugin:newCommand{
  --   id="CleanSpritePaletter",
  --   title="New Palette from Visible Layers",
  --   group="palette_generation",
  --   onclick=function()
  --     local image = app.activeImage
  --
  --   end
  -- }
  plugin:newCommand{
    id="FilesPaletter",
    title="New Palette from Files",
    group="palette_generation",
    onclick=function()
      local data =
        Dialog():label{ id="label", label="Warning!", text="The current palette will be overriden!" }
                :newrow()
                :file{ id="open_file_1", label="File 1:", open=true, filetypes={ "png", "jpg", "jpeg" } }
                :file{ id="open_file_2", label="File 2:", open=true, filetypes={ "png", "jpg", "jpeg" } }
                :button{ id="confirm", text="Confirm" }
                :button{ id="cancel", text="Cancel" }
                :show().data
      if not (data.confirm) then
        return nil
      end
      local palette_1 = generate_palette(data.open_file_1)
      local palette_2 = generate_palette(data.open_file_2)

      local palette_1_size = #palette_1
      palette_1:resize(#palette_1+#palette_2)

      local empty_color_count = 0

      for i = 0, #palette_2-1, 1 do
        local new_color = palette_2:getColor(i)
        if not (new_color.alpha == 0) then
          palette_1:setColor(palette_1_size+i-empty_color_count, new_color)
        else
          palette_1:resize(#palette_1-1)
          empty_color_count = empty_color_count + 1
        end
      end
      set_palette(palette_1)
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
    return Palette{fromFile=filename}
  end
end

function get_image(get_url)
  ws = WebSocket{
      onreceive = ws_receive,
      url = "ws://localhost:8080",
      deflate = false
  }
  -- If the url contains lospec.com, but does not have .png ending, add to it.
  if string.match(get_url, "lospec.com") and not string.match(get_url, ".png$") then
      get_url = get_url.."-1x.png"
  end
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
  elseif mt == WebSocketMessageType.TEXT then
    if data == "image_received" then
      set_palette(generate_palette(path.."image.png"))
    end
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
