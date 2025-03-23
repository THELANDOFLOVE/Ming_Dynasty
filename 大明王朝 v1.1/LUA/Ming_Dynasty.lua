include("UtilityFunctions")  
include("FLuaVector.lua")  
include("PlotIterators.lua")  
-- 定义大明王朝文明的类型常量
local Ming_civili = GameInfoTypes["CIVILIZATION_Ming_Dynasty"]
local POLICY_Ming_Dynasty_ID = GameInfo.Policies["POLICY_Ming_Dynasty"].ID
function GiveMingDynastyPolicy(playerID)
    local player = Players[playerID]
    if player == nil then
        return
    end
    if player:IsBarbarian() or player:IsMinorCiv() then
        return
    end
    if player:GetCivilizationType() == Ming_civili then
        if not player:HasPolicy(POLICY_Ming_Dynasty_ID) then
            player:SetHasPolicy(POLICY_Ming_Dynasty_ID, true, true)
            print("大明王朝政策已赋予")
        end
    end
end
GameEvents.PlayerCityFounded.Add(GiveMingDynastyPolicy)
local MING_DYNASTY = GameInfoTypes["CIVILIZATION_Ming_Dynasty"]
local MING_DYNASTY_GOLD_AGE_POLICY_1 = GameInfo.Policies["POLICY_Ming_Dynasty_Gold_Age_1"].ID
local MING_DYNASTY_GOLD_AGE_POLICY_2 = GameInfo.Policies["POLICY_Ming_Dynasty_Gold_Age_2"].ID
local MING_PALACE = GameInfoTypes["BUILDING_Ming_PALACE"]
-- 辅助函数：根据建筑情况赋予和收回政策
function UpdateMingDynastyPolicies(player)
    -- 检查建筑情况
    local hasPalace = player:CountNumBuildings(MING_PALACE) > 0
    -- 先收回所有可能的政策
    player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_1, false, false)
    player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_2, false, false)
    if hasPalace then
        player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_2, true, true)
        print("玩家根据建筑情况，赋予POLICY_Ming_Dynasty_Gold_Age_2")
    else
        player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_1, true, true)
        print("玩家根据建筑情况，赋予POLICY_Ming_Dynasty_Gold_Age_1")
    end
end

-- 检查玩家是否处于黄金时代，并处理明朝文明的政策赋予与收回
function MingDynastyGoldAgePolicyCheck(iPlayer, bStart, iTurns)
    local player = Players[iPlayer]
    if player == nil then
        return
    end
    if player:IsBarbarian() or player:IsMinorCiv() then
        return
    end
    if player:GetCivilizationType() == MING_DYNASTY then
        if bStart then
            UpdateMingDynastyPolicies(player)
        else
            -- 当不在黄金时代时，收回所有政策
            player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_1, false, false)
            player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_2, false, false)
            print("玩家不在黄金时代，收回POLICY_Ming_Dynasty_Gold_Age_1 到 POLICY_Ming_Dynasty_Gold_Age_2")
        end
    end
end

-- 检查玩家是否建造了特殊建筑并更新政策
function MingDynastyBuildingUpdate(iPlayer)
    local player = Players[iPlayer]
    if player == nil then
        return
    end
    if player:IsBarbarian() or player:IsMinorCiv() then
        return
    end
    if player:GetCivilizationType() == MING_DYNASTY then
        if player:IsGoldenAge() then
            UpdateMingDynastyPolicies(player)
        else
            -- 当不在黄金时代时，收回所有政策
            player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_1, false, false)
            player:SetHasPolicy(MING_DYNASTY_GOLD_AGE_POLICY_2, false, false)
            print("玩家不在黄金时代，收回POLICY_Ming_Dynasty_Gold_Age_1 到 POLICY_Ming_Dynasty_Gold_Age_2")
        end
    end
end

