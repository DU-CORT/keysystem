
-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "albert2026",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "zyon"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

-- GUI independente: uma caixa de key e dois botoes. Sem Fluent.
local CONFIG = {
    GetKeyURL = "", -- Cole aqui o link HTTPS do encurtador.
    ValidateKey = nil, -- function(key) return true/false, "mensagem" end
    OnVerified = nil, -- Acao futura apos validar a key.
}

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local player = assert(Players.LocalPlayer, "Execute no cliente Roblox.")
local env = type(getgenv) == "function" and getgenv() or _G
if type(env.UniversalKeyCleanup) == "function" then pcall(env.UniversalKeyCleanup) end
local connections, closed, busy = {}, false, false
local function connect(event, callback)
    connections[#connections+1] = event:Connect(callback)
end
local function make(class, parent, properties)
    local object = Instance.new(class)
    for name,value in pairs(properties) do object[name] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    make("UICorner",object,{CornerRadius=UDim.new(0,radius)})
end
local screen = make("ScreenGui",player:WaitForChild("PlayerGui"),{
    Name="UniversalKeyGUI",ResetOnSpawn=false,IgnoreGuiInset=true,
    DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})
local function cleanup()
    if closed then return end
    closed=true
    for _,connection in ipairs(connections) do connection:Disconnect() end
    if env.UniversalKeyCleanup==cleanup then env.UniversalKeyCleanup=nil end
    screen:Destroy()
end
env.UniversalKeyCleanup=cleanup
connect(screen.Destroying,cleanup)
local panel=make("Frame",screen,{
    Name="KeyPanel",Size=UDim2.fromOffset(420,270),Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(9,8,13),BorderSizePixel=0,
})
round(panel,14)
make("UIStroke",panel,{Color=Color3.fromRGB(88,52,127),Thickness=1})
local scale=make("UIScale",panel,{Scale=1})
local function fit()
    local camera=workspace.CurrentCamera
    if camera then
        scale.Scale=math.max(0.1,math.min(1,(camera.ViewportSize.X-24)/420,(camera.ViewportSize.Y-24)/270))
        panel.Position=UDim2.fromScale(0.5,0.5)
    end
end
local cameraConnection
local function watchCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    if workspace.CurrentCamera then
        cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
        connections[#connections+1]=cameraConnection
    end
    fit()
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"),watchCamera)
watchCamera()
local header=make("TextLabel",panel,{
    Text="KEY SYSTEM",Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.fromRGB(190,148,255),
    Position=UDim2.fromOffset(24,16),Size=UDim2.new(1,-48,0,38),
    TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Active=true,
})
make("Frame",panel,{Position=UDim2.fromOffset(24,66),Size=UDim2.new(1,-48,0,1),
    BackgroundColor3=Color3.fromRGB(65,39,92),BorderSizePixel=0})
local field=make("TextBox",panel,{
    Name="KeyInput",Text="",PlaceholderText="Cole sua key aqui",ClearTextOnFocus=false,
    Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(241,235,250),
    PlaceholderColor3=Color3.fromRGB(137,125,153),TextXAlignment=Enum.TextXAlignment.Left,
    Position=UDim2.fromOffset(24,88),Size=UDim2.new(1,-48,0,48),
    BackgroundColor3=Color3.fromRGB(3,3,6),BorderSizePixel=0,
})
round(field,8)
make("UIPadding",field,{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
local border=make("UIStroke",field,{Color=Color3.fromRGB(58,43,75),Thickness=1})
connect(field.Focused,function() border.Color=Color3.fromRGB(166,106,248) end)
connect(field.FocusLost,function() border.Color=Color3.fromRGB(58,43,75) end)
local function button(text, x, primary)
    local base=primary and Color3.fromRGB(133,70,218) or Color3.fromRGB(31,21,45)
    local object=make("TextButton",panel,{
        Text=text,Font=Enum.Font.GothamMedium,TextSize=14,TextColor3=Color3.fromRGB(247,241,255),
        Position=UDim2.fromOffset(x,152),Size=UDim2.fromOffset(178,44),
        BackgroundColor3=base,BorderSizePixel=0,AutoButtonColor=false,
    })
    round(object,8)
    make("UIStroke",object,{Color=Color3.fromRGB(109,65,158),Thickness=1})
    connect(object.MouseEnter,function() object.BackgroundColor3=Color3.fromRGB(109,65,158) end)
    connect(object.MouseLeave,function() object.BackgroundColor3=base end)
    return object
end
local getButton=button("Get Key",24,false)
local checkButton=button("Check Key",218,true)
local status=make("TextLabel",panel,{
    Text="",Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,
    TextColor3=Color3.fromRGB(183,168,203),BackgroundTransparency=1,
    Position=UDim2.fromOffset(24,208),Size=UDim2.new(1,-48,0,46),
})
local function message(text)
    if not closed then status.Text=text end
end
connect(getButton.Activated,function()
    local url=CONFIG.GetKeyURL
    if type(url)~="string" or not url:match("^https://[^%s]+$") then
        message("Preencha GetKeyURL no inicio do script.");return
    end
    if type(setclipboard)=="function" and pcall(setclipboard,url) then
        message("Link copiado. Abra no navegador e gere sua key.")
    else
        message("Abra no navegador: "..url)
    end
end)
connect(checkButton.Activated,function()
    if busy then message("Aguarde a verificacao.");return end
    local key=field.Text:match("^%s*(.-)%s*$")
    if key=="" then message("Cole sua key no campo acima.");return end
    if #key>512 then message("A key informada e muito longa.");return end
    if type(CONFIG.ValidateKey)~="function" then message("Configure ValidateKey para conectar a validacao ao seu site.");return end
    busy=true;message("Verificando...")
    task.spawn(function()
        local ok,valid,detail=pcall(CONFIG.ValidateKey,key)
        busy=false
        if closed then return end
        if field.Text:match("^%s*(.-)%s*$")~=key then message("Key alterada. Clique em Check Key novamente.");return end
        if not ok then message("Falha ao consultar o servico. Tente novamente.");return end
        if valid~=true then message(type(detail)=="string" and detail or "Key invalida ou expirada.");return end
        message("Key validada com sucesso.")
        if type(CONFIG.OnVerified)=="function" then
            local activated=pcall(CONFIG.OnVerified)
            if not activated then message("Key valida, mas houve uma falha ao abrir o painel.");end
        end
    end)
end)
local drag
connect(header.InputBegan,function(event)
    if event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch then
        drag={event=event,start=event.Position,origin=panel.Position}
    end
end)
connect(Input.InputChanged,function(event)
    if not drag then return end
    if event~=drag.event and not (event.UserInputType==Enum.UserInputType.MouseMovement and drag.event.UserInputType==Enum.UserInputType.MouseButton1) then return end
    local camera=workspace.CurrentCamera
    if not camera then return end
    local view=camera.ViewportSize
    local x=view.X*drag.origin.X.Scale+drag.origin.X.Offset+event.Position.X-drag.start.X
    local y=view.Y*drag.origin.Y.Scale+drag.origin.Y.Offset+event.Position.Y-drag.start.Y
    panel.Position=UDim2.fromOffset(math.clamp(x,210*scale.Scale,view.X-210*scale.Scale),math.clamp(y,135*scale.Scale,view.Y-135*scale.Scale))
end)
connect(Input.InputEnded,function(event)
    if drag and (event==drag.event or event.UserInputType==Enum.UserInputType.MouseButton1 and drag.event.UserInputType==Enum.UserInputType.MouseButton1) then drag=nil end
end)
connect(Input.WindowFocusReleased,function() drag=nil end)
connect(Input.InputBegan,function(event,processed)
    if event.KeyCode==Enum.KeyCode.RightShift and not processed and not Input:GetFocusedTextBox() then
        panel.Visible=not panel.Visible;drag=nil
    end
end)
