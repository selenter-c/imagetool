--[[
        © AsterionStaff 2022.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--


-- Создаем конвар с настройкой прорисовки
ImageTool.dist = CreateClientConVar("imagetool_dist", 1000, true, nil, "Change distance of drawing pictures")

-- Менюшка с настройкой
hook.Add( "PopulateToolMenu", "ImageTool.Menu", function()
    local l = "imagetool_"

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
            RunConsoleCommand(l .. "dist", ImageTool.dist:GetDefault())
        end
        CPanel:AddPanel(SettingsReset)

        local HistoryReset = vgui.Create("DButton")
        HistoryReset:SetText("Clear the history")
        HistoryReset.DoClick = function()
            ImageTool:SaveHistory({})

            timer.Simple(0.5, function()
                RunConsoleCommand("spawnmenu_reload")
            end)

            LocalPlayer():ChatPrint(ImageTool.prefix .. " You have successfully cleared your history!")
        end
        CPanel:AddPanel(HistoryReset)

        local ImageReset = vgui.Create("DButton")
        ImageReset:SetText("Delete all pictures on the map")
        ImageReset.DoClick = function()
            RunConsoleCommand(l .. "delete_all")
        end
        CPanel:AddPanel(ImageReset)
    end)
end)

-- Получаем каждые 0.5 секунд все картинки возле игрока
local showImagesList = {}
local cache = {}
timer.Create("ImageTool:Update", 0.5, 0, function()
    local client = LocalPlayer()
    if !IsValid(client) then return end

    showImagesList = {}

    for id, array in pairs(ImageTool:GetImages()) do
        -- Удаляем картинки которые слишком далеко от игрока
        if client:GetPos():DistToSqr(array.position) >= ImageTool.dist:GetInt() * 15000 then
            cache[id] = nil
            continue
        end

        showImagesList[id] = array
    end
end)

-- Удаляем из кеша картинки которые не прогружены
timer.Create("ImageTool:Cleaner", 1, 0, function()
    for id in pairs(cache) do
        if !showImagesList[id] then
            cache[id] = nil
        end
    end
end)

local function caching(id, array)
    cache[id] = array
end

local function thread()
	local showImages

	while true do
		showImages = showImagesList

		if !next(showImages) then
			coroutine.yield()
		else
			for id, array in pairs(showImages) do
				coroutine.yield()

				caching(id, array)
			end
		end
	end
end

-- Кешируем по кадрово информацию о картинках
local co
hook.Add("Think", "ImageTool.Think", function()
    if !co or !coroutine.resume(co) then
		co = coroutine.create(thread)
		coroutine.resume(co)
	end
end)

-- Отображение картинок
hook.Add("PostDrawTranslucentRenderables", "ImageTool.PostDrawTranslucentRenderables", function()
    -- Отрисовка всех картинки в мире
    for k, v in pairs(cache) do
        ImageTool:Start3D2D(v)
    end

    ImageTool:DrawImageTool() -- Тул-Ган отрисовка
end)

surface.CreateFont( "ImageToolNSWF", {
    font = "Roboto",
    size = 30,
    weight = 500,
    antialias = true,
} )

local function OpenNSFWSettings()
    local enabled = tobool(cookie.GetString( "ImageTool.EnableNSFW" ))
    local MainWindow = vgui.Create("DFrame")
    MainWindow:SetSize(500, 150)
    MainWindow:Center()
    MainWindow:SetTitle("")
    MainWindow:SetDraggable(false)
    MainWindow:MakePopup()
    
    MainWindow.Paint = function(self, w, h)
    
        surface.SetDrawColor( 60, 60, 60, 255 )
        surface.DrawRect( 0, 0, w, 37 )
    
        surface.SetDrawColor( 37, 37, 38, 255 )
        surface.DrawRect( 0, 37, w, h )
    
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h, 5 )
        surface.DrawLine(0,37,w,37)
    
        surface.SetFont( "ImageToolNSWF" )
        surface.SetTextColor( 160, 160, 160 )
        surface.SetTextPos( 10, 7 ) 
        surface.DrawText( "ImageTool" )
    
        surface.SetTextPos( 10, 50 ) 
        surface.DrawText( "NSFW изображения:" )
    
        surface.SetTextPos( 245, 50 ) 
        surface.SetTextColor( enabled and 0 or 230, enabled and 230 or 0, 0 )
        surface.DrawText( enabled and "Включены" or "Отключены" )
    
    end
    
    local ToggleButton = vgui.Create( "DButton", MainWindow )
    ToggleButton:SetText( "" )
    ToggleButton:SetPos( 5, 100 )
    ToggleButton:SetSize( 490, 40 )
    
    ToggleButton.Paint = function(self, w, h)
        surface.SetDrawColor( 45, 45, 45, 255 )
        surface.DrawRect( 0, 0, w, h )
        surface.SetDrawColor( enabled and 0 or 230, enabled and 230 or 0, 0, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h, 2 )
        surface.SetFont( "ImageToolNSWF" )
        surface.SetTextColor( 150, 150, 150 )
        local offsetx, offsety = surface.GetTextSize(enabled and "Выключить" or "Включить")
        surface.SetTextPos( w/2-offsetx/2, h/2-offsety/2 ) 
        surface.DrawText( enabled and "Выключить" or "Включить" )
    end
    
    ToggleButton.DoClick = function()
        enabled = !enabled
        cookie.Set( "ImageTool.EnableNSFW", tostring(enabled) )
    end
end

hook.Add( "InitPostEntity", "ImageTool.InitPostEntity", function()
	if tostring(cookie.GetString( "ImageTool.EnableNSFW" )) == "nil" then
       OpenNSFWSettings()
    end
end )

concommand.Add("ImageTool_NSFW_Settings", function() OpenNSFWSettings() end)