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
            
            -- Determinar cor baseada no time
            local hitboxColor = Color3.fromRGB(255, 255, 255) -- Branco padrão
            
            if player.Team then
               hitboxColor = player.Team.TeamColor.Color
            end
            
            -- Criar nova hitbox
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "HitboxVisual"
            box.Adornee = hrp
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
            box.Color3 = hitboxColor
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
