-- Fronteira do Brasil - Rayfield UI
-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela
local Window = Rayfield:CreateWindow({
   Name = "Fronteira do Brasil",
   LoadingTitle = "Carregando Script",
   LoadingSubtitle = "by Comunidade",
   ConfigurationSaving = {
      Enabled = true,
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
-- ABA: IMIGRANTE
-- ========================================
local ImigranteTab = Window:CreateTab("👤 Imigrante", nil)
local ImigranteSection = ImigranteTab:CreateSection("Percurso Automático")

local ImigranteButton = ImigranteTab:CreateButton({
   Name = "Ande pra três para pegar arma",
   Callback = function()
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
      
      -- Primeiro teleport
      humanoidRootPart.CFrame = CFrame.new(117.29, 12.99, 193.24)
      task.wait(1)
      
      -- Simular tecla E
      local vim = game:GetService("VirtualInputManager")
      vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
      task.wait(0.1)
      vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
      task.wait(0.5)
      
      -- Segundo teleport ajustado
      local destino = Vector3.new(222.76, 22.42, 7.44)
      local camera = workspace.CurrentCamera
      local direcao = camera.CFrame.LookVector
      direcao = Vector3.new(direcao.X, 0, direcao.Z).Unit
      local destinoFinal = destino - (direcao * 3)
      
      humanoidRootPart.CFrame = CFrame.new(destinoFinal)
      
      Rayfield:Notify({
         Title = "Imigrante",
         Content = "Percurso concluído com sucesso!",
         Duration = 3,
         Image = nil
      })
   end
})

-- ========================================
-- ABA: COMBATE
-- ========================================
local CombateTab = Window:CreateTab("⚔️ Combate", nil)
local CombateSection = CombateTab:CreateSection("Configurações de Hitbox")

local HeadSize = 50
local HitboxEnabled = false
local hitboxConnection

local function UpdateHitbox()
   for _, player in ipairs(game.Players:GetPlayers()) do
      if player ~= game.Players.LocalPlayer and player.Character then
         local hrp = player.Character:FindFirstChild("HumanoidRootPart")
         if hrp then
            -- Remover antigas
            for _, child in ipairs(hrp:GetChildren()) do
               if child.Name == "HitboxVisual" then
                  child:Destroy()
               end
            end
            
            -- Criar nova
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "HitboxVisual"
            box.Adornee = hrp
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
            box.Color3 = Color3.fromRGB(0, 170, 255)
            box.Transparency = 0.7
            box.Parent = hrp
         end
      end
   end
end

local function ClearHitbox()
   for _, player in ipairs(game.Players:GetPlayers()) do
      if player.Character then
         local hrp = player.Character:FindFirstChild("HumanoidRootPart")
         if hrp then
            for _, child in ipairs(hrp:GetChildren()) do
               if child.Name == "HitboxVisual" then
                  child:Destroy()
               end
            end
         end
      end
   end
end

local HitboxToggle = CombateTab:CreateToggle({
   Name = "Ativar Hitbox",
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
            if HitboxEnabled then
               UpdateHitbox()
            end
         end)
         Rayfield:Notify({
            Title = "Hitbox",
            Content = "Hitbox ATIVADA",
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
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 50,
   Flag = "HitboxSize",
   Callback = function(Value)
      HeadSize = Value
      if HitboxEnabled then
         UpdateHitbox()
      end
   end
})

-- ========================================
-- ABA: PERSONAGEM
-- ========================================
local PersonagemTab = Window:CreateTab("🏃 Personagem", nil)
local MovimentoSection = PersonagemTab:CreateSection("Movimentação")

-- NoClip
local NoclipEnabled = false
local noclipConnection

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
            if NoclipEnabled and game.Players.LocalPlayer.Character then
               for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = false
                  end
               end
            end
         end)
         Rayfield:Notify({
            Title = "NoClip",
            Content = "Atravessar paredes ATIVADO",
            Duration = 2,
            Image = nil
         })
      else
         Rayfield:Notify({
            Title = "NoClip",
            Content = "Atravessar paredes DESATIVADO",
            Duration = 2,
            Image = nil
         })
      end
   end
})

-- Velocidade
local SpeedEnabled = false
local SpeedValue = 2
local speedConnection

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
         Rayfield:Notify({
            Title = "Velocidade",
            Content = "Velocidade aumentada ATIVADA",
            Duration = 2,
            Image = nil
         })
      else
         local char = game.Players.LocalPlayer.Character
         if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
               hum.WalkSpeed = 16
            end
         end
         Rayfield:Notify({
            Title = "Velocidade",
            Content = "Velocidade aumentada DESATIVADA",
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

-- Pulo
local JumpEnabled = false
local JumpValue = 2
local jumpConnection

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
         Rayfield:Notify({
            Title = "Pulo",
            Content = "Pulo alto ATIVADO",
            Duration = 2,
            Image = nil
         })
      else
         local char = game.Players.LocalPlayer.Character
         if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
               hum.JumpPower = 50
            end
         end
         Rayfield:Notify({
            Title = "Pulo",
            Content = "Pulo alto DESATIVADO",
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

local FarmEnabled = false
local AntiAFKEnabled = false
local farmPosition = Vector3.new(205.10, 47.33, 70.59)
local farmConnection
local antiAfkConnection

local function StartFarm()
   if FarmEnabled then return end
   FarmEnabled = true
   
   local player = game.Players.LocalPlayer
   local character = player.Character or player.CharacterAdded:Wait()
   local hrp = character:WaitForChild("HumanoidRootPart")
   local hum = character:WaitForChild("Humanoid")
   
   -- Teleportar virado para Sudeste (135 graus)
   local sudeste = CFrame.Angles(0, math.rad(135), 0)
   hrp.CFrame = CFrame.new(farmPosition) * sudeste
   task.wait(1)
   
   -- Agachar
   game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)
   
   -- Congelar
   hum.WalkSpeed = 0
   hum.JumpPower = 0
   
   Rayfield:Notify({
      Title = "Farm XP",
      Content = "Farm AFK INICIADO!",
      Duration = 3,
      Image = nil
   })
   
   -- Anti-AFK com movimento
   farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
      if FarmEnabled and hrp then
         local offset = math.sin(tick() * 1.5) * 0.05
         hrp.CFrame = CFrame.new(farmPosition) * CFrame.new(offset, 0, offset)
      end
   end)
end

local function StopFarm()
   if not FarmEnabled then return end
   FarmEnabled = false
   
   if farmConnection then
      farmConnection:Disconnect()
      farmConnection = nil
   end
   
   local char = game.Players.LocalPlayer.Character
   if char then
      local hum = char:FindFirstChild("Humanoid")
      if hum then
         hum.WalkSpeed = 16
         hum.JumpPower = 50
      end
      game:GetService("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
   end
   
   Rayfield:Notify({
      Title = "Farm XP",
      Content = "Farm AFK PARADO",
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
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
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

-- Atualizar coordenadas a cada 0.5 segundos
task.spawn(function()
   while true do
      local char = game.Players.LocalPlayer.Character
      if char then
         local hrp = char:FindFirstChild("HumanoidRootPart")
         if hrp then
            local pos = hrp.Position
            coordsLabel:Set(string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z))
         end
      end
      task.wait(0.5)
   end
end)

local CopyButton = CoordsTab:CreateButton({
   Name = "Copiar Coordenadas",
   Callback = function()
      local char = game.Players.LocalPlayer.Character
      if char then
         local hrp = char:FindFirstChild("HumanoidRootPart")
         if hrp then
            local pos = hrp.Position
            local coords = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            setclipboard(coords)
            Rayfield:Notify({
               Title = "Coordenadas",
               Content = "Copiado para área de transferência!",
               Duration = 2,
               Image = nil
            })
         end
      end
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
         end
      end
      
      game:GetService("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
      ClearHitbox()
      
      Rayfield:Notify({
         Title = "Sistema",
         Content = "Todas as configurações resetadas!",
         Duration = 3,
         Image = nil
      })
   end
})

local CreditSection = SettingsTab:CreateSection("Créditos")
local Credit1 = SettingsTab:CreateLabel("Script: Fronteira do Brasil")
local Credit2 = SettingsTab:CreateLabel("UI: Rayfield Interface Suite")
local Credit3 = SettingsTab:CreateLabel("Versão: 3.0 (Rayfield)")

-- ========================================
-- RECONEXÃO AUTOMÁTICA
-- ========================================
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
   task.wait(2)
   
   -- Reconectar hitbox
   if HitboxEnabled then
      if hitboxConnection then hitboxConnection:Disconnect() end
      hitboxConnection = game:GetService("RunService").RenderStepped:Connect(function()
         if HitboxEnabled then UpdateHitbox() end
      end)
   end
   
   -- Reconectar noclip
   if NoclipEnabled then
      if noclipConnection then noclipConnection:Disconnect() end
      noclipConnection = game:GetService("RunService").Stepped:Connect(function()
         if NoclipEnabled and char then
            for _, part in ipairs(char:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end
      end)
   end
   
   -- Reconectar velocidade
   if SpeedEnabled then
      if speedConnection then speedConnection:Disconnect() end
      speedConnection = game:GetService("RunService").RenderStepped:Connect(function()
         if SpeedEnabled then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 * SpeedValue end
         end
      end)
   end
   
   -- Reconectar pulo
   if JumpEnabled then
      if jumpConnection then jumpConnection:Disconnect() end
      jumpConnection = game:GetService("RunService").RenderStepped:Connect(function()
         if JumpEnabled then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = 50 * JumpValue end
         end
      end)
   end
   
   -- Reconectar farm
   if FarmEnabled then
      StopFarm()
      task.wait(1)
      StartFarm()
   end
end)

-- Notificação inicial
Rayfield:Notify({
   Title = "Fronteira do Brasil",
   Content = "Script carregado com sucesso!",
   Duration = 5,
   Image = nil
})
