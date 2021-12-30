--[[
        © Asterion Project 2021.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterionproject.ru
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--


-- Создаем конвар с настройкой прорисовки
ImageTool.dist = CreateClientConVar("imagetool_dist", 1000, true, nil, "Change distance of drawing pictures")

-- Менюшка с настройкой
hook.Add( "PopulateToolMenu", "ImageTool.Menu", function()
    spawnmenu.AddToolMenuOption("Options", "Image Tool", "imagetoolsettings", "Image Tool Settings", nil, nil, function(CPanel)
        CPanel:ClearControls()

        CPanel:AddControl("Header",{
            Description = "In this menu you can change the settings for the ImageTool."
        })

        CPanel:AddControl("Slider", {
            Label = "Draw distance:",
            Command = "imagetool_dist",
            Min = 0,
            Max = 10000
        })

        local SettingsReset = vgui.Create("DButton")
        SettingsReset:SetText("Return to default settings")
        SettingsReset.DoClick = function()
            local l = "imagetool_"

            RunConsoleCommand(l .. "dist", ImageTool.dist:GetDefault())
        end
        CPanel:AddPanel(SettingsReset)
    end)
end)

-- Отображение картинок
hook.Add("PostDrawTranslucentRenderables", "ImageTool.PostDrawTranslucentRenderables", function()
    ImageTool:DrawImageTool() -- Тул-Ган отрисовка
    ImageTool:DrawAllImages() -- Отрисовка всех картинки в мире
end)