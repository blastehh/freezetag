local indicator_mat = Material("freezetag/frost")
local indicator_col = Color(255, 255, 255, 200)


local client, plys, ply, pos, dir, tgt
local GetPlayers = player.GetAll

-- using this hook instead of pre/postplayerdraw because playerdraw seems to
-- happen before certain entities are drawn, which then clip over the sprite
hook.Add("PostDrawTranslucentRenderables", "frozen_indicators", function()
	client = LocalPlayer()
	plys = GetPlayers()

	dir = client:GetForward() * -1

	render.SetMaterial(indicator_mat)

	for k,ply in pairs(team.GetPlayers( client:Team() )) do
		if ply:GetNWBool( "Frozen", false ) and ply != client and ply:Team() == client:Team() then
			pos = ply:GetPos()
			pos.z = pos.z + 74

			render.DrawQuadEasy(pos, dir, 13, 13, indicator_col, 180)
		end
	end

end)