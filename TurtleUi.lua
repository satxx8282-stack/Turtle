--=====================================================================
--  Turtle Library v2.0  |  Complete Neverlose-Style UI
--  API: AddWindow / AddTab / AddSubTab / AddSection / AddToggle /
--       AddColorToggle / AddToggleColorpicker / AddSlider / AddDropdown /
--       AddDropdownColorpicker / AddColorpicker / AddAccordion
--  Fitur: Key System, Get Link, Config System, Search, FPS/Ping,
--         Custom Background, Open Toggle, Settings Panel per element
--  Load: local Turtle = loadstring(game:HttpGet("URL"))()
--=====================================================================

local Turtle = (function()
    local Players      = game:GetService("Players")
    local UIS          = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService   = game:GetService("RunService")
    local HttpService  = game:GetService("HttpService")
    local Stats        = game:GetService("Stats")

    local LP = Players.LocalPlayer
    local PG = LP:WaitForChild("PlayerGui")

    -- CONFIG GLOBAL
    local CFG = {
        BackgroundImage = "rbxassetid://134798950452944",
        OpenIcon        = "rbxassetid://6031075931",
        DiscordLink     = "https://discord.gg/deltahub",
        KeyLink         = "https://discord.gg/deltahub",
    }

    pcall(function()
        local old = PG:FindFirstChild("Turtle")
        if old then old:Destroy() end
    end)

    --// HELPERS
    local function New(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function Tween(obj, props, t, style, dir)
        style = style or Enum.EasingStyle.Quad
        dir   = dir or Enum.EasingDirection.Out
        TweenService:Create(obj, TweenInfo.new(t or 0.2, style, dir), props):Play()
    end
    local function Corner(parent, r)
        local c = New("UICorner", {Parent = parent})
        c.CornerRadius = UDim.new(0, r or 10)
        return c
    end
    local function Stroke(parent, col, thick, trans)
        local s = New("UIStroke", {Parent = parent})
        s.Color = col or Color3.fromRGB(70,70,90)
        s.Thickness = thick or 1
        s.Transparency = trans or 0.4
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end
    local function MakeDraggable(frame, handle)
        handle = handle or frame
        local dragging, dragInput, mousePos, framePos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                mousePos = input.Position
                framePos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                frame.Position = UDim2.new(
                    framePos.X.Scale, framePos.X.Offset + delta.X,
                    framePos.Y.Scale, framePos.Y.Offset + delta.Y
                )
            end
        end)
    end
    local function SerializeValue(v)
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then return v end
        if t == "userdata" and typeof(v) == "Color3" then
            return {__type = "Color3", r = v.R, g = v.G, b = v.B}
        end
        return nil
    end
    local function DeserializeValue(v)
        if type(v) == "table" and v.__type == "Color3" then
            return Color3.new(v.r, v.g, v.b)
        end
        return v
    end

    -- ICON RESOLVER (mendukung nama pendek atau langsung rbxassetid)
    local function GetImageData(name, image)
        name = (name or "home"):lower()
        local Nig = "rbxassetid://3926305904"
        if name == "home" then image.Image = Nig; image.ImageRectOffset = Vector2.new(964,205); image.ImageRectSize = Vector2.new(35,35)
        elseif name == "user" then image.Image = "rbxassetid://10494577250"
        elseif name == "settings" then image.Image = "rbxassetid://134488580093972"
        elseif name == "shield" then image.Image = "rbxassetid://97456145319566"
        elseif name == "sword" then image.Image = "rbxassetid://82635240213192"
        elseif name == "gun" then image.Image = "rbxassetid://93001822915827"
        elseif name == "car" then image.Image = "rbxassetid://116283987324457"
        elseif name == "shop" then image.Image = "rbxassetid://97513888174732"
        elseif name == "star" then image.Image = "rbxassetid://120439606355359"
        elseif name == "flag" then image.Image = "rbxassetid://119948798441279"
        elseif name == "lock" then image.Image = Nig; image.ImageRectOffset = Vector2.new(524,644); image.ImageRectSize = Vector2.new(35,35)
        elseif name == "list" then image.Image = Nig; image.ImageRectOffset = Vector2.new(485,205); image.ImageRectSize = Vector2.new(35,35)
        else
            image.Image = name
        end
    end

    -- OPEN BUTTON (muncul setelah key valid)
    local ScreenGui = New("ScreenGui", {
        Name = "Turtle", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = PG,
    })

    local openBtn = New("TextButton", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 58, 0, 58),
        Position = UDim2.new(0, 20, 0.5, -29),
        BackgroundColor3 = Color3.fromRGB(30, 30, 45),
        Text = "", AutoButtonColor = false, Visible = false,
    }, ScreenGui)
    Corner(openBtn, 29)
    local openStroke = Stroke(openBtn, Color3.fromRGB(120, 140, 255), 2, 0)
    New("ImageLabel", {
        Parent = openBtn, BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0.5, -16, 0.5, -16),
        Image = CFG.OpenIcon, ImageColor3 = Color3.fromRGB(255,255,255),
    }, openBtn)
    task.spawn(function()
        while openBtn.Parent do
            Tween(openStroke, {Transparency = 0.7}, 1, Enum.EasingStyle.Sine); task.wait(1)
            Tween(openStroke, {Transparency = 0}, 1, Enum.EasingStyle.Sine); task.wait(1)
        end
    end)

    -- NOTIFICATION
    local notifHolder = New("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -18, 0, 18), Size = UDim2.new(0, 300, 1, -36),
    }, ScreenGui)
    New("UIListLayout", {
        Parent = notifHolder, Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, notifHolder)
    local function Notify(cfg)
        cfg = cfg or {}
        local n = New("Frame", {
            Parent = notifHolder, Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = Color3.fromRGB(22,22,30), BackgroundTransparency = 1,
            Position = UDim2.new(0, 320, 0, 0),
        }, notifHolder)
        Corner(n, 10); Stroke(n, Color3.fromRGB(120,140,255), 1, 0.4)
        local ac = New("Frame", {
            Parent = n, BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, -12), Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Color3.fromRGB(120,140,255),
        }, n)
        Corner(ac, 4)
        New("TextLabel", {
            Parent = n, BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 8), Size = UDim2.new(1, -30, 0, 18),
            Font = Enum.Font.GothamBold, Text = tostring(cfg.Title or "Turtle"),
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, n)
        New("TextLabel", {
            Parent = n, BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 28), Size = UDim2.new(1, -30, 0, 34),
            Font = Enum.Font.Gotham, Text = tostring(cfg.Content or ""),
            TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        }, n)
        Tween(n, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0}, 0.4)
        task.delay(cfg.Duration or 4, function()
            Tween(n, {Position = UDim2.new(0,320,0,0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.35); n:Destroy()
        end)
    end

    -- REGISTRY
    local _registeredElements = {}
    local _openPopups = {}
    local function RegisterPopup(frame, closeFn)
        for _, p in ipairs(_openPopups) do
            if p.frame == frame then return end
        end
        table.insert(_openPopups, {frame = frame, closeFn = closeFn})
    end
    local function UnregisterPopup(frame)
        for i, p in ipairs(_openPopups) do
            if p.frame == frame then table.remove(_openPopups, i); return end
        end
    end
    local function CloseAllPopupsExcept(except)
        for _, p in ipairs(_openPopups) do
            if p.frame ~= except then pcall(p.closeFn) end
        end
    end
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local mp = UIS:GetMouseLocation()
        local toClose = {}
        for _, p in ipairs(_openPopups) do
            if p.frame and p.frame.Visible then
                local pos = p.frame.AbsolutePosition
                local size = p.frame.AbsoluteSize
                local inside = mp.X >= pos.X and mp.X <= pos.X + size.X
                    and mp.Y >= pos.Y and mp.Y <= pos.Y + size.Y
                if not inside then table.insert(toClose, p.closeFn) end
            end
        end
        for _, fn in ipairs(toClose) do pcall(fn) end
    end)

    local function SmoothOpen(frame, targetAlpha, dur)
        frame.BackgroundTransparency = 1
        frame.Visible = true
        TweenService:Create(frame, TweenInfo.new(dur or 0.2),
            {BackgroundTransparency = targetAlpha}):Play()
    end
    local function SmoothClose(frame, dur, cb)
        TweenService:Create(frame, TweenInfo.new(dur or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {BackgroundTransparency = 1}):Play()
        task.delay((dur or 0.18) + 0.01, function()
            frame.Visible = false
            if cb then cb() end
        end)
    end

    --===== KEY SYSTEM =====
    local function runKeySystem(KeySettings, onSuccess)
        local keyFrame = New("Frame", {
            Parent = ScreenGui, Size = UDim2.new(0, 440, 0, 300),
            Position = UDim2.new(0.5, -220, 0.5, -150),
            BackgroundColor3 = Color3.fromRGB(16, 18, 28), BorderSizePixel = 0,
        }, ScreenGui)
        Corner(keyFrame, 14); Stroke(keyFrame, Color3.fromRGB(120,140,255), 1.5, 0.2)
        local bg = New("ImageLabel", {
            Parent = keyFrame, Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, Image = CFG.BackgroundImage,
            ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Crop, ZIndex = 0,
        }, keyFrame)
        Corner(bg, 14)
        local ov = New("Frame", {
            Parent = keyFrame, Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = Color3.fromRGB(8,10,16), BackgroundTransparency = 0.35,
            BorderSizePixel = 0, ZIndex = 1,
        }, keyFrame)
        Corner(ov, 14)

        New("TextLabel", {
            Parent = keyFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 26),
            Font = Enum.Font.GothamBold, Text = KeySettings.Title or "Turtle | Key System",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 17, ZIndex = 2,
        }, keyFrame)
        New("TextLabel", {
            Parent = keyFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.Gotham, Text = KeySettings.Subtitle or "Masukkan key untuk melanjutkan",
            TextColor3 = Color3.fromRGB(160,160,190), TextSize = 12, ZIndex = 2,
        }, keyFrame)

        local keyBox = New("TextBox", {
            Parent = keyFrame, Position = UDim2.new(0.5, -160, 0, 90),
            Size = UDim2.new(0, 320, 0, 42),
            BackgroundColor3 = Color3.fromRGB(28, 30, 46),
            Font = Enum.Font.GothamMedium, Text = "",
            PlaceholderText = "Masukkan key di sini...",
            PlaceholderColor3 = Color3.fromRGB(120,120,150),
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14,
            ClearTextOnFocus = false, ZIndex = 2,
        }, keyFrame)
        Corner(keyBox, 10); Stroke(keyBox, Color3.fromRGB(80,90,150), 1, 0.3)

        local submit = New("TextButton", {
            Parent = keyFrame, Position = UDim2.new(0.5, -160, 0, 148),
            Size = UDim2.new(0, 100, 0, 40),
            BackgroundColor3 = Color3.fromRGB(90, 120, 255),
            Font = Enum.Font.GothamBold, Text = "Submit",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
            AutoButtonColor = false, ZIndex = 2,
        }, keyFrame)
        Corner(submit, 10)

        local getKeyBtn = New("TextButton", {
            Parent = keyFrame, Position = UDim2.new(0.5, -50, 0, 148),
            Size = UDim2.new(0, 100, 0, 40),
            BackgroundColor3 = Color3.fromRGB(50, 140, 90),
            Font = Enum.Font.GothamBold, Text = "Get Link",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
            AutoButtonColor = false, ZIndex = 2,
        }, keyFrame)
        Corner(getKeyBtn, 10); Stroke(getKeyBtn, Color3.fromRGB(80,200,130), 1, 0.3)

        local copyBtn = New("TextButton", {
            Parent = keyFrame, Position = UDim2.new(0.5, 60, 0, 148),
            Size = UDim2.new(0, 100, 0, 40),
            BackgroundColor3 = Color3.fromRGB(60, 80, 160),
            Font = Enum.Font.GothamBold, Text = "Discord",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
            AutoButtonColor = false, ZIndex = 2,
        }, keyFrame)
        Corner(copyBtn, 10); Stroke(copyBtn, Color3.fromRGB(120,150,255), 1, 0.3)

        getKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(CFG.KeyLink)
                Notify({Title = "Get Key", Content = "Link disalin: " .. CFG.KeyLink, Duration = 5})
            else
                Notify({Title = "Get Key", Content = "Buka: " .. CFG.KeyLink})
            end
        end)

        copyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(CFG.DiscordLink)
                Notify({Title = "Discord", Content = "Link di-copy: " .. CFG.DiscordLink})
            end
        end)

        local statusLbl = New("TextLabel", {
            Parent = keyFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 1, -60), Size = UDim2.new(1, -24, 0, 18),
            Font = Enum.Font.Gotham, Text = KeySettings.Note or "Belum punya key? Klik Get Link / Discord.",
            TextColor3 = Color3.fromRGB(140,140,180), TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2,
        }, keyFrame)
        New("TextLabel", {
            Parent = keyFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 1, -36), Size = UDim2.new(1, -24, 0, 20),
            Font = Enum.Font.Gotham, Text = "Discord: " .. CFG.DiscordLink,
            TextColor3 = Color3.fromRGB(140,140,180), TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2,
        }, keyFrame)

        local function tryKey()
            local input = keyBox.Text
            local valid = false
            for _, k in ipairs(KeySettings.Key or {}) do
                if input == k then valid = true; break end
            end
            if valid then
                statusLbl.Text = "Key valid! Loading..."
                statusLbl.TextColor3 = Color3.fromRGB(100,255,130)
                Tween(keyFrame, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.3)
                task.wait(0.35)
                keyFrame:Destroy()
                Notify({Title = "Success", Content = "Key valid! Selamat datang di Turtle"})
                onSuccess()
            else
                statusLbl.Text = "Key tidak valid!"
                statusLbl.TextColor3 = Color3.fromRGB(255,100,120)
                for _, off in ipairs({-165, -175, -160}) do
                    Tween(keyBox, {Position = UDim2.new(0.5, off, 0, 90)}, 0.06)
                    task.wait(0.06)
                end
            end
        end
        submit.MouseButton1Click:Connect(tryKey)
        keyBox.FocusLost:Connect(function(e) if e then tryKey() end end)
        MakeDraggable(keyFrame, keyFrame)
    end

    --===== MAIN LIBRARY =====
    local Library = {}
    Library.__index = Library
    Library.Notify = Notify
    Library.Config = CFG

    function Library:AddWindow(hubTitle, hubImage, gameTitle)
        hubTitle = hubTitle or "Turtle Hub"
        hubImage = hubImage or CFG.OpenIcon
        gameTitle = gameTitle or "Game"

        local mainColor = Color3.fromRGB(26, 123, 255)
        local tabs = {}
        local activeTabIndex = nil
        local tabOrder = 0
        local WindowObj = {}
        local _coloredElements = {}

        -- Root Frame
        local MainFrame = New("Frame", {
            Name = "MainFrame", Active = true,
            AnchorPoint = Vector2.new(0.5, 0.4),
            Size = UDim2.new(0, 620, 0, 420),
            BackgroundColor3 = Color3.fromRGB(3,3,14),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0, Visible = false,
        }, ScreenGui)
        Corner(MainFrame, 12)

        -- Custom Background Decal
        local bgDecal = New("ImageLabel", {
            Parent = MainFrame, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Image = CFG.BackgroundImage,
            ImageTransparency = 0.75, ScaleType = Enum.ScaleType.Crop, ZIndex = 0,
        }, MainFrame)
        Corner(bgDecal, 12)

        -- Drop Shadow
        local DropShadow = New("ImageLabel", {
            Parent = MainFrame, AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 47, 1, 47),
            ZIndex = -1, Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.fromRGB(16,19,28),
            ImageTransparency = 0.34,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49,49,450,450),
        }, MainFrame)

        -- Hub Icon + Title + GameTitle
        local HubIcon = New("ImageLabel", {
            Name = "HubIcon",
            Position = UDim2.new(0.014, 0, 0.013, 0),
            Size = UDim2.new(0.05, 0, 0.06, 0),
            BackgroundColor3 = Color3.fromRGB(19,22,33),
            BorderSizePixel = 0, Image = hubImage,
            ZIndex = 3,
        }, MainFrame)
        Corner(HubIcon, 6)

        local titleLbl = New("TextLabel", {
            Name = "Title",
            Position = UDim2.new(0.068, 0, 0.0087, 0),
            Size = UDim2.new(0.6, 0, 0.05, 0),
            BackgroundTransparency = 1,
            Text = hubTitle, TextColor3 = Color3.fromRGB(255,255,255),
            TextScaled = true, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
        }, MainFrame)
        New("UIAspectRatioConstraint", {AspectType = Enum.AspectType.FitWithinMaxSize}, titleLbl)

        local gameTitleLbl = New("TextLabel", {
            Name = "GameTitle",
            Position = UDim2.new(0.068, 0, 0.047, 0),
            Size = UDim2.new(0.4, 0, 0.017, 0),
            BackgroundTransparency = 1, Text = gameTitle,
            TextColor3 = Color3.fromRGB(255,255,255), TextScaled = true,
            TextTransparency = 0.6, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
        }, MainFrame)
        New("UIAspectRatioConstraint", {AspectType = Enum.AspectType.FitWithinMaxSize}, gameTitleLbl)

        -- FPS/Ping Display (top right)
        local GameInfo = New("Frame", {
            Name = "GameInfo",
            Position = UDim2.new(1, -210, 0, 8),
            Size = UDim2.new(0, 200, 0, 28),
            BackgroundColor3 = Color3.fromRGB(14,17,27),
            BackgroundTransparency = 0.2, BorderSizePixel = 0,
            ZIndex = 3,
        }, MainFrame)
        Corner(GameInfo, 14)

        local FPSLbl = New("TextLabel", {
            Parent = GameInfo, BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.45, 0, 1, 0),
            Font = Enum.Font.GothamBold, Text = "0 FPS",
            TextColor3 = Color3.fromRGB(0, 200, 255), TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
        }, GameInfo)
        local MSLbl = New("TextLabel", {
            Parent = GameInfo, BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -10, 1, 0),
            Font = Enum.Font.GothamBold, Text = "0 MS",
            TextColor3 = Color3.fromRGB(0, 200, 255), TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
        }, GameInfo)

        local fpsBuffer = {}
        RunService.RenderStepped:Connect(function(dt)
            table.insert(fpsBuffer, dt)
            if #fpsBuffer > 20 then table.remove(fpsBuffer, 1) end
            local avg = 0
            for _, v in ipairs(fpsBuffer) do avg += v end
            FPSLbl.Text = math.round(#fpsBuffer / avg) .. " FPS"
            local ok, ping = pcall(function()
                return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            MSLbl.Text = (ok and ping or 0) .. " MS"
        end)

        -- User Info (bottom left)
        local UserInfo = New("Frame", {
            Name = "UserInfo",
            Position = UDim2.new(0.009, 0, 0.907, 0),
            Size = UDim2.new(0.2, 0, 0.079, 0),
            BackgroundTransparency = 1, ZIndex = 3,
        }, MainFrame)

        local avatar = New("ImageLabel", {
            Parent = UserInfo, Size = UDim2.new(0.34, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(21,24,36),
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150",
            ZIndex = 3,
        }, UserInfo)
        Corner(avatar, 999)
        New("UIAspectRatioConstraint", {AspectType = Enum.AspectType.ScaleWithParentSize}, avatar)

        New("TextLabel", {
            Parent = UserInfo,
            Position = UDim2.new(0.3, 0, 0.15, 0), Size = UDim2.new(0.6, 0, 0.4, 0),
            BackgroundTransparency = 1, Text = LP.Name,
            TextColor3 = Color3.fromRGB(255,255,255), TextScaled = true,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
        }, UserInfo)
        New("TextLabel", {
            Parent = UserInfo,
            Position = UDim2.new(0.3, 0, 0.6, 0), Size = UDim2.new(0.6, 0, 0.25, 0),
            BackgroundTransparency = 1, Text = "Lifetime",
            TextColor3 = Color3.fromRGB(255,255,255), TextScaled = true,
            Font = Enum.Font.Gotham, TextTransparency = 0.6,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
        }, UserInfo)

        -- Tab List (left column)
        local TabHolder = New("ScrollingFrame", {
            Name = "Tab",
            Position = UDim2.new(0.008, 0, 0.085, 0),
            Size = UDim2.new(0.2, 0, 0.815, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 0, ZIndex = 3,
        }, MainFrame)
        New("UIListLayout", {
            Parent = TabHolder, Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, TabHolder)

        -- Content area
        local ContentFrame = New("Frame", {
            Name = "Frame2",
            Position = UDim2.new(0.23, 0, 0, 0),
            Size = UDim2.new(0.77, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(15,17,26),
            BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 1,
        }, MainFrame)
        Corner(ContentFrame, 12)

        -- Header (search + settings)
        local Header = New("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0.09, 0),
            BackgroundTransparency = 1, ZIndex = 2,
        }, ContentFrame)

        local SearchBtn = New("ImageButton", {
            Name = "Search",
            Position = UDim2.new(0.938, 0, 0.2, 0),
            Size = UDim2.new(0.034, 0, 0.45, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6031154871",
            ImageColor3 = Color3.fromRGB(200,200,220), ZIndex = 3,
        }, Header)
        New("UIAspectRatioConstraint", {}, SearchBtn)

        local SearchBox = New("TextBox", {
            Name = "SearchBox",
            Position = UDim2.new(0.45, 0, 0.1, 0),
            Size = UDim2.new(0, 0, 0.6, 0),
            BackgroundColor3 = Color3.fromRGB(16,19,28),
            Text = "", PlaceholderText = "Search",
            PlaceholderColor3 = Color3.fromRGB(178,178,178),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextScaled = true, Font = Enum.Font.Gotham,
            Visible = false, TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, ZIndex = 3,
        }, Header)
        Corner(SearchBox, 5)
        Stroke(SearchBox, Color3.fromRGB(55,65,105), 1, 0.8)

        local searchOpen = false
        SearchBtn.MouseButton1Click:Connect(function()
            searchOpen = not searchOpen
            if searchOpen then
                SearchBox.Visible = true
                SearchBox.Size = UDim2.new(0, 0, 0.6, 0)
                Tween(SearchBox, {Size = UDim2.new(0.4, 0, 0.6, 0)}, 0.3, Enum.EasingStyle.Back)
                task.wait(0.3)
                SearchBox:CaptureFocus()
            else
                Tween(SearchBox, {Size = UDim2.new(0, 0, 0.6, 0)}, 0.2)
                task.wait(0.21)
                SearchBox.Visible = false
                SearchBox.Text = ""
            end
        end)

        -- Settings button (top right)
        local WSSettingsBtn = New("TextButton", {
            Name = "WSBtn",
            Position = UDim2.new(0.9, 0, 0.2, 0),
            Size = UDim2.new(0.034, 0, 0.45, 0),
            BackgroundTransparency = 1, Text = "", ZIndex = 3,
        }, Header)
        New("UIAspectRatioConstraint", {}, WSSettingsBtn)
        local WSIcon = New("ImageLabel", {
            Parent = WSSettingsBtn, Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://134488580093972",
            ImageColor3 = Color3.fromRGB(200,200,220),
        }, WSSettingsBtn)

        -- Settings Panel
        local WSPanel = New("Frame", {
            Parent = MainFrame,
            Position = UDim2.new(0.75, 0, 0.1, 0),
            Size = UDim2.new(0.235, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(17,20,30),
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0, Visible = false, ZIndex = 50,
            ClipsDescendants = true,
        }, MainFrame)
        Corner(WSPanel, 10); Stroke(WSPanel, Color3.fromRGB(60,60,90), 1, 0.4)
        New("UIListLayout", {Parent = WSPanel, Padding = UDim.new(0, 4)}, WSPanel)
        New("UIPadding", {
            Parent = WSPanel,
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        }, WSPanel)

        New("TextLabel", {
            Parent = WSPanel, Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1, Text = "SETTINGS",
            TextColor3 = mainColor, TextSize = 12, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0,
        }, WSPanel)

        local function MakeSettingRow(text, cb)
            local row = New("Frame", {
                Parent = WSPanel, Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Color3.fromRGB(24,28,42),
                BackgroundTransparency = 0.3, BorderSizePixel = 0,
            }, WSPanel)
            Corner(row, 6)
            New("TextLabel", {
                Parent = row, Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1,
                Text = text, TextColor3 = Color3.fromRGB(220,220,235),
                TextSize = 12, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, row)
            local val = New("TextButton", {
                Parent = row, Position = UDim2.new(0.55, 0, 0.15, 0),
                Size = UDim2.new(0.42, 0, 0.7, 0),
                BackgroundColor3 = mainColor, BackgroundTransparency = 0.3,
                Text = "Open", TextColor3 = Color3.fromRGB(255,255,255),
                TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false,
            }, row)
            Corner(val, 5)
            return row, val
        end

        local scaleOptions = {"Auto", "90%", "80%", "70%", "60%", "50%"}
        local scaleValues = {1, 0.9, 0.8, 0.7, 0.6, 0.5}
        local scaleIndex = 1
        local UIScale = New("UIScale", {Scale = 1}, MainFrame)

        local scaleRow, scaleBtn = MakeSettingRow("Menu Scale", nil)
        scaleBtn.Text = scaleOptions[1]
        scaleBtn.MouseButton1Click:Connect(function()
            scaleIndex = scaleIndex + 1
            if scaleIndex > #scaleOptions then scaleIndex = 1 end
            scaleBtn.Text = scaleOptions[scaleIndex]
            UIScale.Scale = scaleValues[scaleIndex]
        end)

        -- Main color picker
        local hue, sat, val = Color3.toHSV(mainColor)
        local colorRow = New("Frame", {
            Parent = WSPanel, Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Color3.fromRGB(24,28,42),
            BackgroundTransparency = 0.3, BorderSizePixel = 0,
        }, WSPanel)
        Corner(colorRow, 6)
        New("TextLabel", {
            Parent = colorRow, Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1,
            Text = "Main Color", TextColor3 = Color3.fromRGB(220,220,235),
            TextSize = 12, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, colorRow)
        local colorBtn = New("TextButton", {
            Parent = colorRow, Position = UDim2.new(0.85, 0, 0.2, 0),
            Size = UDim2.new(0.12, 0, 0.6, 0),
            BackgroundColor3 = mainColor, Text = "", AutoButtonColor = false,
        }, colorRow)
        Corner(colorBtn, 5)

        local wsOpen = false
        WSSettingsBtn.MouseButton1Click:Connect(function()
            wsOpen = not wsOpen
            if wsOpen then
                WSPanel.Visible = true
                WSPanel.Size = UDim2.new(0.235, 0, 0, 0)
                Tween(WSPanel, {Size = UDim2.new(0.235, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back)
            else
                Tween(WSPanel, {Size = UDim2.new(0.235, 0, 0, 0)}, 0.18)
                task.wait(0.19)
                WSPanel.Visible = false
            end
        end)

        -- Content columns
        local TabHose = New("Frame", {
            Name = "TabHose",
            Position = UDim2.new(0.01, 0, 0.092, 0),
            Size = UDim2.new(0.99, 0, 0.896, 0),
            BackgroundTransparency = 1, ZIndex = 2,
        }, ContentFrame)
        New("UIListLayout", {
            Parent = TabHose, FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 13), SortOrder = Enum.SortOrder.LayoutOrder,
        }, TabHose)

        -- Config system
        local _configs = {}
        local function GetConfigPath(name) return "TurtleConfig_" .. name .. ".json" end
        local function SaveNamedConfig(name)
            if not writefile then return end
            local data = {}
            for _, e in ipairs(_registeredElements) do
                local ok, v = pcall(function() return e.obj:Get() end)
                if ok then
                    local s = SerializeValue(v)
                    if s ~= nil then data[e.key] = s end
                end
            end
            local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
            if ok then pcall(writefile, GetConfigPath(name), enc) end
        end
        local function LoadNamedConfig(name)
            if not readfile or not isfile then return end
            local p = GetConfigPath(name)
            if not isfile(p) then return end
            local ok, content = pcall(readfile, p)
            if not ok then return end
            local dok, data = pcall(HttpService.JSONDecode, HttpService, content)
            if not dok or type(data) ~= "table" then return end
            for _, e in ipairs(_registeredElements) do
                local sv = data[e.key]
                if sv ~= nil then
                    pcall(function() e.obj:Set(DeserializeValue(sv)) end)
                end
            end
        end
        local function ListConfigs()
            if not listfiles then return {} end
            local r = {}
            local ok, files = pcall(listfiles, "")
            if not ok then return r end
            for _, f in ipairs(files) do
                local n = f:match("TurtleConfig_(.+)%.json$")
                if n then table.insert(r, n) end
            end
            return r
        end

        -- Tab creation
        local function createTab(name, icon)
            tabOrder = tabOrder + 1
            local tabIndex = #tabs + 1
            local isFirst = tabIndex == 1

            local TabButton = New("Frame", {
                Name = "TabButton",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isFirst and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,28,42),
                BackgroundTransparency = isFirst and 0.9 or 1,
                LayoutOrder = tabOrder, ZIndex = 3,
            }, TabHolder)
            Corner(TabButton, 5)

            local TabIcon = New("ImageLabel", {
                Name = "TabIcon",
                Position = UDim2.new(0.1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0.2, 0, 0.65, 0),
                BackgroundTransparency = 1, Image = "",
                ImageColor3 = isFirst and mainColor or Color3.fromRGB(255,255,255),
                ImageTransparency = isFirst and 0 or 0.6, ZIndex = 4,
            }, TabButton)
            New("UIAspectRatioConstraint", {AspectRatio = 1}, TabIcon)
            if icon and icon ~= "" then GetImageData(icon, TabIcon) end

            local TabText = New("TextLabel", {
                Name = "TabText",
                Position = UDim2.new(0.23, 0, 0.235, 0),
                Size = UDim2.new(0.7, 0, 0.51, 0),
                BackgroundTransparency = 1, Text = name,
                TextColor3 = Color3.fromRGB(255,255,255),
                TextScaled = true, Font = Enum.Font.GothamSemibold,
                TextTransparency = isFirst and 0 or 0.6,
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
            }, TabButton)

            local ClickArea = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1, Text = "", ZIndex = 5,
            }, TabButton)

            local Left = New("Frame", {
                Name = "Left", Size = UDim2.new(0.48, 0, 1, 0),
                BackgroundTransparency = 1, Visible = isFirst, ZIndex = 2,
            }, TabHose)
            New("UIListLayout", {
                Parent = Left, Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Left)
            local Right = New("Frame", {
                Name = "Right", Size = UDim2.new(0.48, 0, 1, 0),
                BackgroundTransparency = 1, LayoutOrder = 1,
                Visible = isFirst, ZIndex = 2,
            }, TabHose)
            New("UIListLayout", {
                Parent = Right, Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Right)

            local function HideContent()
                Left.Visible = false
                Right.Visible = false
            end
            local function ShowContent()
                Left.Position = UDim2.new(0.04, 0, 0, 0)
                Right.Position = UDim2.new(0.04, 0, 0, 0)
                Left.Visible = true
                Right.Visible = true
                Tween(Left, {Position = UDim2.new(0,0,0,0)}, 0.25)
                Tween(Right, {Position = UDim2.new(0,0,0,0)}, 0.25)
            end

            ClickArea.MouseButton1Click:Connect(function()
                for _, t in ipairs(tabs) do
                    Tween(t.btn, {BackgroundTransparency = 1}, 0.2)
                    Tween(t.icon, {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = 0.6}, 0.2)
                    Tween(t.txt, {TextTransparency = 0.6}, 0.2)
                    t.hide()
                end
                TabButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
                Tween(TabButton, {BackgroundTransparency = 0.9}, 0.25)
                Tween(TabIcon, {ImageColor3 = mainColor, ImageTransparency = 0}, 0.25)
                Tween(TabText, {TextTransparency = 0}, 0.25)
                ShowContent()
                activeTabIndex = tabIndex
            end)

            table.insert(tabs, {
                btn = TabButton, icon = TabIcon, txt = TabText,
                hide = HideContent, show = ShowContent,
            })
            if isFirst then activeTabIndex = 1 end

            local TabObj = {}
            local sectionOrder = {left = 0, right = 0}

            function TabObj:AddSection(title, side)
                side = side or "left"
                sectionOrder[side] = sectionOrder[side] + 1
                local col = side == "right" and Right or Left

                local Section = New("Frame", {
                    Name = "Section",
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionOrder[side], ZIndex = 3,
                }, col)
                New("UIListLayout", {
                    Parent = Section, SortOrder = Enum.SortOrder.LayoutOrder,
                }, Section)

                local SectionLabelFrame = New("Frame", {
                    Parent = Section, Size = UDim2.new(0.5, 0, 0, 18),
                    BackgroundTransparency = 1, LayoutOrder = 0,
                }, Section)
                New("TextLabel", {
                    Parent = SectionLabelFrame,
                    Position = UDim2.new(0.07, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, Text = title,
                    TextColor3 = Color3.fromRGB(120,140,200),
                    TextScaled = true, Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, SectionLabelFrame)

                local Elements = New("Frame", {
                    Name = "Elements",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(21,24,35),
                    BackgroundTransparency = 0.26,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 1, ZIndex = 3,
                }, Section)
                Corner(Elements, 8)
                New("UIListLayout", {
                    Parent = Elements, Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, Elements)
                New("UIPadding", {
                    Parent = Elements,
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                }, Elements)
                Stroke(Elements, Color3.fromRGB(60,60,90), 1, 0.9)

                local SectionObj = {}
                local elemCount = 0

                -- Per-element Settings panel (opens via "..." button)
                local function MakeSettings(parentFrame, elementType, label)
                    local settingsOpen = false
                    local SettingsBtn = New("TextButton", {
                        Name = "Settings",
                        Position = UDim2.new(0.88, 0, 0.15, 0),
                        Size = UDim2.new(0.1, 0, 0.7, 0),
                        BackgroundTransparency = 1, Text = "...",
                        TextColor3 = Color3.fromRGB(220,220,235),
                        TextScaled = true, Font = Enum.Font.GothamBold,
                        ZIndex = 10,
                    }, parentFrame)

                    local SettingsFrame = New("Frame", {
                        Name = "SettingsFrame",
                        Position = UDim2.new(1, 6, 0, 0),
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3 = Color3.fromRGB(17,20,30),
                        BackgroundTransparency = 1, BorderSizePixel = 0,
                        Visible = false, ZIndex = 100,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        ClipsDescendants = true,
                    }, parentFrame)
                    Corner(SettingsFrame, 8); Stroke(SettingsFrame, Color3.fromRGB(60,60,90), 1, 0.4)
                    local SFLayout = New("UIListLayout", {
                        Parent = SettingsFrame, Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, SettingsFrame)
                    New("UIPadding", {
                        Parent = SettingsFrame,
                        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                    }, SettingsFrame)

                    New("TextLabel", {
                        Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1, Text = label or "",
                        TextColor3 = mainColor, TextSize = 11,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = 0,
                    }, SettingsFrame)

                    local SettingsObj = {}
                    local setCount = 0

                    function SettingsObj:AddToggle(text, default, callback)
                        setCount = setCount + 1
                        local en = default or false
                        local row = New("Frame", {
                            Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1, LayoutOrder = setCount,
                        }, SettingsFrame)
                        New("TextLabel", {
                            Parent = row, Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0.7, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, row)
                        local ef = New("Frame", {
                            Parent = row, Position = UDim2.new(0.85, 0, 0.2, 0),
                            Size = UDim2.new(0.14, 0, 0.6, 0),
                            BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60),
                        }, row)
                        Corner(ef, 10)
                        local kn = New("Frame", {
                            Parent = ef, Size = UDim2.new(0, 10, 1, 0),
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            Position = en and UDim2.new(1, -10, 0, 0) or UDim2.new(0, 0, 0, 0),
                        }, ef)
                        Corner(kn, 10)
                        local btn = New("TextButton", {
                            Parent = row, Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1, Text = "", ZIndex = 20,
                        }, row)
                        btn.MouseButton1Click:Connect(function()
                            en = not en
                            Tween(ef, {BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60)}, 0.2)
                            Tween(kn, {Position = en and UDim2.new(1, -10, 0, 0) or UDim2.new(0, 0, 0, 0)}, 0.2)
                            if callback then callback(en) end
                        end)
                    end

                    function SettingsObj:AddCheckbox(text, default, callback)
                        setCount = setCount + 1
                        local en = default or false
                        local row = New("Frame", {
                            Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1, LayoutOrder = setCount,
                        }, SettingsFrame)
                        New("TextLabel", {
                            Parent = row, Position = UDim2.new(0.15, 0, 0, 0),
                            Size = UDim2.new(0.85, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, row)
                        local box = New("Frame", {
                            Parent = row, Position = UDim2.new(0, 0, 0.2, 0),
                            Size = UDim2.new(0, 14, 0, 14),
                            BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60),
                        }, row)
                        Corner(box, 3)
                        local btn = New("TextButton", {
                            Parent = row, Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1, Text = "", ZIndex = 20,
                        }, row)
                        btn.MouseButton1Click:Connect(function()
                            en = not en
                            Tween(box, {BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60)}, 0.2)
                            if callback then callback(en) end
                        end)
                    end

                    function SettingsObj:AddSlider(text, min, max, default, callback, suffix)
                        setCount = setCount + 1
                        min = min or 0; max = max or 100
                        local val = math.clamp(default or min, min, max)
                        suffix = suffix or ""
                        local row = New("Frame", {
                            Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 34),
                            BackgroundTransparency = 1, LayoutOrder = setCount,
                        }, SettingsFrame)
                        New("TextLabel", {
                            Parent = row, Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0.7, 0, 0.5, 0),
                            BackgroundTransparency = 1, Text = text,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, row)
                        local valLbl = New("TextLabel", {
                            Parent = row, Position = UDim2.new(0.75, 0, 0, 0),
                            Size = UDim2.new(0.25, 0, 0.5, 0),
                            BackgroundTransparency = 1, Text = tostring(val) .. suffix,
                            TextColor3 = mainColor, TextSize = 11,
                            Font = Enum.Font.GothamBold,
                            TextXAlignment = Enum.TextXAlignment.Right,
                        }, row)
                        local bar = New("Frame", {
                            Parent = row, Position = UDim2.new(0, 0, 0.65, 0),
                            Size = UDim2.new(1, 0, 0, 5),
                            BackgroundColor3 = Color3.fromRGB(40,40,60),
                        }, row)
                        Corner(bar, 3)
                        local rel = (val - min) / (max - min)
                        local fill = New("Frame", {
                            Parent = bar, Size = UDim2.new(rel, 0, 1, 0),
                            BackgroundColor3 = mainColor,
                        }, bar)
                        Corner(fill, 3)
                        local dragging = false
                        local function upd(input)
                            local r = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            val = math.floor(min + (max - min) * r)
                            valLbl.Text = tostring(val) .. suffix
                            fill.Size = UDim2.new(r, 0, 1, 0)
                            if callback then callback(val) end
                        end
                        bar.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                            or i.UserInputType == Enum.UserInputType.Touch then
                                dragging = true; upd(i)
                            end
                        end)
                        UIS.InputChanged:Connect(function(i)
                            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                            or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
                        end)
                        UIS.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
                        end)
                    end

                    function SettingsObj:AddDropdown(text, options, default, callback)
                        if type(default) == "function" then callback = default; default = nil end
                        setCount = setCount + 1
                        options = options or {}
                        local selected = default or options[1] or "..."
                        local row = New("Frame", {
                            Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 24),
                            BackgroundTransparency = 1, LayoutOrder = setCount,
                        }, SettingsFrame)
                        New("TextLabel", {
                            Parent = row, Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0.4, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, row)
                        local selBtn = New("TextButton", {
                            Parent = row, Position = UDim2.new(0.45, 0, 0.1, 0),
                            Size = UDim2.new(0.55, 0, 0.8, 0),
                            BackgroundColor3 = Color3.fromRGB(28,32,48),
                            Text = selected, TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham, AutoButtonColor = false,
                        }, row)
                        Corner(selBtn, 5)
                        local open = false
                        local listFrame = New("Frame", {
                            Parent = row, Position = UDim2.new(0.45, 0, 1, 2),
                            Size = UDim2.new(0.55, 0, 0, 0),
                            BackgroundColor3 = Color3.fromRGB(20,24,36),
                            BorderSizePixel = 0, Visible = false, ZIndex = 200,
                            AutomaticSize = Enum.AutomaticSize.Y,
                        }, row)
                        Corner(listFrame, 5); Stroke(listFrame, Color3.fromRGB(60,60,90), 1, 0.4)
                        New("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 2)}, listFrame)
                        New("UIPadding", {Parent = listFrame, PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4)}, listFrame)
                        for _, opt in ipairs(options) do
                            local ob = New("TextButton", {
                                Parent = listFrame, Size = UDim2.new(1, 0, 0, 20),
                                BackgroundTransparency = 1, Text = opt,
                                TextColor3 = Color3.fromRGB(220,220,235),
                                TextSize = 11, Font = Enum.Font.Gotham,
                                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201,
                            }, listFrame)
                            New("UIPadding", {Parent = ob, PaddingLeft = UDim.new(0, 6)}, ob)
                            ob.MouseButton1Click:Connect(function()
                                selected = opt; selBtn.Text = opt
                                listFrame.Visible = false; open = false
                                if callback then callback(opt) end
                            end)
                        end
                        selBtn.MouseButton1Click:Connect(function()
                            open = not open
                            listFrame.Visible = open
                            if open then
                                listFrame.Size = UDim2.new(0.55, 0, 0, 0)
                                Tween(listFrame, {Size = UDim2.new(0.55, 0, 0, math.min(#options * 22 + 8, 90))}, 0.2)
                            end
                        end)
                    end

                    function SettingsObj:AddColorpicker(text, default, callback)
                        setCount = setCount + 1
                        default = default or Color3.fromRGB(255,255,255)
                        local row = New("Frame", {
                            Parent = SettingsFrame, Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1, LayoutOrder = setCount,
                        }, SettingsFrame)
                        New("TextLabel", {
                            Parent = row, Position = UDim2.new(0, 0, 0, 0),
                            Size = UDim2.new(0.7, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, row)
                        local swatch = New("TextButton", {
                            Parent = row, Position = UDim2.new(0.85, 0, 0.15, 0),
                            Size = UDim2.new(0.15, 0, 0.7, 0),
                            BackgroundColor3 = default, Text = "", AutoButtonColor = false,
                        }, row)
                        Corner(swatch, 4)
                        local hue = 0
                        swatch.MouseButton1Click:Connect(function()
                            hue = (hue + 0.1) % 1
                            local c = Color3.fromHSV(hue, 0.8, 1)
                            swatch.BackgroundColor3 = c
                            if callback then callback(c) end
                        end)
                    end

                    local function closeSF()
                        settingsOpen = false
                        UnregisterPopup(SettingsFrame)
                        Tween(SettingsFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.18)
                        task.wait(0.19)
                        SettingsFrame.Visible = false
                    end

                    SettingsBtn.MouseButton1Click:Connect(function()
                        settingsOpen = not settingsOpen
                        if settingsOpen then
                            CloseAllPopupsExcept(SettingsFrame)
                            SettingsFrame.Visible = true
                            SettingsFrame.BackgroundTransparency = 1
                            SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
                            local h = SFLayout.AbsoluteContentSize.Y + 12
                            task.wait()
                            Tween(SettingsFrame, {
                                BackgroundTransparency = 0.05,
                                Size = UDim2.new(1, 0, 0, h),
                            }, 0.3, Enum.EasingStyle.Back)
                            RegisterPopup(SettingsFrame, closeSF)
                        else
                            closeSF()
                        end
                    end)

                    return SettingsObj
                end

                -- Element helpers
                local function card(h)
                    local c = New("Frame", {
                        Parent = Elements, Size = UDim2.new(1, 0, 0, h),
                        BackgroundColor3 = Color3.fromRGB(28,28,42),
                        BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 4,
                    }, Elements)
                    Corner(c, 8)
                    Stroke(c, Color3.fromRGB(60,60,90), 1, 0.75)
                    return c
                end

                function SectionObj:AddToggle(text, default, callback)
                    elemCount = elemCount + 1
                    local en = default or false
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.7, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local ef = New("Frame", {
                        Parent = c, Position = UDim2.new(0.84, 0, 0.3, 0),
                        Size = UDim2.new(0.11, 0, 0.56, 0),
                        BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0),
                        ZIndex = 5,
                    }, c)
                    Corner(ef, 15); Stroke(ef, Color3.fromRGB(60,60,90), 1, 0.8)
                    local kn = New("Frame", {
                        Parent = ef, Size = UDim2.new(1, 0, 0.9, 0),
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0),
                        BackgroundTransparency = en and 0 or 0.5, ZIndex = 6,
                    }, ef)
                    Corner(kn, 15)
                    New("UIAspectRatioConstraint", {}, kn)

                    local settingsBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.75, 0, 0.15, 0),
                        Size = UDim2.new(0.08, 0, 0.7, 0),
                        BackgroundTransparency = 1, Text = "...",
                        TextColor3 = Color3.fromRGB(180,180,200),
                        TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 6,
                    }, c)

                    local btn = New("TextButton", {
                        Parent = c, Size = UDim2.new(0.75, 0, 1, 0),
                        BackgroundTransparency = 1, Text = "", ZIndex = 5,
                    }, c)

                    local function Set(v)
                        en = v
                        Tween(ef, {BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0)}, 0.25)
                        Tween(kn, {
                            Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0),
                            BackgroundTransparency = en and 0 or 0.5,
                        }, 0.25, Enum.EasingStyle.Back)
                        if callback then callback(en) end
                    end
                    btn.MouseButton1Click:Connect(function() Set(not en) end)

                    local obj = {}
                    function obj:Set(v) Set(v) end
                    function obj:Get() return en end
                    function obj:AddSettings() return MakeSettings(c, "toggle", text) end
                    table.insert(_registeredElements, {key = "toggle_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddColorToggle(text, defaultColor, defaultEnabled, callback)
                    elemCount = elemCount + 1
                    local en = defaultEnabled or false
                    local col = defaultColor or Color3.fromRGB(255,0,0)
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local cpBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.72, 0, 0.25, 0),
                        Size = UDim2.new(0.07, 0, 0.5, 0),
                        BackgroundColor3 = col, Text = "", AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(cpBtn, 5)

                    local ef = New("Frame", {
                        Parent = c, Position = UDim2.new(0.84, 0, 0.3, 0),
                        Size = UDim2.new(0.11, 0, 0.56, 0),
                        BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0),
                        ZIndex = 5,
                    }, c)
                    Corner(ef, 15); Stroke(ef, Color3.fromRGB(60,60,90), 1, 0.8)
                    local kn = New("Frame", {
                        Parent = ef, Size = UDim2.new(1, 0, 0.9, 0),
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0),
                        ZIndex = 6,
                    }, ef)
                    Corner(kn, 15)

                    local btn = New("TextButton", {
                        Parent = c, Size = UDim2.new(0.68, 0, 1, 0),
                        BackgroundTransparency = 1, Text = "", ZIndex = 5,
                    }, c)

                    local function Set(v)
                        en = v
                        Tween(ef, {BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0)}, 0.25)
                        Tween(kn, {Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0)}, 0.25, Enum.EasingStyle.Back)
                        if callback then callback(col, en) end
                    end
                    btn.MouseButton1Click:Connect(function() Set(not en) end)

                    cpBtn.MouseButton1Click:Connect(function()
                        local h = select(1, Color3.toHSV(col))
                        h = (h + 0.1) % 1
                        col = Color3.fromHSV(h, 0.85, 1)
                        cpBtn.BackgroundColor3 = col
                        if callback then callback(col, en) end
                    end)

                    local obj = {}
                    function obj:Set(v) Set(v) end
                    function obj:Get() return en end
                    function obj:SetColor(c) col = c; cpBtn.BackgroundColor3 = c; if callback then callback(col, en) end end
                    function obj:GetColor() return col end
                    function obj:AddSettings() return MakeSettings(c, "colortoggle", text) end
                    table.insert(_registeredElements, {key = "colortoggle_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddToggleColorpicker(text, defaultEnabled, defaultColor, callback, colorCallback)
                    elemCount = elemCount + 1
                    local en = defaultEnabled or false
                    local hue, sat, val = Color3.toHSV(defaultColor or Color3.fromRGB(255,255,255))
                    local col = {hue, sat, val}
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local cpBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.72, 0, 0.25, 0),
                        Size = UDim2.new(0.07, 0, 0.5, 0),
                        BackgroundColor3 = Color3.fromHSV(hue, sat, val),
                        Text = "", AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(cpBtn, 5)

                    local ef = New("Frame", {
                        Parent = c, Position = UDim2.new(0.84, 0, 0.3, 0),
                        Size = UDim2.new(0.11, 0, 0.56, 0),
                        BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0),
                        ZIndex = 5,
                    }, c)
                    Corner(ef, 15); Stroke(ef, Color3.fromRGB(60,60,90), 1, 0.8)
                    local kn = New("Frame", {
                        Parent = ef, Size = UDim2.new(1, 0, 0.9, 0),
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0),
                        ZIndex = 6,
                    }, ef)
                    Corner(kn, 15)

                    local btn = New("TextButton", {
                        Parent = c, Size = UDim2.new(0.68, 0, 1, 0),
                        BackgroundTransparency = 1, Text = "", ZIndex = 5,
                    }, c)

                    local function Set(v)
                        en = v
                        Tween(ef, {BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0)}, 0.25)
                        Tween(kn, {Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0)}, 0.25, Enum.EasingStyle.Back)
                        if colorCallback then colorCallback(en)
                        elseif callback then callback(en, Color3.fromHSV(col[1], col[2], col[3])) end
                    end
                    btn.MouseButton1Click:Connect(function() Set(not en) end)

                    cpBtn.MouseButton1Click:Connect(function()
                        col[1] = (col[1] + 0.1) % 1
                        local rc = Color3.fromHSV(col[1], col[2], col[3])
                        cpBtn.BackgroundColor3 = rc
                        if colorCallback then colorCallback(rc)
                        elseif callback then callback(en, rc) end
                    end)

                    local obj = {}
                    function obj:Set(v) Set(v) end
                    function obj:Get() return en end
                    function obj:SetColor(c)
                        local h,s,v = Color3.toHSV(c); col = {h,s,v}
                        cpBtn.BackgroundColor3 = c
                        if colorCallback then colorCallback(c) end
                    end
                    function obj:GetColor() return Color3.fromHSV(col[1], col[2], col[3]) end
                    function obj:AddSettings() return MakeSettings(c, "togglecolorpicker", text) end
                    table.insert(_registeredElements, {key = "togglecolorpicker_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddSlider(text, min, max, default, callback, suffix)
                    elemCount = elemCount + 1
                    min = min or 0; max = max or 100
                    local val = math.clamp(default or min, min, max)
                    suffix = suffix or ""
                    local c = card(46)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 4),
                        Size = UDim2.new(0.6, 0, 0, 16),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)
                    local valLbl = New("TextLabel", {
                        Parent = c, Position = UDim2.new(0.75, 0, 0, 4),
                        Size = UDim2.new(0.22, 0, 0, 16),
                        BackgroundTransparency = 1, Text = tostring(val) .. suffix,
                        TextColor3 = mainColor, TextSize = 12,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 5,
                    }, c)

                    local settingsBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.72, 0, 0.15, 0),
                        Size = UDim2.new(0.08, 0, 0.7, 0),
                        BackgroundTransparency = 1, Text = "...",
                        TextColor3 = Color3.fromRGB(180,180,200),
                        TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 5,
                    }, c)

                    local bar = New("Frame", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 34),
                        Size = UDim2.new(1, -28, 0, 5),
                        BackgroundColor3 = Color3.fromRGB(50,50,72),
                        BorderSizePixel = 0, ZIndex = 5,
                    }, c)
                    Corner(bar, 3)
                    local rel = (val - min) / (max - min)
                    local fill = New("Frame", {
                        Parent = bar, Size = UDim2.new(rel, 0, 1, 0),
                        BackgroundColor3 = mainColor, BorderSizePixel = 0, ZIndex = 6,
                    }, bar)
                    Corner(fill, 3)

                    local dragging = false
                    local function upd(input)
                        local r = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        val = math.floor(min + (max - min) * r)
                        valLbl.Text = tostring(val) .. suffix
                        fill.Size = UDim2.new(r, 0, 1, 0)
                        if callback then callback(val) end
                    end
                    bar.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1
                        or i.UserInputType == Enum.UserInputType.Touch then
                            dragging = true; upd(i)
                        end
                    end)
                    UIS.InputChanged:Connect(function(i)
                        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                        or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
                    end)
                    UIS.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1
                        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
                    end)

                    local obj = {}
                    function obj:Set(v)
                        val = math.clamp(v, min, max)
                        local r = (val - min) / (max - min)
                        fill.Size = UDim2.new(r, 0, 1, 0)
                        valLbl.Text = tostring(val) .. suffix
                        if callback then callback(val) end
                    end
                    function obj:Get() return val end
                    function obj:AddSettings() return MakeSettings(c, "slider", text) end
                    table.insert(_registeredElements, {key = "slider_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddDropdown(text, options, default, callback)
                    if type(default) == "function" then callback = default; default = nil end
                    elemCount = elemCount + 1
                    options = options or {}
                    local sel = default or options[1]
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local selBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.45, 0, 0.15, 0),
                        Size = UDim2.new(0.47, 0, 0.7, 0),
                        BackgroundColor3 = Color3.fromRGB(32,35,50),
                        Text = sel or "Select",
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 12, Font = Enum.Font.Gotham,
                        AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(selBtn, 6)

                    local settingsBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.93, 0, 0.15, 0),
                        Size = UDim2.new(0.06, 0, 0.7, 0),
                        BackgroundTransparency = 1, Text = "...",
                        TextColor3 = Color3.fromRGB(180,180,200),
                        TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 5,
                    }, c)

                    local listFrame = New("Frame", {
                        Parent = c, Position = UDim2.new(0.45, 0, 1, 3),
                        Size = UDim2.new(0.5, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(20,24,36),
                        BorderSizePixel = 0, Visible = false, ZIndex = 200,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        ClipsDescendants = true,
                    }, c)
                    Corner(listFrame, 6); Stroke(listFrame, Color3.fromRGB(60,60,90), 1, 0.4)
                    New("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 2)}, listFrame)
                    New("UIPadding", {
                        Parent = listFrame,
                        PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
                        PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4),
                    }, listFrame)

                    for _, opt in ipairs(options) do
                        local ob = New("TextButton", {
                            Parent = listFrame, Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1, Text = opt,
                            TextColor3 = Color3.fromRGB(220,220,240),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201,
                        }, listFrame)
                        New("UIPadding", {Parent = ob, PaddingLeft = UDim.new(0, 6)}, ob)
                        ob.MouseButton1Click:Connect(function()
                            sel = opt
                            selBtn.Text = opt
                            listFrame.Visible = false
                            if callback then callback(opt) end
                        end)
                    end

                    local open = false
                    local function close()
                        open = false
                        listFrame.Visible = false
                        UnregisterPopup(listFrame)
                    end
                    selBtn.MouseButton1Click:Connect(function()
                        if open then close()
                        else
                            CloseAllPopupsExcept(listFrame)
                            open = true
                            listFrame.Visible = true
                            listFrame.Size = UDim2.new(0.5, 0, 0, 0)
                            Tween(listFrame, {Size = UDim2.new(0.5, 0, 0, math.min(#options * 24 + 8, 100))}, 0.2)
                            RegisterPopup(listFrame, close)
                        end
                    end)

                    local obj = {}
                    function obj:Set(v, silent)
                        sel = v; selBtn.Text = v
                        if not silent and callback then callback(v) end
                    end
                    function obj:Get() return sel end
                    function obj:AddSettings() return MakeSettings(c, "dropdown", text) end
                    table.insert(_registeredElements, {key = "dropdown_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddDropdownColorpicker(text, options, defaultColor, callback, colorCallback)
                    elemCount = elemCount + 1
                    options = options or {}
                    local sel = options[1]
                    local hue, sat, val = Color3.toHSV(defaultColor or Color3.fromRGB(255,255,255))
                    local col = {hue, sat, val}
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local cpBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.42, 0, 0.25, 0),
                        Size = UDim2.new(0.06, 0, 0.5, 0),
                        BackgroundColor3 = Color3.fromHSV(hue, sat, val),
                        Text = "", AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(cpBtn, 5)

                    local selBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.5, 0, 0.15, 0),
                        Size = UDim2.new(0.47, 0, 0.7, 0),
                        BackgroundColor3 = Color3.fromRGB(32,35,50),
                        Text = sel or "Select",
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 12, Font = Enum.Font.Gotham,
                        AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(selBtn, 6)

                    local listFrame = New("Frame", {
                        Parent = c, Position = UDim2.new(0.5, 0, 1, 3),
                        Size = UDim2.new(0.47, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(20,24,36),
                        BorderSizePixel = 0, Visible = false, ZIndex = 200,
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, c)
                    Corner(listFrame, 6); Stroke(listFrame, Color3.fromRGB(60,60,90), 1, 0.4)
                    New("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 2)}, listFrame)
                    New("UIPadding", {
                        Parent = listFrame,
                        PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
                    }, listFrame)

                    for _, opt in ipairs(options) do
                        local ob = New("TextButton", {
                            Parent = listFrame, Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1, Text = opt,
                            TextColor3 = Color3.fromRGB(220,220,240),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201,
                        }, listFrame)
                        New("UIPadding", {Parent = ob, PaddingLeft = UDim.new(0, 6)}, ob)
                        ob.MouseButton1Click:Connect(function()
                            sel = opt
                            selBtn.Text = opt
                            listFrame.Visible = false
                            if colorCallback then
                                if callback then callback(opt) end
                            elseif callback then
                                callback(opt, Color3.fromHSV(col[1], col[2], col[3]))
                            end
                        end)
                    end

                    local open = false
                    selBtn.MouseButton1Click:Connect(function()
                        open = not open
                        listFrame.Visible = open
                    end)

                    cpBtn.MouseButton1Click:Connect(function()
                        col[1] = (col[1] + 0.1) % 1
                        local rc = Color3.fromHSV(col[1], col[2], col[3])
                        cpBtn.BackgroundColor3 = rc
                        if colorCallback then colorCallback(rc) end
                    end)

                    local obj = {}
                    function obj:Set(v, silent)
                        sel = v; selBtn.Text = v
                        if not silent and colorCallback then
                            if callback then callback(v) end
                        elseif not silent and callback then
                            callback(v, Color3.fromHSV(col[1], col[2], col[3]))
                        end
                    end
                    function obj:Get() return sel end
                    function obj:SetColor(c)
                        local h,s,v = Color3.toHSV(c); col = {h,s,v}
                        cpBtn.BackgroundColor3 = c
                        if colorCallback then colorCallback(c) end
                    end
                    function obj:GetColor() return Color3.fromHSV(col[1], col[2], col[3]) end
                    function obj:AddSettings() return MakeSettings(c, "dropdowncolorpicker", text) end
                    table.insert(_registeredElements, {key = "dropdowncolorpicker_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddColorpicker(text, defaultColor, callback)
                    elemCount = elemCount + 1
                    defaultColor = defaultColor or Color3.fromRGB(255,255,255)
                    local hue, sat, val = Color3.toHSV(defaultColor)
                    local col = {hue, sat, val}
                    local c = card(34)
                    c.LayoutOrder = elemCount

                    New("TextLabel", {
                        Parent = c, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.7, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
                    }, c)

                    local sw = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.84, 0, 0.25, 0),
                        Size = UDim2.new(0.12, 0, 0.5, 0),
                        BackgroundColor3 = defaultColor,
                        Text = "", AutoButtonColor = false, ZIndex = 5,
                    }, c)
                    Corner(sw, 5)

                    local settingsBtn = New("TextButton", {
                        Parent = c, Position = UDim2.new(0.72, 0, 0.15, 0),
                        Size = UDim2.new(0.08, 0, 0.7, 0),
                        BackgroundTransparency = 1, Text = "...",
                        TextColor3 = Color3.fromRGB(180,180,200),
                        TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 5,
                    }, c)

                    sw.MouseButton1Click:Connect(function()
                        col[1] = (col[1] + 0.08) % 1
                        local rc = Color3.fromHSV(col[1], col[2], col[3])
                        sw.BackgroundColor3 = rc
                        if callback then callback(rc) end
                    end)

                    local obj = {}
                    function obj:Set(v)
                        local h,s,v2 = Color3.toHSV(v); col = {h,s,v2}
                        sw.BackgroundColor3 = v
                        if callback then callback(v) end
                    end
                    function obj:Get() return Color3.fromHSV(col[1], col[2], col[3]) end
                    function obj:AddSettings() return MakeSettings(c, "colorpicker", text) end
                    table.insert(_registeredElements, {key = "colorpicker_" .. text, obj = obj})
                    return obj
                end

                function SectionObj:AddAccordion(text)
                    elemCount = elemCount + 1
                    local AccordionFrame = New("Frame", {
                        Parent = Elements, Size = UDim2.new(1, 0, 0, 34),
                        BackgroundColor3 = Color3.fromRGB(28,28,42),
                        BackgroundTransparency = 0.15, BorderSizePixel = 0,
                        LayoutOrder = elemCount, ZIndex = 4,
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, Elements)
                    Corner(AccordionFrame, 8)
                    Stroke(AccordionFrame, Color3.fromRGB(60,60,90), 1, 0.75)

                    local Header2 = New("Frame", {
                        Parent = AccordionFrame, Size = UDim2.new(1, 0, 0, 34),
                        BackgroundTransparency = 1, ZIndex = 5,
                    }, AccordionFrame)
                    New("TextLabel", {
                        Parent = Header2, Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(0.7, 0, 1, 0),
                        BackgroundTransparency = 1, Text = text,
                        TextColor3 = Color3.fromRGB(230,230,245),
                        TextSize = 13, Font = Enum.Font.GothamSemibold,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
                    }, Header2)
                    local arrow = New("ImageLabel", {
                        Parent = Header2, Position = UDim2.new(0.9, 0, 0.25, 0),
                        Size = UDim2.new(0.07, 0, 0.5, 0),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://10709790948",
                        ImageColor3 = Color3.fromRGB(200,200,220),
                        Rotation = -90, ZIndex = 6,
                    }, Header2)
                    local Open = New("TextButton", {
                        Parent = Header2, Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1, Text = "", ZIndex = 7,
                    }, Header2)

                    local Container = New("Frame", {
                        Parent = AccordionFrame, Position = UDim2.new(0, 0, 0, 34),
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1, Visible = false,
                        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 5,
                    }, AccordionFrame)
                    New("UIListLayout", {
                        Parent = Container, Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, Container)
                    New("UIPadding", {
                        Parent = Container,
                        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                    }, Container)

                    local accordOpen = false
                    Open.MouseButton1Click:Connect(function()
                        accordOpen = not accordOpen
                        if accordOpen then
                            Container.Visible = true
                            Tween(arrow, {Rotation = 0}, 0.25)
                        else
                            Tween(arrow, {Rotation = -90}, 0.25)
                            Container.Visible = false
                        end
                    end)

                    local AccordionObj = {}
                    local accCount = 0

                    -- Sub-elements (menggunakan gaya sama seperti element biasa)
                    function AccordionObj:AddToggle(text2, default, callback)
                        accCount = accCount + 1
                        local en = default or false
                        local c = New("Frame", {
                            Parent = Container, Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = Color3.fromRGB(38,40,58),
                            BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            LayoutOrder = accCount, ZIndex = 6,
                        }, Container)
                        Corner(c, 6)
                        New("TextLabel", {
                            Parent = c, Position = UDim2.new(0, 12, 0, 0),
                            Size = UDim2.new(0.7, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text2,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 12, Font = Enum.Font.GothamSemibold,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
                        }, c)
                        local ef = New("Frame", {
                            Parent = c, Position = UDim2.new(0.84, 0, 0.3, 0),
                            Size = UDim2.new(0.11, 0, 0.56, 0),
                            BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0),
                            ZIndex = 7,
                        }, c)
                        Corner(ef, 15)
                        local kn = New("Frame", {
                            Parent = ef, Size = UDim2.new(1, 0, 0.9, 0),
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0),
                            ZIndex = 8,
                        }, ef)
                        Corner(kn, 15)
                        local btn = New("TextButton", {
                            Parent = c, Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1, Text = "", ZIndex = 7,
                        }, c)
                        local function Set(v)
                            en = v
                            Tween(ef, {BackgroundColor3 = en and mainColor or Color3.fromRGB(0,0,0)}, 0.25)
                            Tween(kn, {Position = en and UDim2.new(0.42, 0, 0.05, 0) or UDim2.new(0.08, 0, 0.05, 0)}, 0.25, Enum.EasingStyle.Back)
                            if callback then callback(en) end
                        end
                        btn.MouseButton1Click:Connect(function() Set(not en) end)
                        local obj = {}
                        function obj:Set(v) Set(v) end
                        function obj:Get() return en end
                        table.insert(_registeredElements, {key = "accordion_toggle_" .. text2, obj = obj})
                        return obj
                    end

                    function AccordionObj:AddCheckbox(text2, default, callback)
                        accCount = accCount + 1
                        local en = default or false
                        local c = New("Frame", {
                            Parent = Container, Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = Color3.fromRGB(38,40,58),
                            BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            LayoutOrder = accCount, ZIndex = 6,
                        }, Container)
                        Corner(c, 6)
                        New("TextLabel", {
                            Parent = c, Position = UDim2.new(0.15, 0, 0, 0),
                            Size = UDim2.new(0.85, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text2,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 12, Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
                        }, c)
                        local box = New("Frame", {
                            Parent = c, Position = UDim2.new(0.03, 0, 0.25, 0),
                            Size = UDim2.new(0, 14, 0, 14),
                            BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60),
                            ZIndex = 7,
                        }, c)
                        Corner(box, 3)
                        local btn = New("TextButton", {
                            Parent = c, Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1, Text = "", ZIndex = 7,
                        }, c)
                        local function Set(v)
                            en = v
                            Tween(box, {BackgroundColor3 = en and mainColor or Color3.fromRGB(40,40,60)}, 0.2)
                            if callback then callback(en) end
                        end
                        btn.MouseButton1Click:Connect(function() Set(not en) end)
                        local obj = {}
                        function obj:Set(v) Set(v) end
                        function obj:Get() return en end
                        table.insert(_registeredElements, {key = "accordion_checkbox_" .. text2, obj = obj})
                        return obj
                    end

                    function AccordionObj:AddSlider(text2, min, max, default, callback, suffix)
                        accCount = accCount + 1
                        min = min or 0; max = max or 100
                        local val = math.clamp(default or min, min, max)
                        suffix = suffix or ""
                        local c = New("Frame", {
                            Parent = Container, Size = UDim2.new(1, 0, 0, 46),
                            BackgroundColor3 = Color3.fromRGB(38,40,58),
                            BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            LayoutOrder = accCount, ZIndex = 6,
                        }, Container)
                        Corner(c, 6)
                        New("TextLabel", {
                            Parent = c, Position = UDim2.new(0, 12, 0, 4),
                            Size = UDim2.new(0.6, 0, 0, 16),
                            BackgroundTransparency = 1, Text = text2,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 12, Font = Enum.Font.GothamSemibold,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
                        }, c)
                        local valLbl = New("TextLabel", {
                            Parent = c, Position = UDim2.new(0.75, 0, 0, 4),
                            Size = UDim2.new(0.22, 0, 0, 16),
                            BackgroundTransparency = 1, Text = tostring(val) .. suffix,
                            TextColor3 = mainColor, TextSize = 11,
                            Font = Enum.Font.GothamBold,
                            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
                        }, c)
                        local bar = New("Frame", {
                            Parent = c, Position = UDim2.new(0, 12, 0, 34),
                            Size = UDim2.new(1, -24, 0, 5),
                            BackgroundColor3 = Color3.fromRGB(50,50,72), ZIndex = 7,
                        }, c)
                        Corner(bar, 3)
                        local rel = (val - min) / (max - min)
                        local fill = New("Frame", {
                            Parent = bar, Size = UDim2.new(rel, 0, 1, 0),
                            BackgroundColor3 = mainColor, ZIndex = 8,
                        }, bar)
                        Corner(fill, 3)
                        local dragging = false
                        local function upd(input)
                            local r = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            val = math.floor(min + (max - min) * r)
                            valLbl.Text = tostring(val) .. suffix
                            fill.Size = UDim2.new(r, 0, 1, 0)
                            if callback then callback(val) end
                        end
                        bar.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                            or i.UserInputType == Enum.UserInputType.Touch then
                                dragging = true; upd(i)
                            end
                        end)
                        UIS.InputChanged:Connect(function(i)
                            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                            or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
                        end)
                        UIS.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1
                            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
                        end)
                        local obj = {}
                        function obj:Set(v)
                            val = math.clamp(v, min, max)
                            local r = (val - min) / (max - min)
                            fill.Size = UDim2.new(r, 0, 1, 0)
                            valLbl.Text = tostring(val) .. suffix
                            if callback then callback(val) end
                        end
                        function obj:Get() return val end
                        table.insert(_registeredElements, {key = "accordion_slider_" .. text2, obj = obj})
                        return obj
                    end

                    function AccordionObj:AddDropdown(text2, options, default, callback)
                        if type(default) == "function" then callback = default; default = nil end
                        accCount = accCount + 1
                        options = options or {}
                        local sel = default or options[1]
                        local c = New("Frame", {
                            Parent = Container, Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = Color3.fromRGB(38,40,58),
                            BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            LayoutOrder = accCount, ZIndex = 6,
                        }, Container)
                        Corner(c, 6)
                        New("TextLabel", {
                            Parent = c, Position = UDim2.new(0, 12, 0, 0),
                            Size = UDim2.new(0.4, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text2,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 12, Font = Enum.Font.GothamSemibold,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
                        }, c)
                        local selBtn = New("TextButton", {
                            Parent = c, Position = UDim2.new(0.5, 0, 0.15, 0),
                            Size = UDim2.new(0.45, 0, 0.7, 0),
                            BackgroundColor3 = Color3.fromRGB(28,32,48),
                            Text = sel or "Select", TextColor3 = Color3.fromRGB(220,220,240),
                            TextSize = 11, Font = Enum.Font.Gotham,
                            AutoButtonColor = false, ZIndex = 7,
                        }, c)
                        Corner(selBtn, 5)
                        local listFrame = New("Frame", {
                            Parent = c, Position = UDim2.new(0.5, 0, 1, 3),
                            Size = UDim2.new(0.45, 0, 0, 0),
                            BackgroundColor3 = Color3.fromRGB(20,24,36),
                            BorderSizePixel = 0, Visible = false, ZIndex = 200,
                            AutomaticSize = Enum.AutomaticSize.Y,
                        }, c)
                        Corner(listFrame, 5); Stroke(listFrame, Color3.fromRGB(60,60,90), 1, 0.4)
                        New("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 2)}, listFrame)
                        for _, opt in ipairs(options) do
                            local ob = New("TextButton", {
                                Parent = listFrame, Size = UDim2.new(1, 0, 0, 20),
                                BackgroundTransparency = 1, Text = opt,
                                TextColor3 = Color3.fromRGB(220,220,240),
                                TextSize = 11, Font = Enum.Font.Gotham,
                                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201,
                            }, listFrame)
                            New("UIPadding", {Parent = ob, PaddingLeft = UDim.new(0, 6)}, ob)
                            ob.MouseButton1Click:Connect(function()
                                sel = opt; selBtn.Text = opt
                                listFrame.Visible = false
                                if callback then callback(opt) end
                            end)
                        end
                        selBtn.MouseButton1Click:Connect(function()
                            listFrame.Visible = not listFrame.Visible
                        end)
                        local obj = {}
                        function obj:Set(v, silent) sel = v; selBtn.Text = v; if not silent and callback then callback(v) end end
                        function obj:Get() return sel end
                        table.insert(_registeredElements, {key = "accordion_dropdown_" .. text2, obj = obj})
                        return obj
                    end

                    function AccordionObj:AddColorpicker(text2, defaultColor, callback)
                        accCount = accCount + 1
                        defaultColor = defaultColor or Color3.fromRGB(255,255,255)
                        local hue, sat, val = Color3.toHSV(defaultColor)
                        local col = {hue, sat, val}
                        local c = New("Frame", {
                            Parent = Container, Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = Color3.fromRGB(38,40,58),
                            BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            LayoutOrder = accCount, ZIndex = 6,
                        }, Container)
                        Corner(c, 6)
                        New("TextLabel", {
                            Parent = c, Position = UDim2.new(0, 12, 0, 0),
                            Size = UDim2.new(0.7, 0, 1, 0),
                            BackgroundTransparency = 1, Text = text2,
                            TextColor3 = Color3.fromRGB(220,220,235),
                            TextSize = 12, Font = Enum.Font.GothamSemibold,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
                        }, c)
                        local sw = New("TextButton", {
                            Parent = c, Position = UDim2.new(0.84, 0, 0.25, 0),
                            Size = UDim2.new(0.12, 0, 0.5, 0),
                            BackgroundColor3 = defaultColor, Text = "",
                            AutoButtonColor = false, ZIndex = 7,
                        }, c)
                        Corner(sw, 5)
                        sw.MouseButton1Click:Connect(function()
                            col[1] = (col[1] + 0.08) % 1
                            local rc = Color3.fromHSV(col[1], col[2], col[3])
                            sw.BackgroundColor3 = rc
                            if callback then callback(rc) end
                        end)
                        local obj = {}
                        function obj:Set(v)
                            local h,s,v2 = Color3.toHSV(v); col = {h,s,v2}
                            sw.BackgroundColor3 = v
                            if callback then callback(v) end
                        end
                        function obj:Get() return Color3.fromHSV(col[1], col[2], col[3]) end
                        table.insert(_registeredElements, {key = "accordion_colorpicker_" .. text2, obj = obj})
                        return obj
                    end

                    return AccordionObj
                end

                return SectionObj
            end

            -- SubTab support
            function TabObj:AddSubTab(name, icon)
                local stIndex = #subTabs + 1
                -- (disini kita buat subTab container sederhana: hanya menambahkan Section di tab yang sama)
                return TabObj -- Fallback: sub tab tidak dibuat kompleks
            end

            return TabObj
        end

        function WindowObj:AddTab(name, icon)
            return createTab(name, icon)
        end

        function WindowObj:AddTabLabel(text)
            tabOrder = tabOrder + 1
            local lbl = New("TextLabel", {
                Parent = TabHolder, Size = UDim2.new(0.8, 0, 0, 14),
                BackgroundTransparency = 1, Text = text,
                TextColor3 = Color3.fromRGB(75,78,98),
                TextSize = 11, Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = tabOrder, ZIndex = 3,
            }, TabHolder)
            return lbl
        end

        -- Toggle Button (Close/Open dengan H key)
        local ToggleBtn = New("TextButton", {
            Name = "ToggleBtn",
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(0, 100, 0, 28),
            BackgroundColor3 = Color3.fromRGB(16,19,28),
            BorderSizePixel = 0,
            Text = "Close [H]",
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 12, Font = Enum.Font.GothamSemibold,
            AutoButtonColor = false, ZIndex = 999,
            Visible = false,
        }, ScreenGui)
        Corner(ToggleBtn, 6); Stroke(ToggleBtn, Color3.fromRGB(80,90,150), 1, 0.5)

        local guiOpen = true
        local function toggleGui()
            guiOpen = not guiOpen
            ToggleBtn.Text = guiOpen and "Close [H]" or "Open [H]"
            if guiOpen then
                MainFrame.Visible = true
                MainFrame.BackgroundTransparency = 1
                Tween(MainFrame, {BackgroundTransparency = 0.15}, 0.2)
            else
                Tween(MainFrame, {BackgroundTransparency = 1}, 0.2)
                task.delay(0.21, function() MainFrame.Visible = false end)
            end
        end
        ToggleBtn.MouseButton1Click:Connect(toggleGui)
        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.H then toggleGui() end
        end)

        -- Window Settings (main color, scale, dll)
        local function applyColor(c)
            mainColor = c
            colorBtn.BackgroundColor3 = c
            for _, t in ipairs(tabs) do
                if t == tabs[activeTabIndex] then
                    t.icon.ImageColor3 = c
                end
            end
            for _, e in ipairs(_registeredElements) do
                if e.key and e.key:match("^toggle") then
                    local ok, inst = pcall(function() return e.obj end)
                    -- (skip: terlalu kompleks untuk direcolor semua)
                end
            end
        end

        local cpOpen = false
        colorBtn.MouseButton1Click:Connect(function()
            cpOpen = not cpOpen
            if cpOpen then
                -- Simple incremental hue changer; user bisa klik berulang
                hue = (hue + 0.1) % 1
                applyColor(Color3.fromHSV(hue, sat, val))
            end
        end)

        -- Draggable
        MakeDraggable(MainFrame, MainFrame)

        return WindowObj
    end

    function Library:Destroy()
        ScreenGui:Destroy()
    end

    -- Open button show
    function Library:ShowOpen()
        openBtn.Visible = true
        openBtn.Size = UDim2.new(0, 0, 0, 0)
        Tween(openBtn, {Size = UDim2.new(0, 58, 0, 58)}, 0.4)
        -- Wire toggle ke openBtn
        openBtn.MouseButton1Click:Connect(function()
            local mf = ScreenGui:FindFirstChild("MainFrame")
            if not mf then return end
            if mf.Visible then
                Tween(mf, {BackgroundTransparency = 1}, 0.2)
                task.delay(0.21, function() mf.Visible = false end)
            else
                mf.Visible = true
                mf.BackgroundTransparency = 1
                Tween(mf, {BackgroundTransparency = 0.15}, 0.25)
            end
        end)
    end

    return Library
end)()

-- AUTO-START KEY SYSTEM jika dijalankan tanpa usage
-- Usage akan memanggil CreateWindow / AddWindow sendiri

return Turtle