-- Fronteira do Brasil - Rayfield UI
-- Versão com Hitbox por Time

-- Verificar se já está rodando
if _G.FronteiraBrasilLoaded then
    warn("Script já está em execução!")
    return
end
_G.FronteiraBrasilLoaded = true

-- Carregar Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Erro ao carregar Rayfield UI")
    return
end

-- Criar janela
local Window = Rayfield:CreateWindow({
   Name = "Fronteira do Brasil",
   LoadingTitle = "Carregando Script",
   LoadingSubtitle = "by Comunidade",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "FronteiraBrasil"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- ========================================
-- VARIÁVEIS GLOBAIS
-- ========================================
local HeadSize = 50
local HitboxEnabled = false
local hitboxConnection = nil

local NoclipEnabled = false
local noclipConnection = nil

local SpeedEnabled = false
local SpeedValue = 2
local speedConnection = nil

local JumpEnabled = false
local JumpValue = 2
local jumpConnection = nil

local FarmEnabled = false
local AntiAFKEnabled = false
local farmPosition = Vector3.new(243.30, 47.24, 81.19)  -- Posição de XP em dobro
local safePosition = Vector3.new(243.30, -500, 81.19)  -- Posição segura (embaixo do mapa)
local farmConnection = nil
local antiAfkConnection = nil

-- ========================================
-- FUNÇÕES DE HITBOX
-- ========================================
local function UpdateHitbox()
   if HitboxEnabled then
      local localPlayer = game:GetService('Players').LocalPlayer
      
      for _, v in pairs(game:GetService('Players'):GetPlayers()) do
         if v.Name ~= localPlayer.Name and v.Character then
            pcall(function()
               local hrp = v.Character:FindFirstChild("HumanoidRootPart")
               if hrp then
                  -- Verificar se é do mesmo time
                  local isTeammate = false
                  if localPlayer.Team and v.Team then
                     if localPlayer.Team == v.Team then
                        isTeammate = true
                     end
                  end
                  
                  -- Só aplicar hitbox se NÃO for do mesmo time
                  if not isTeammate then
                     local teamColor = BrickColor.new("Really blue")
                     
                     if v.Team then
                        teamColor = v.Team.TeamColor
                     end
                     
                     hrp.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                     hrp.Transparency = 0.7
                     hrp.BrickColor = teamColor
                     hrp.Material = Enum.Material.Neon
                     hrp.CanCollide = false
                  else
                     -- Resetar aliados
                     hrp.Size = Vector3.new(2, 2, 1)
                     hrp.Transparency = 1
                     hrp.CanCollide = true
                  end
               end
            end)
         end
      end
   end
end

local function ClearHitbox()
   for _, v in pairs(game:GetService('Players'):GetPlayers()) do
      if v.Name ~= game:GetService('Players').LocalPlayer.Name and v.Character then
         pcall(function()
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
               hrp.Size = Vector3.new(2, 2, 1)
               hrp.Transparency = 1
               hrp.CanCollide = true
            end
         end)
      end
   end
end

-- ========================================
-- ABA: IMIGRANTE
-- ========================================
local ImigranteTab = Window:CreateTab("👤 Imigrante", nil)
local ImigranteSection = ImigranteTab:CreateSection("Percurso Automático")

local ImigranteButton = ImigranteTab:CreateButton({
   Name = "Pegar arma imigrante",
   Callback = function()
      pcall(function()
         local player = game.Players.LocalPlayer
         local character = player.Character or player.CharacterAdded:Wait()
         local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
         
         humanoidRootPart.CFrame = CFrame.new(117.29, 12.99, 193.24)
         task.wait(1)
         
         local vim = game:GetService("VirtualInputManager")
         vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
         task.wait(0.1)
         vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
         task.wait(0.5)
         
         local destino = Vector3.new(222.76, 22.42, 7.44)
         local camera = workspace.CurrentCamera
         local direcao = camera.CFrame.LookVector
         direcao = Vector3.new(direcao.X, 0, direcao.Z).Unit
         local destinoFinal = destino - (direcao * 3)
         
         humanoidRootPart.CFrame = CFrame.new(destinoFinal)
         
         Rayfield:Notify({
            Title = "Imigrante",
            Content = "Percurso concluído!",
            Duration = 3,
            Image = nil
         })
      end)
   end
})

-- ========================================
-- ABA: COMBATE
-- ========================================
local CombateTab = Window:CreateTab("⚔️ Combate", nil)
local CombateSection = CombateTab:CreateSection("Configurações de Hitbox")

local HitboxToggle = CombateTab:CreateToggle({
   Name = "Ativar Hitbox (Só Inimigos)",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      HitboxEnabled = Value
      
      if hitboxConnection then
         hitboxConnection:Disconnect()
         hitboxConnection = nil
      end
      
      if Value then
         hitboxConnection = game:GetService("RunService").RenderStepped:Connect(function()
            UpdateHitbox()
         end)
         Rayfield:Notify({
            Title = "Hitbox",
            Content = "Hitbox ATIVADA (Cores por Time)",
            Duration = 2,
            Image = nil
         })
      else
         ClearHitbox()
         Rayfield:Notify({
            Title = "Hitbox",
            Content = "Hitbox DESATIVADA",
            Duration = 2,
            Image = nil
         })
      end
   end
})

local HitboxSlider = CombateTab:CreateSlider({
   Name = "Tamanho da Hitbox",
   Range = {10, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 50,
   Flag = "HitboxSize",
   Callback = function(Value)
      HeadSize = Value
   end
})

-- ========================================
-- ABA: PERSONAGEM
-- ========================================
local PersonagemTab = Window:CreateTab("🏃 Personagem", nil)
local MovimentoSection = PersonagemTab:CreateSection("Movimentação")

local NoclipToggle = PersonagemTab:CreateToggle({
   Name = "Atravessar Paredes (NoClip)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      NoclipEnabled = Value
      
      if noclipConnection then
         noclipConnection:Disconnect()
         noclipConnection = nil
      end
      
      if Value then
         noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            pcall(function()
               if NoclipEnabled and game.Players.LocalPlayer.Character then
                  for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                     if part:IsA("BasePart") then
                        part.CanCollide = false
                     end
                  end
               end
            end)
         end)
         Rayfield:Notify({
            Title = "NoClip",
            Content = "NoClip ATIVADO",
            Duration = 2,
            Image = nil
         })
      else
         Rayfield:Notify({
            Title = "NoClip",
            Content = "NoClip DESATIVADO",
            Duration = 2,
            Image = nil
         })
      end
   end
})

local SpeedToggle = PersonagemTab:CreateToggle({
   Name = "Velocidade Aumentada",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      SpeedEnabled = Value
      
      if speedConnection then
         speedConnection:Disconnect()
         speedConnection = nil
      end
      
      if Value then
         speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
            pcall(function()
               if SpeedEnabled then
                  local char = game.Players.LocalPlayer.Character
                  if char then
                     local hum = char:FindFirstChild("Humanoid")
                     if hum then
                        hum.WalkSpeed = 16 * SpeedValue
                     end
                  end
               end
            end)
         end)
         Rayfield:Notify({
            Title = "Velocidade",
            Content = "Velocidade ATIVADA",
            Duration = 2,
            Image = nil
         })
      else
         pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char then
               local hum = char:FindFirstChild("Humanoid")
               if hum then
                  hum.WalkSpeed = 16
               end
            end
         end)
         Rayfield:Notify({
            Title = "Velocidade",
            Content = "Velocidade DESATIVADA",
            Duration = 2,
            Image = nil
         })
      end
   end
})

