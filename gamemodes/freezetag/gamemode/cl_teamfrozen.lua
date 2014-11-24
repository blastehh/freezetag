local indicator_mat = Material("freezetag/frost")
local indicator_col = Color(255, 255, 255, 200)

local teamIndMat = {}
teamIndMat[TEAM_RED] = Material("freezetag/redind")
teamIndMat[TEAM_BLUE] = Material("freezetag/blueind")
local teamIndCol = Color(255, 255, 255, 190)

local client, plys, ply, pos, dir, tgt
local GetPlayers = player.GetAll

-- using this hook instead of pre/postplayerdraw because playerdraw seems to
-- happen before certain entities are drawn, which then clip over the sprite
hook.Add("PostDrawTranslucentRenderables", "frozen_indicators", function()
	if LocalPlayer():Team() == TEAM_RED or LocalPlayer():Team() == TEAM_BLUE then
	
		client = LocalPlayer()
		plys = GetPlayers()

		dir = client:GetForward() * -1

		

		for k,ply in pairs(team.GetPlayers( client:Team() )) do
			pos = ply:GetPos()
			pos.z = pos.z + 74
			
			if ply:GetNWBool( "Frozen", false ) and ply != client and ply:Team() == client:Team() then
				render.SetMaterial(indicator_mat)
				render.DrawQuadEasy(pos, dir, 13, 13, indicator_col, 180)
				
			elseif ply != client and (ply:Team() == client:Team()) and ply:Alive() then
				render.SetMaterial(teamIndMat[client:Team()])
				render.DrawQuadEasy(pos, dir, 8, 8, teamIndCol, 180)
				
			end
		end
		
	end

end)