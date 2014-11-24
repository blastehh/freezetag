
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_teamfrozen.lua" )

include( "shared.lua" )
include( "tables.lua" )
include( "ply_extension.lua" )
include( "sv_resources.lua" )

function GM:OnRoundStart()
	
	UTIL_UnFreezeAllPlayers()
	
end

function GM:OnRoundResult( t )
	
	team.AddScore( t, 1 )
	
	for k,v in pairs( player.GetAll() ) do 
	
		--v:Thaw()
		
		if v:Team() == t then
			
			v:PlaySound(GAMEMODE.WinSound)
		else
			v:PlaySound(GAMEMODE.LoseSound)
		end
		
	end
	timer.Create("ThawRoundEnd", 3,1, function()
		for k,v in pairs( player.GetAll() ) do
			v:Thaw()
		end
	end)
end

function GM:RoundTimerEnd()

	if ( !GAMEMODE:InRound() ) then return end
	
	if GAMEMODE:GetFrozenPlayers( TEAM_RED ) < GAMEMODE:GetFrozenPlayers( TEAM_BLUE ) then
		GAMEMODE:RoundEndWithResult( TEAM_RED, "RED WINS!" )
	elseif GAMEMODE:GetFrozenPlayers( TEAM_RED ) > GAMEMODE:GetFrozenPlayers( TEAM_BLUE ) then
		GAMEMODE:RoundEndWithResult( TEAM_BLUE, "BLUE WINS!" )
	else
		GAMEMODE:RoundEndWithResult( -1, "NOBODY WINS!" )
	end

end

function GM:CheckRoundEnd()

	if ( team.NumPlayers( TEAM_RED ) + team.NumPlayers( TEAM_BLUE ) ) < 2 then return end

	if GAMEMODE:GetFrozenPlayers( TEAM_RED ) == team.NumPlayers( TEAM_RED ) and team.NumPlayers( TEAM_RED ) > 0 then
		GAMEMODE:RoundEndWithResult( TEAM_BLUE, "BLUE WINS!" )
	elseif GAMEMODE:GetFrozenPlayers( TEAM_BLUE ) == team.NumPlayers( TEAM_BLUE ) and team.NumPlayers( TEAM_BLUE ) > 0 then
		GAMEMODE:RoundEndWithResult( TEAM_RED, "RED WINS!" )
	end

end

function GM:EntityTakeDamage( ent, dmginfo )
	local inflictor, attacker, amount = dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage()
	
	if not ent:IsPlayer() then return end
	if not ent:Alive() then return end
	
	if dmginfo:IsFallDamage() or ent == attacker or not attacker:IsPlayer() or not GAMEMODE:InRound() then
	
		dmginfo:SetDamage( 0 ) 
		return
		
	end
	
	if ent:IsFrozen() then
		
		ent:EmitSound( table.Random( GAMEMODE.GlassHit ) )
		
		if attacker:Team() == ent:Team() then
			dmginfo:SetDamage( 0 )
			return
		end
		
		dmginfo:ScaleDamage( 0.40 )
		
		if (ent:Health() - dmginfo:GetDamage()) <= 1 then
		
			ent:SetHealth( 1 )
			dmginfo:SetDamage( 0 )
			return
			
		end

	end
	
	if ent:Health() - dmginfo:GetDamage() <= 1 then
	
		if IsValid( attacker ) and attacker:IsPlayer() then
		
			if attacker:Team() != ent:Team() then
			
				ent:SetHealth( 1 )
				ent:AddDeaths( 1 )
				ent:Flashlight( false )
				ent:IceFreeze()
				
				dmginfo:SetDamage( 0 )
				
				attacker:AddFrags( 1 )
				
				if ( ( inflictor and inflictor == attacker ) or inflictor:IsPlayer() ) then
					inflictor = attacker:GetActiveWeapon()
				end

				net.Start( "PlayerKilledByPlayer" )
		
					net.WriteEntity( ent )
					net.WriteString( inflictor:GetClass() )
					net.WriteEntity( attacker )
		
				net.Broadcast()

			end
		end
	end
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	
	dmginfo:ScaleDamage( 1 )
	
end

function GM:GetFrozenPlayers( t )

	local num = 0
	
	for k,v in pairs( team.GetPlayers( t ) ) do
	
		if v:IsFrozen() or not v:Alive() then
			num = num + 1
		end
		
	end
	
	return num
	
end

function GM:Think()

	LastThawTick = LastThawTick or 0
	if CurTime() - LastThawTick > 0.3 then
		for k,v in pairs(player.GetAll()) do
			if v:IsFrozen() and v:Alive() then
				v:ThawCheck()
			end
		end
		LastThawTick = CurTime()
	end
end