local SpeedSlider = PersonagemTab:CreateSlider({
   Name = "Multiplicador de Velocidade",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "x",
   CurrentValue = 2,
   Flag = "SpeedValue",
   Callback = function(Value)
      SpeedValue = Value
   end
})

local JumpToggle = PersonagemTab:CreateToggle({
   Name = "Pulo Alto",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
      JumpEnabled = Value
      
      if jumpConnection then
         jumpConnection:Disconnect()
         jumpConnection = nil
      end
      
      if Value then
         jumpConnection = game:GetService("RunService").RenderStepped:Connect(function()
            pcall(function()
               if JumpEnabled then
                  local char = game.Players.LocalPlayer.Character
                  if char then
                     local hum = char:FindFirstChild("Humanoid")
                     if hum then
                        hum.JumpPower = 50 * JumpValue
                     end
                  end
               end
            end)
         end)
         Rayfield:Notify({
            Title = "Pulo",
            Content = "Pulo Alto ATIVADO",
            Duration = 2,
            Image = nil
         })
      else
         pcall(function()
            local char = game.Players.LocalPlayer.Character
            if char then
               local hum = char:FindFirstChild("Humanoid")
               if hum then
                  hum.JumpPower = 50
               end
            end
         end)
         Rayfield:Notify({
            Title = "Pulo",
            Content = "Pulo Alto DESATIVADO",
            Duration = 2,
            Image = nil
         })
      end
   end
})

