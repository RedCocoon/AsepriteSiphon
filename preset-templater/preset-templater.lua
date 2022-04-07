local pluginLocal

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   str = str:gsub("\\","/")
   return str:match("(.*/)") or "."
end

local path = script_path()

function init(plugin)
  pluginLocal = plugin
  if plugin.preferences.templates == nil then
    plugin.preferences.templates = {}
  end

  plugin:newCommand{
    id="NewFromTemplate",
    title="New Sprite From Template...",
    group="file_new",
    onclick=function()
      if not does_any_template_exists() then
        return nil
      end
      local data =
      Dialog("Select a Template"):newrow()
              :combobox{ id="name", label="Select a Template:", options= plugin.preferences.templates }
              :button{ id="confirm", text="Confirm", focus=true }
              :button{ id="cancel", text="Cancel" }
              :show().data
      if not data.confirm then
        return nil
      end
      load_template(path.."templates/"..data.name..".aseprite")
    end
  }

  -- plugin:newCommand{
  --   id="ClearTemplate",
  --   title="Clear all Templates...",
  --   group="file_new",
  --   onclick=function()
  --     plugin.preferences.templates = {}
  --   end
  -- }

  plugin:newCommand{
    id="SaveAsTemplate",
    title="Save As Template...",
    group="file_save",
    onclick=function()
      local sprite = app.activeSprite
      if sprite then
        name = show_enter_name_dlg("Save Current Sprite As Template")
        save_template(name)
      else
        simple_info_dlg("Error!", "A sprite must be opened for this operation!")
      end
    end
  }

  plugin:newCommand{
    id="ManageTemplates",
    title="Manage Templates",
    group="file_scripts",
    onclick=function()
      local templates = pluginLocal.preferences.templates
      if not does_any_template_exists() then
        return nil
      end
      local data = show_manage_dlg(0).data
      local index = has_value(templates, data.name)
      -- Navigation does not close the menu
      while true do
        if ((data.up) and (1 < index)) then
          swap_element(pluginLocal.preferences.templates, index, index-1)
          index = index-1
        elseif ((data.down) and (#templates >= index+1)) then
          swap_element(pluginLocal.preferences.templates, index, index+1)
          index = index+1
        elseif (data.rename) then
          --name = show_enter_name_dlg("Save Current Sprite As Template")
          simple_info_dlg("Uhh... This is awkward...", "As Aseprite currently does not support renaming files, this option currently do nothing.")
        elseif (data.delete) then
           if simple_info_dlg("Warning!", "Are you sure?") then
             table.remove(pluginLocal.preferences.templates, index)
             if (index > #pluginLocal.preferences.templates) then
               index = #pluginLocal.preferences.templates
             end
             four_label_info_dlg("Uhh... This is awkward...",
             "As Aseprite currently does not support removing files,",
             "You need to manually remove the file:",
             path.."templates/"..data.name..".aseprite",
             "The file will no longer show up on the list even if you don't delete, though." )
           end
        else
          break
        end
        if not does_any_template_exists() then
          return nil
        end
        data = show_manage_dlg(index).data
      end
    end
  }
end

function swap_element(tab, from, to)
  local temp = tab[from]
  tab[from] = tab[to]
  tab[to] = temp
end

function does_any_template_exists()
  if #pluginLocal.preferences.templates < 1 then
    simple_info_dlg("Error!", "No Templates Available!")
    return false
  end
  return true
end

function save_template(name)
  local sprite = app.activeSprite
  local templates = pluginLocal.preferences.templates
  local index = has_value(templates, name)
  if index then
    local data =
      Dialog("Warning!"):label{ id="label", label="A template already exists with this name!"}
            :newrow()
            :label{ id="label2", label="Do you want to override the existing template?"}
            :button{ id="confirm", text="Confirm" }
            :button{ id="cancel", text="Cancel" }
            :show().data
    if not data.confirm then
      return nil
    end
    sprite:saveCopyAs(path.."/templates/"..name..".aseprite")
    pluginLocal.preferences.templates[index] = name
    return nil
  end
  sprite:saveCopyAs(path.."/templates/"..name..".aseprite")
  table.insert(pluginLocal.preferences.templates, name)
end

function load_template(name)
  local original_sprite = Sprite{ fromFile=name }
  Sprite(original_sprite)
  original_sprite:close()

end

function simple_info_dlg(title, label_text)
  local data =
    Dialog(title):label{ id="label", label=label_text}
          :newrow()
          :button{ id="confirm", text="Confirm" }
          :show().data
  return data.confirm
end

function four_label_info_dlg(title, label1, label2, label3, label4)
  local remove_file_data = Dialog(title):label{ id="label", label=label1}
      :newrow()
      :label{ id="label2", label=label2}
      :newrow()
      :label{ id="label3", label=label3}
      :newrow()
      :label{ id="label3", label=label4}
      :button{ id="confirm", text="Confirm" }
      :show().data
end

function show_enter_name_dlg(title)
  local data =
  Dialog(title):newrow()
          :entry{ id="name", label="Enter a Name:" } -- text=sprite.filename:gsub("\\","/"):match("/*%.") }
          :button{ id="confirm", text="Confirm", focus=true}
          :button{ id="cancel", text="Cancel" }
          :show().data
  if not (data.confirm) then
    return nil
  end
  if not data.name or data.name == "" then
    simple_info_dlg("Error!", "No template name entered! Please retry with a name!")
    return nil
  end
  return data.name
end

function show_manage_dlg(index)
  local templates = pluginLocal.preferences.templates
  return Dialog("Manage Templates"):newrow()
          :combobox{ id="name", label="Select a Template:", option=templates[index] ,options=templates }
          :newrow()
          :button{ id="up", text="Move Up" }
          :button{ id="down", text="Move Down" }
          :newrow()
          :button{ id="delete", text="Delete" }
          :show()

end

function has_value(tab, val)
    for key,value in ipairs(tab) do
        if value == val then
            return key
        end
    end
    return false
end