-- 将检查函数绑定到玩家黄金时代开始和结束事件
GameEvents.PlayerGoldenAge.Add(MingDynastyGoldAgePolicyCheck)
-- 将检查函数绑定到玩家回合结束事件
GameEvents.PlayerDoTurn.Add(MingDynastyBuildingUpdate)
function IsCivilisationActive(MING_DYNASTY)
	for iSlot = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		  local slotStatus = PreGame.GetSlotStatus(iSlot)
		  if (slotStatus == SlotStatus.SS_TAKEN or slotStatus == SlotStatus.SS_COMPUTER) then
			  if PreGame.GetCivilization(iSlot) == MING_DYNASTY then
				  return true
			  end
		  end
	  end
  
	  return false
  end
  local bIsCivActive = IsCivilisationActive(MING_DYNASTY)
  function ONLY_MING_DYNASTY(iPlayer, iCity, iBuilding)
	if iBuilding == GameInfoTypes.BUILDING_Ming_PALACE  then
		print ("该建筑是大明南京故宫")
		local pPlayer = Players[iPlayer]
		local pCity = pPlayer:GetCityByID(iCity)
		if pPlayer:GetCivilizationType() == MING_DYNASTY then
			print ("允许朱瞻基建造大明南京故宫")
			return true
		end	
		print ("只允许朱瞻基建造大明南京故宫")
		return false
	end
	return true
end
if bIsCivActive then
GameEvents.CityCanConstruct.Add(ONLY_MING_DYNASTY)
end
function ShenJiYing(iPlayer)
	local pPlayer = Players[iPlayer]
	local ZhengHeTreasureShip = GameInfoTypes.PROMOTION_Ming_ShenJiYing
	local iEraModifier = math.max(pPlayer:GetCurrentEra(), 1)
	local iInfluence = 15 * iEraModifier
	for pUnit in pPlayer:Units() do
		if pUnit:IsHasPromotion(ZhengHeTreasureShip) then
			local iMinorPlayerID = pUnit:GetPlot():GetOwner()
			
			if iMinorPlayerID >= 0 then
				local pMinorPlayer = Players[iMinorPlayerID]
			
				if pMinorPlayer:IsMinorCiv() then
					pMinorPlayer:ChangeMinorCivFriendshipWithMajor(iPlayer, iInfluence)
				
					if pPlayer:IsHuman() then
						local vHex = ToHexFromGrid(Vector2(pUnit:GetX(), pUnit:GetY()))
						Events.AddPopupTextEvent(HexToWorld(vHex), Locale.ConvertTextKey("[ICON_WHITE]+{1_Num}[ENDCOLOR][ICON_INFLUENCE]", iInfluence), true)
					end
				end
			end
		end
	end
end

GameEvents.PlayerDoTurn.Add(ShenJiYing)
function ZhengHe(iPlayer)
	local pPlayer = Players[iPlayer]
	local ZhengHeTreasureShip = GameInfoTypes.PROMOTION_Ming_ZhengHeTreasureShip
	local iEraModifier = math.max(pPlayer:GetCurrentEra(), 1)
	local iInfluence = 50 * iEraModifier
	for pUnit in pPlayer:Units() do
		if pUnit:IsHasPromotion(ZhengHeTreasureShip) then
			local iMinorPlayerID = pUnit:GetPlot():GetOwner()
			
			if iMinorPlayerID >= 0 then
				local pMinorPlayer = Players[iMinorPlayerID]
			
				if pMinorPlayer:IsMinorCiv() then
					pMinorPlayer:ChangeMinorCivFriendshipWithMajor(iPlayer, iInfluence)
				
					if pPlayer:IsHuman() then
						local vHex = ToHexFromGrid(Vector2(pUnit:GetX(), pUnit:GetY()))
						Events.AddPopupTextEvent(HexToWorld(vHex), Locale.ConvertTextKey("[ICON_WHITE]+{1_Num}[ENDCOLOR][ICON_INFLUENCE]", iInfluence), true)
					end
				end
			end
		end
	end
end

GameEvents.PlayerDoTurn.Add(ZhengHe)