local JumpSlider = PersonagemTab:CreateSlider({
   Name = "Força do Pulo",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "x",
   CurrentValue = 2,
   Flag = "JumpValue",
   Callback = function(Value)
      JumpValue = Value
   end
})

-- ========================================
-- ABA: FARM EXÉRCITO
-- ========================================
local FarmTab = Window:CreateTab("💰 Farm Exército", nil)
local FarmSection = FarmTab:CreateSection("Farm Automático de XP")

local function StartFarm()
   if FarmEnabled then return end
   FarmEnabled = true
   
   task.spawn(function()
      pcall(function()
         local player = game.Players.LocalPlayer
         local character = player.Character or player.CharacterAdded:Wait()
         local hrp = character:WaitForChild("HumanoidRootPart")
         local hum = character:WaitForChild("Humanoid")
         
         -- Desativar colisão de todas as partes
         for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
         
         -- Mover corpo para posição segura (invisível)
         for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
               part.CFrame = CFrame.new(safePosition)
            end
         end
         
         -- HumanoidRootPart fica na posição de XP em dobro
         local sudeste = CFrame.Angles(0, math.rad(135), 0)
         hrp.CFrame = CFrame.new(farmPosition) * sudeste
         
         task.wait(1)
         
         hum.WalkSpeed = 0
         hum.JumpPower = 0
         
         Rayfield:Notify({
            Title = "Farm XP",
            Content = "Farm Invisível INICIADO!",
            Duration = 3,
            Image = nil
         })
         
         -- Manter HumanoidRootPart no local de XP
         farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function()
               if FarmEnabled and hrp then
                  local offset = math.sin(tick() * 1.5) * 0.05
                  hrp.CFrame = CFrame.new(farmPosition) * CFrame.new(offset, 0, offset)
                  
                  -- Manter outras partes escondidas
                  for _, part in pairs(character:GetChildren()) do
                     if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CFrame = CFrame.new(safePosition)
                     end
                  end
               end
            end)
         end)
         
         -- Equipar e desequipar Continência
         while FarmEnabled do
            pcall(function()
               local backpack = player.Backpack
               local continencia = backpack:FindFirstChild("Continência")
               
               if continencia then
                  hum:EquipTool(continencia)
                  task.wait(0.5)
                  hum:UnequipTools()
                  task.wait(0.5)
               else
                  task.wait(0.5)
               end
            end)
         end
      end)
   end)
end

local function StopFarm()
   if not FarmEnabled then return end
   FarmEnabled = false
   
   if farmConnection then
      farmConnection:Disconnect()
      farmConnection = nil
   end
   
   pcall(function()
      local char = game.Players.LocalPlayer.Character
      if char then
         local hum = char:FindFirstChild("Humanoid")
         local hrp = char:FindFirstChild("HumanoidRootPart")
         
         if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum:UnequipTools()
         end
         
         -- Restaurar corpo normal
         if hrp then
            for _, part in pairs(char:GetChildren()) do
               if part:IsA("BasePart") then
                  part.CanCollide = true
                  if part.Name ~= "HumanoidRootPart" then
                     part.CFrame = hrp.CFrame
                  end
               end
            end
         end
      end
   end)
   
   Rayfield:Notify({
      Title = "Farm XP",
      Content = "Farm PARADO",
      Duration = 2,
      Image = nil
   })
