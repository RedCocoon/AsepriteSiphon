local ws

local target_url
local received_image

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local path = script_path()

function init(plugin)
  plugin:newCommand{
    id="ApiCheck",
    title="Check API Version",
    group="sprite_properties",
    onclick=function()
      print(app.version)
      print(app.apiVersion)
      print(WebSocket == nil)
    end
  }
  plugin:newCommand{
    id="FilePaletter",
    title="New Palette from File...",
    group="sprite_properties",
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
    title="New Palette from URL...",
    group="sprite_properties",
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
      os.execute("python "..path.."WebSocket.py")
      get_image(data.url)
    end
  }
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
  if app.activeSprite == nil then
      new_sprite(filename)
  else
    set_palette(Palette{fromFile=filename})
  end
end

function get_image(get_url)
  ws = WebSocket{
      onreceive = ws_receive,
      url = "https://localhost:8080",
      deflate = false
  }
  target_url = get_url
  ws:connect()
end

function ws_receive(mt, data)
  if mt == WebSocketMessageType.OPEN then
    ws:sendText(target_url)
  elseif mt == WebSocketMessageType.BINARY then
    received_image = temp_file(data)
    generate_palette(received_image)
    ws:sendText("shutdown")
    ws:close()

    -- TODO: Uncomment this when Aseprite support io.tmpname()
    -- os.remove(received_image)
  elseif mt == WebSocketMessageType.CLOSE then
  end
end

function temp_file(data)
  -- TODO: Uncomment this when Aseprite support io.tmpname()
  -- local filename = io.tmpname()
  local file,err = io.open(path.."image.png","w")
  if file then
      file:write(data)
      file:close()
  else
      print("error:", err) -- not so hard?
  end
  -- TODO: Uncomment this when Aseprite support io.tmpname()
  -- return filename
  return path.."image.png"
end
