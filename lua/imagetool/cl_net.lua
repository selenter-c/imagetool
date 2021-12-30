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


-- Получаем новую картинку
net.Receive("image.SendImage", function()
    local length = net.ReadUInt(32)
    local id = net.ReadUInt(32)
    local data = net.ReadData(length)

    local uncompressed = util.Decompress(data)
    local info = util.JSONToTable(uncompressed)

    ImageTool.imageList[id] = info -- Добавляем

    if ImageTool:IsUsesTool(LocalPlayer()) then
        LocalPlayer():ChatPrint(ImageTool.prefix .. " Image was added successfully!")
    end
end)

-- Удаляем картинку
net.Receive("image.RemoveImage", function()
    local id = net.ReadUInt(32)

    ImageTool.imageList[id] = nil -- Удаляем

    if ImageTool:IsUsesTool(LocalPlayer()) then
        LocalPlayer():ChatPrint(ImageTool.prefix .. " Image has been successfully deleted!")
    end
end)