end

local AntiAFKToggle = FarmTab:CreateToggle({
   Name = "Anti-AFK (Prevenir Kick)",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(Value)
      AntiAFKEnabled = Value
      
      if antiAfkConnection then
         antiAfkConnection:Disconnect()
         antiAfkConnection = nil
      end
      
      if Value then
         antiAfkConnection = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function()
               local vu = game:GetService("VirtualUser")
               vu:CaptureController()
               vu:ClickButton2(Vector2.new())
            end)
         end)
         Rayfield:Notify({
            Title = "Anti-AFK",
            Content = "Anti-AFK ATIVADO",
            Duration = 2,
            Image = nil
         })
      else
         Rayfield:Notify({
            Title = "Anti-AFK",
            Content = "Anti-AFK DESATIVADO",
            Duration = 2,
            Image = nil
         })
      end
   end
})

local FarmToggle = FarmTab:CreateToggle({
   Name = "Ativar Farm XP Automático",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
      if Value then
         StartFarm()
      else
         StopFarm()
      end
   end
})

-- ========================================
-- ABA: COORDENADAS
-- ========================================
local CoordsTab = Window:CreateTab("📍 Coordenadas", nil)
local CoordsSection = CoordsTab:CreateSection("Posição Atual")

local coordsLabel = CoordsTab:CreateLabel("Carregando...")

task.spawn(function()
   while task.wait(0.5) do
      pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
               local pos = hrp.Position
               coordsLabel:Set(string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z))
            end
         end
      end)
   end
end)

local CopyButton = CoordsTab:CreateButton({
   Name = "Copiar Coordenadas",
   Callback = function()
      pcall(function()
         local char = game.Players.LocalPlayer.Character
         if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
               local pos = hrp.Position
               local coords = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
               setclipboard(coords)
               Rayfield:Notify({
                  Title = "Coordenadas",
                  Content = "Copiado!",
                  Duration = 2,
                  Image = nil
               })
            end
         end
      end)
   end
})

-- ========================================
-- ABA: CONFIGURAÇÕES
-- ========================================
local SettingsTab = Window:CreateTab("⚙️ Configurações", nil)
local ConfigSection = SettingsTab:CreateSection("Controles")

local ResetButton = SettingsTab:CreateButton({
   Name = "Resetar Todas as Configurações",
   Callback = function()
      pcall(function()
         FarmEnabled = false
         HitboxEnabled = false
         NoclipEnabled = false
         SpeedEnabled = false
         JumpEnabled = false
         AntiAFKEnabled = false
         
         if farmConnection then farmConnection:Disconnect() end
         if hitboxConnection then hitboxConnection:Disconnect() end
         if noclipConnection then noclipConnection:Disconnect() end
         if antiAfkConnection then antiAfkConnection:Disconnect() end
         if speedConnection then speedConnection:Disconnect() end
         if jumpConnection then jumpConnection:Disconnect() end
         
         local char = game.Players.LocalPlayer.Character
         if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
               hum.WalkSpeed = 16
               hum.JumpPower = 50
               hum:UnequipTools()
            end
         end
         
         ClearHitbox()
         
         Rayfield:Notify({
            Title = "Sistema",
            Content = "Configurações resetadas!",
            Duration = 3,
            Image = nil
         })
      end)
   end
})

local CreditSection = SettingsTab:CreateSection("Créditos")
local Credit1 = SettingsTab:CreateLabel("Script: Fronteira do Brasil")
local Credit2 = SettingsTab:CreateLabel("UI: Rayfield Interface Suite")
local Credit3 = SettingsTab:CreateLabel("Versão: 3.2 - Hitbox por Time")

-- ========================================
-- NOTIFICAÇÃO INICIAL
-- ========================================
Rayfield:Notify({
   Title = "Fronteira do Brasil",
   Content = "Script carregado com sucesso!",
   Duration = 5,
   Image = nil
})

print("Script Fronteira do Brasil carregado com sucesso!")
