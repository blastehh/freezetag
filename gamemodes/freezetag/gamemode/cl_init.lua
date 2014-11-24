include( "shared.lua" )
include( "cl_postprocess.lua" )
include( "cl_hud.lua" )
include( "cl_teamfrozen.lua" )

function GM:Initialize( )	

	self.BaseClass:Initialize()
	
	surface.CreateFont("CSKillIcons", {
		font = "csd",
		size = ScreenScale(25),
		weight = 500
		}
	)

	killicon.AddFont( "thaw", "CSKillIcons", "F", Color( 0, 255, 80 ) )	

end

function GM:RenderScreenspaceEffects()

	self.BaseClass:RenderScreenspaceEffects()
	
	if LocalPlayer():GetNetworkedBool( "Frozen", false ) then
	
		ColorModify[ "$pp_colour_addb" ]		= 0.10
		ColorModify[ "$pp_colour_mulb" ] 		= 0.50
		ColorModify[ "$pp_colour_colour" ] 		= 0.85
	end
	
end

function GM:OnHUDPaint()

	if LocalPlayer():GetNetworkedBool( "Frozen", false ) then
	
		surface.SetTexture( surface.GetTextureID( "freezetag/icescreen" ) )
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
	
	end

end

function GM:HUDShouldDraw( name )

	if GAMEMODE.ScoreboardVisible then return false end
	
	for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
		if name == v then return false end 
  	end 
	
	if name == "CHudDamageIndicator" and not LocalPlayer():Alive() then
		return false
	end
	
	return true
	
end

function ThirdPersonCheck( ply, pos, angles, fov )
		
	if LocalPlayer():GetNetworkedBool( "Frozen", false ) then
		local view = {}
		view.origin = pos-( angles:Forward()*100 )
		view.angles = angles
		view.fov = fov
		return view
	end
end
	
hook.Add( "CalcView", "MyCalcView", ThirdPersonCheck )
	
hook.Add( "ShouldDrawLocalPlayer", "MyShouldDrawLocalPlayer", function( ply )
	if LocalPlayer():GetNetworkedBool( "Frozen", false ) then
		return true
	end
end )

hook.Add("CreateMove", "FrozenMovement", function( cmd )
	if LocalPlayer():GetNetworkedBool( "Frozen", false ) then
		cmd:ClearMovement()
		cmd:RemoveKey(IN_ATTACK + IN_ATTACK2 + IN_JUMP + IN_DUCK + IN_RELOAD)
	end
end)
