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


-- Если картинка находится в кеше, то возвращаем его
function ImageTool:FindInCache(data)
    if self.cacheMaterials[data] then
        return self.cacheMaterials[data]
    end
end

-- Получаем картинку по uniqueID
function ImageTool:GetImage(data)
    local path = Format("%s/%s", self.path, game.GetMap())
    local filename = data .. ".png"

    if self:FindInCache(data) then
        return self:FindInCache(data)
    end

    return Material("data/" .. path .. "/" .. filename)
end

-- Скачиваем картинку
function ImageTool:DownloadImage(path, data)
    if !self.requestList[data] or CurTime() >= self.requestList[data] then
        if self:IsUsesTool(LocalPlayer()) then
            LocalPlayer():ChatPrint(self.prefix .. " Download the picture: " .. data)
        end

        -- Запрос на сайт
        http.Fetch(data, function(body, size, headers)
            local extension = self:CheckExtensionImage(body, headers)
            if !extension then return end

            file.Write(path, body)
        end)

        self.requestList[data] = CurTime() + 10
    end
end

-- Грузим картинку из URL
function ImageTool:LoadingURL(data)
    local uniqueID = util.CRC(data) -- Уникальный ID картинки

    -- Если картинка уже закешированна, то возвращаем ее
    if self:FindInCache(uniqueID) then
        return self:FindInCache(uniqueID)
    end

    local path = Format("%s/%s", self.path, game.GetMap())
    local filename = uniqueID .. ".png"

    -- Пытаемся найти картинку в дате
    if file.Exists(path .. "/" .. filename, "DATA") then
        local mat = self:GetImage(uniqueID)

        if mat and !mat:IsError() then
            if self:IsUsesTool(LocalPlayer()) then
                LocalPlayer():ChatPrint(self.prefix .. " Image has been uploaded successfully: " .. data)
            end

            self.cacheMaterials[uniqueID] = mat -- Сохраняем картинку в Кеше

            return mat
        end

        if !self.notifyErr[data] or CurTime() >= self.notifyErr[data] then
            if self:IsUsesTool(LocalPlayer()) then
                LocalPlayer():ChatPrint(self.prefix .. " It is not possible to upload a picture: " .. data .. ". Repeated request in 5 seconds!")
            end

            self.notifyErr[data] = CurTime() + 5

            -- Прерываем функцию и качаем картинку
            return self:DownloadImage(path .. "/" .. filename, data)
        end
    end

    -- Если не нашли картинку, то качаем ее
    self:DownloadImage(path .. "/" .. filename, data)
end

-- Рисуем выбранную картинку в TOOL-е
function ImageTool:DrawImageTool()
    local client = LocalPlayer()

    -- Если у нас в руках не ТулГан, то прерываем функцию
    local data = self:GetToolData(client)
    if !data then return end

    self:Start3D2D(data)
end

-- Рисуем все картинки на карте
function ImageTool:DrawAllImages()
    for k, v in pairs(self:GetImages()) do
        if LocalPlayer():GetPos():DistToSqr(v.position) >= ImageTool.dist:GetInt() * 15000 then continue end -- Удаляем картинки которые слишком далеко от игрока

        self:Start3D2D(v)
    end
end

-- Запускаем cam3d2d для отрисовки картинки
function ImageTool:Start3D2D(data)
    if !data then return end

    local scale = data.scale / 100
    local brightness = data.brightness

    local curtime = CurTime()

    -- Чото типо анимации)
    local alpha = math.sin(curtime * 2) * 255
    local dotA = math.sin(curtime * 1) * 255
    local dot = math.floor(math.abs(dotA) * 0.015)
    local dotStr = string.rep(".", dot + 1)

    local imageMaterial = self:LoadingURL(data.url)

    -- Рисуем
    cam.Start3D2D(data.position, data.angles, scale)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            if type(imageMaterial) == "IMaterial" and !imageMaterial:IsError() then -- Проверяем загрузилась ли картинка
                surface.SetDrawColor(brightness, brightness, brightness)
                surface.SetMaterial(imageMaterial)
                surface.DrawTexturedRect(0, 0, data.width, data.height)
            else
                surface.SetDrawColor(255, alpha, 255)
                surface.DrawRect(0, 0, data.width, data.height)
                draw.DrawText("Loading" .. dotStr, "Default", data.width / 2, data.height / 2 - 10, Color(alpha, 0, 0), TEXT_ALIGN_CENTER)
            end
        render.PopFilterMag()
        render.PopFilterMin()
    cam.End3D2D()
end