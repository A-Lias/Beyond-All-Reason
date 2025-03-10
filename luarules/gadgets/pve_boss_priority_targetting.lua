function gadget:GetInfo()
    return {
        name = "Raptor Queen Anti-Dgun behavior",
        desc = "Queen will prioritize targetting nearby commander so it doesn't let itself be dgunned",
        author = "Damgam",
        date = "2023",
        license = "GNU GPL, v2 or later",
        layer = 0,
        enabled = true
    }
end

if not gadgetHandler:IsSyncedCode() then
    return
end

local queenUnitDefs = {
    raptor_queen_veryeasy = true,
    raptor_queen_easy = true,
    raptor_queen_normal = true,
    raptor_queen_hard = true,
    raptor_queen_veryhard = true,
    raptor_queen_epic = true,

    raptor_matriarch_spectre = true,
	raptor_matriarch_electric = true,
	raptor_matriarch_acid = true,
	raptor_matriarch_healer = true,
	raptor_matriarch_basic = true,
	raptor_matriarch_fire = true,

    armscavengerbossv2_veryeasy = true,
    armscavengerbossv2_easy = true,
    armscavengerbossv2_normal = true,
    armscavengerbossv2_hard = true,
    armscavengerbossv2_veryhard = true,
    armscavengerbossv2_epic = true,
}


local queenUnits = {}
for unitDefName, isqueen in pairs(queenUnitDefs) do
	if UnitDefNames[unitDefName] then
		queenUnits[UnitDefNames[unitDefName].id] = isqueen
	end
end
queenUnitDefs = nil

local queenTargets = {}
for unitDefID, unitDef in pairs(UnitDefs) do
    if unitDef.customParams.iscommander then
        queenTargets[unitDefID] = true
    end
end


local aliveQueens = {}
local aliveTargets = {}
function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
    if queenUnits[unitDefID] then
        aliveQueens[unitID] = true
    end
    if queenTargets[unitDefID] then
        aliveTargets[unitID] = true
    end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
    if aliveQueens[unitID] then
        aliveQueens[unitID] = nil
    end
    if aliveTargets[unitID] then
        aliveTargets[unitID] = nil
    end
end

function gadget:GameFrame(frame)
    if frame%30 == 21 then
        for queenID, _ in pairs(aliveQueens) do
            local queenx,queeny,queenz = Spring.GetUnitPosition(queenID)
            local surroundingUnits = Spring.GetUnitsInSphere(queenx, queeny, queenz, 750)
            for i = 1,#surroundingUnits do
				if aliveTargets[surroundingUnits[i]] and Spring.GetUnitAllyTeam(surroundingUnits[i]) ~= Spring.GetUnitAllyTeam(queenID) then
                    Spring.GiveOrderToUnit(queenID, CMD.STOP, 0, 0)
                    Spring.GiveOrderToUnit(queenID, CMD.ATTACK, {surroundingUnits[i]}, 0)
                    break
                end
            end
        end
    end
end
