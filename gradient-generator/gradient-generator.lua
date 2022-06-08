local pluginLocal

function init(plugin)
  pluginLocal = plugin

  plugin:newCommand{
    id="newGradient",
    title="New Gradient...",
    group="palette_generation",
    onclick=function()
      local dlg = Dialog()
      dlg:color{ id="color", label="Enter color:", color=app.fgColor}
      dlg:newrow()
      dlg:slider{ id="steps", label="Steps:", min=3, max=256, value=9}
      dlg:slider{ id="angle", label="Angle:", min=-360, max=360, value=90}
      dlg:newrow()
      dlg:check{ id="replace", label="Replace current palette?", selected=false }
      dlg:newrow()
      dlg:button{ id="confirm", text="Confirm" }
      dlg:button{ id="cancel", text="Cancel" }
      dlg:show()
      local data = dlg.data
      if not data.confirm then
        return
      end
      local steps = data.steps
      local angle = data.angle
      local color = Color(data.color)
      local lightness = color.lightness
      local darker = math.floor(steps * (lightness))
      local lighter = steps - darker - 1
      local colors = {}
      for x = darker - 1, 0, -1 do
        local new_color = Color{ r=color.red, g=color.green, b=color.blue, a=color.alpha }
        new_color.lightness = lerp(lightness, 0, (x + 1) / (darker + 1))
        new_color.hue = toPositiveAngle(new_color.hue + lerp(0, -angle / 2, (x + 1) / (darker + 1)))
        table.insert(colors, new_color)
      end

      table.insert(colors, color)

      for x = lighter - 1, 0, -1 do
        local new_color = Color{ r=color.red, g=color.green, b=color.blue, a=color.alpha }
        new_color.lightness = lerp(1, lightness, (x + 1) / (lighter + 1))
        new_color.hue = toPositiveAngle(new_color.hue + lerp(angle / 2, 0, (x + 1) / (lighter + 1)))
        table.insert(colors, new_color)
      end

      local palette = Palette()
      if data.replace then
        palette:resize(#colors)
        for x = 0, #colors-1, 1 do
          palette:setColor(x, colors[x+1])
        end
      else
        local sprite = app.activeSprite
        local original_size = #sprite.palettes[1]
        palette:resize(original_size+#colors)
        for x = 0, original_size-1, 1 do
          palette:setColor(x, sprite.palettes[1]:getColor(x))
        end
        for x = 0, #colors-1, 1 do
          palette:setColor(original_size+x, colors[x+1])
        end
      end
      set_palette(palette)
    end
  }
end

function lerp(a, b, c)
  return (a * (1 - c) + b * c)
end

function toPositiveAngle(angle)
  angle = ((angle % 360) + 360) % 360
  if (angle < 0) then angle = angle + 360 end
  return angle;
end

function set_palette(palette)
  local sprite = app.activeSprite
  sprite:setPalette(palette)
end
