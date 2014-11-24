
local hudScreen = nil
local Alive = false
local Class = nil
local Team = 0
local WaitingToRespawn = false
local InRound = false
local RoundResult = 0
local RoundWinner = nil
local IsObserver = false
local ObserveMode = 0
local ObserveTarget = nil
local InVote = false

local fontCreated = false
local hudHealth = nil
local hudHealthText = nil
local hudAmmo = nil
local hudAmmoText = nil
local hudTime = nil
local hudTimeText = nil
local hudTeams = nil
local hudTeamsText = nil
local redrawTeams = true

-- Materials List
local hpBG = Material( "freezetag/health.png", "smooth" )
local ammoBG = Material( "freezetag/ammo.png", "smooth" )
local timeBG = Material( "freezetag/time.png", "smooth" )

if (!fontCreated) then
		surface.CreateFont( "PerrinFont", {
			font = "Arial", 
			size = 50, 
			weight = 2000, 
			blursize = 0, 
			scanlines = 0, 
			antialias = true, 
			underline = false, 
			italic = false, 
			strikeout = false, 
			symbol = false, 
			rotary = false, 
			shadow = false, 
			additive = false, 
			outline = false, 
		} )	
		fontCreated = true
end

function GM:AddHUDItem( item, pos, parent )
	hudScreen:AddItem( item, parent, pos )
end

function GM:HUDNeedsUpdate()

	if ( !IsValid( LocalPlayer() ) ) then return false end

	if ( Class != LocalPlayer():GetNWString( "Class", "Default" ) ) then return true end
	if ( Alive != LocalPlayer():Alive() ) then return true end
	if ( Team != LocalPlayer():Team() ) then return true end
	if ( WaitingToRespawn != ( (LocalPlayer():GetNWFloat( "RespawnTime", 0 ) > CurTime()) && LocalPlayer():Team() != TEAM_SPECTATOR && !LocalPlayer():Alive()) ) then return true end
	if ( InRound != GetGlobalBool( "InRound", false ) ) then return true end
	if ( RoundResult != GetGlobalInt( "RoundResult", 0 ) ) then return true end
	if ( RoundWinner != GetGlobalEntity( "RoundWinner", nil ) ) then return true end
	if ( IsObserver != LocalPlayer():IsObserver() ) then return true end
	if ( ObserveMode != LocalPlayer():GetObserverMode() ) then return true end
	if ( ObserveTarget != LocalPlayer():GetObserverTarget() ) then return true end
	if ( InVote != GAMEMODE:InGamemodeVote() ) then return true end
	
	return false
end

function GM:OnHUDUpdated()
	Class = LocalPlayer():GetNWString( "Class", "Default" )
	Alive = LocalPlayer():Alive()
	Team = LocalPlayer():Team()
	WaitingToRespawn = (LocalPlayer():GetNWFloat( "RespawnTime", 0 ) > CurTime()) && LocalPlayer():Team() != TEAM_SPECTATOR && !Alive
	InRound = GetGlobalBool( "InRound", false )
	RoundResult = GetGlobalInt( "RoundResult", 0 )
	RoundWinner = GetGlobalEntity( "RoundWinner", nil )
	IsObserver = LocalPlayer():IsObserver()
	ObserveMode = LocalPlayer():GetObserverMode()
	ObserveTarget = LocalPlayer():GetObserverTarget()
	InVote = GAMEMODE:InGamemodeVote()
end

function GM:OnHUDPaint()

end

function GM:RefreshHUD()

	if ( !GAMEMODE:HUDNeedsUpdate() ) then return end
	GAMEMODE:OnHUDUpdated()
	
	if ( IsValid( hudScreen ) ) then hudScreen:Remove() end
	hudScreen = vgui.Create( "DHudLayout" )
	
	if ( InVote ) then return end
	
	if ( RoundWinner and RoundWinner != NULL ) then
		GAMEMODE:UpdateHUD_RoundResult( RoundWinner, Alive )
	elseif ( RoundResult != 0 ) then
		GAMEMODE:UpdateHUD_RoundResult( RoundResult, Alive )
	elseif ( IsObserver ) then
		GAMEMODE:UpdateHUD_Observer( WaitingToRespawn, InRound, ObserveMode, ObserveTarget )
	elseif ( !Alive ) then
		GAMEMODE:UpdateHUD_Dead( WaitingToRespawn, InRound )
	else
		/* GAMEMODE:UpdateHUD_Alive( InRound ) */
	end
	
end

function GM:HUDPaint()

	self.BaseClass:HUDPaint()

	--GAMEMODE:UpdatePerrinHUD()
	
	MattHUD()
	
	--GAMEMODE:OnHUDPaint()
	GAMEMODE:RefreshHUD()
	
end

--
local function DrawHUDHealth()
	if !LocalPlayer():Alive() then return end
	
	surface.SetMaterial( hpBG )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( 30, ScrH() - 130, 165, 104)
	surface.SetTextPos( 97, ScrH() - 85 )
	surface.SetTextColor( 24, 103, 136, 255 )
	surface.SetFont( "PerrinFont" )
	surface.DrawText( LocalPlayer():Health() )
	
end

local function DrawHUDAmmo()
	if !LocalPlayer():Alive() then return end
	local text = "0"
	if IsValid(LocalPlayer():GetActiveWeapon()) then
		text = LocalPlayer():GetActiveWeapon():Clip1()
	end
	surface.SetMaterial( ammoBG )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( ScrW() - 190, ScrH() - 130, 159, 125)
	surface.SetTextPos( ScrW() - 105 , ScrH() - 85 )
	surface.SetTextColor( 24, 103, 136, 255 )
	surface.SetFont( "PerrinFont" )
	surface.DrawText( text )
	
end

local function DrawHUDTime()
	--if !LocalPlayer():Alive() then return end
	local timerValue = 0
	local TimeMessage = ""

	if ( bWaitingToSpawn ) then
		timerValue = LocalPlayer():GetNWFloat( "RespawnTime", 0 )
		TimeMessage = util.ToMinutesSeconds( timerValue )
	end

	if (InRound) then
		if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then
			timerValue = GetGlobalFloat( "RoundStartTime", 0 )
		else
			timerValue =  GetGlobalFloat( "RoundEndTime" )
		end 
		TimeMessage = util.ToMinutesSeconds( timerValue - CurTime() )
	end
		
	surface.SetMaterial( timeBG )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( (ScrW() / 2) - 130, 30, 261, 90)
	surface.SetTextPos( (ScrW() / 2) - 40, 60 )
	surface.SetTextColor( 24, 103, 136, 255 )
	surface.SetFont( "PerrinFont" )
	surface.DrawText( TimeMessage )
	
end

function MattHUD()

	DrawHUDHealth()
	DrawHUDAmmo()
	DrawHUDTime()
	
end
function GM:UpdatePerrinHUD()

	if (!IsValid(hudHealth)) then		
		hudHealth = vgui.Create( "DPanel" )
		hudHealth:SetSize( 165, 104 )
		hudHealth:SetPos(30, ScrH() - 130)
		hudHealth:SetDrawBackground( false )
		
		local img_bg = vgui.Create( "DImage", hudHealth )
		img_bg:SetSize( hudHealth:GetSize() )		
		img_bg:SetImage( "freezetag/Health.png" )	

		hudHealthText = vgui.Create("DLabel", hudHealth)
		hudHealthText:SetPos(55,45)
		hudHealthText:SetFont("PerrinFont")
		hudHealthText:SetTextColor( Color( 24, 103, 136, 255 ) )
		hudHealthText:SetText("100")
		hudHealthText:SizeToContents()
		hudHealthText:SetVisible(true)
	end	

	if (!IsValid(hudAmmo)) then		
		hudAmmo = vgui.Create( "DPanel" )
		hudAmmo:SetSize( 159, 125 )
		hudAmmo:SetPos(ScrW() - 190, ScrH() - 130)
		hudAmmo:SetDrawBackground( false )
		
		local hudAmmoBG = vgui.Create( "DImage", hudAmmo )
		hudAmmoBG:SetSize( hudAmmo:GetSize() )		
		hudAmmoBG:SetImage( "freezetag/ammo.png" )	

		hudAmmoText = vgui.Create("DLabel", hudAmmo)
		hudAmmoText:SetPos(55,45)
		hudAmmoText:SetFont("PerrinFont")
		hudAmmoText:SetTextColor( Color( 24, 103, 136, 255 ) )
		hudAmmoText:SetText("0")
		hudAmmoText:SizeToContents()
		hudAmmoText:SetVisible(true)
	end	

	if (!IsValid(hudTime)) then		
		hudTime = vgui.Create( "DPanel" )
		hudTime:SetSize( 261, 90 )
		hudTime:SetPos((ScrW() / 2) - 130, 30)
		hudTime:SetDrawBackground( false )
		
		local hudTimeBG = vgui.Create( "DImage", hudTime )
		hudTimeBG:SetSize( hudTime:GetSize() )		
		hudTimeBG:SetImage( "freezetag/time.png" )	

		hudTimeText = vgui.Create("DLabel", hudTime)
		hudTimeText:SetPos(100,30)
		hudTimeText:SetFont("PerrinFont")
		hudTimeText:SetTextColor( Color( 24, 103, 136, 255 ) )
		hudTimeText:SetText("0")
		hudTimeText:SizeToContents()
		hudTimeText:SetVisible(true)
	end
	
	if (IsValid(hudTeams)) then
		/* hudTeams:Remove() */
	end
	

	

	if (!IsValid(hudTeams)) then		
		hudTeams = vgui.Create( "DPanel" )
		hudTeams:SetSize( 300, 90 )
		hudTeams:SetPos((ScrW() / 2) - 130, ScrH() - 100)
		hudTeams:SetDrawBackground( false )
				
		local redPlayers = team.GetPlayers(TEAM_RED)
		for key, currentPlayer in pairs(redPlayers) do
			if (currentPlayer:GetNWBool( "Frozen", false )) then
				debugVal = "FROZEN"
			else
				debugVal = "FREE"
			end
		end
		
		hudTeamsText = vgui.Create("DLabel", hudTeams)
		hudTeamsText:SetPos(100,30)
		hudTeamsText:SetFont("PerrinFont")
		hudTeamsText:SetTextColor( Color( 24, 103, 136, 255 ) )
		hudTeamsText:SetText(debugVal)
		hudTeamsText:SizeToContents()
		hudTeamsText:SetVisible(true)
		
	end	



	
	if (IsValid(hudHealthText)) then
		hudHealthText:SetText(LocalPlayer():Health())
		hudHealthText:SizeToContents()
	end
	
	if (IsValid(hudAmmoText)) then
		local ammoText = "0"
		if IsValid( LocalPlayer():GetActiveWeapon() ) then
			ammoText = LocalPlayer():GetActiveWeapon():Clip1()
		end
		hudAmmoText:SetText(ammoText)
		hudAmmoText:SizeToContents()
	end
	
	if (IsValid(hudTimeText)) then

		local timerValue = 0
		local TimeMessage = ""

		if ( bWaitingToSpawn ) then
			timerValue = LocalPlayer():GetNWFloat( "RespawnTime", 0 )
			TimeMessage = util.ToMinutesSeconds( timerValue )
		end
	
		if (InRound) then
			if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then
				timerValue = GetGlobalFloat( "RoundStartTime", 0 )
			else
				timerValue =  GetGlobalFloat( "RoundEndTime" )
			end 
			TimeMessage = util.ToMinutesSeconds( timerValue - CurTime() )
		end
	
		hudTimeText:SetText(TimeMessage)
		hudTimeText:SizeToContents()
	end


end

concommand.Add( "testc1", function( ply )
	 GAMEMODE:UpdatePerrinHUD()
end )
concommand.Add( "testc2", function( ply )
	if (IsValid(hudTeamsText)) then
		hudTeamsText:Remove()
	end
end )

function GM:UpdateHUD_RoundResult( RoundResult, Alive )

	local txt = GetGlobalString( "RRText" )
	
	if ( type( RoundResult ) == "number" ) && ( team.GetAllTeams()[ RoundResult ] && txt == "" ) then
		local TeamName = team.GetName( RoundResult )
		if ( TeamName ) then txt = TeamName .. " Wins!" end
	elseif ( type( RoundResult ) == "Player" && IsValid( RoundResult ) && txt == "" ) then
		txt = RoundResult:Name() .. " Wins!"
	end

	local RespawnText = vgui.Create( "DHudElement" );
		RespawnText:SizeToContents()
		RespawnText:SetText( txt )
	GAMEMODE:AddHUDItem( RespawnText, 8 )

end

function GM:UpdateHUD_Observer( bWaitingToSpawn, InRound, ObserveMode, ObserveTarget )
--[[
	local lbl = nil
	local txt = nil
	local col = Color( 255, 255, 255 );

	if ( IsValid( ObserveTarget ) && ObserveTarget:IsPlayer() && ObserveTarget != LocalPlayer() && ObserveMode != OBS_MODE_ROAMING ) then
		lbl = "SPECTATING"
		txt = ObserveTarget:Nick()
		col = team.GetColor( ObserveTarget:Team() );
	end
	
	if ( ObserveMode == OBS_MODE_DEATHCAM || ObserveMode == OBS_MODE_FREEZECAM ) then
		txt = "You Died!" // were killed by?
	end
	
	if ( txt ) then
		local txtLabel = vgui.Create( "DHudElement" );
		txtLabel:SetText( txt )
		if ( lbl ) then txtLabel:SetLabel( lbl ) end
		txtLabel:SetTextColor( col )
		
		GAMEMODE:AddHUDItem( txtLabel, 2 )		
	end

	
	GAMEMODE:UpdateHUD_Dead( bWaitingToSpawn, InRound )
--]]
end

function GM:UpdateHUD_Dead( bWaitingToSpawn, InRound )

	if ( !InRound && GAMEMODE.RoundBased ) then
	
		local RespawnText = vgui.Create( "DHudElement" );
			RespawnText:SizeToContents()
			RespawnText:SetText( "Waiting for round start" )
		GAMEMODE:AddHUDItem( RespawnText, 8 )
		return
		
	end

	if ( bWaitingToSpawn ) then

		local RespawnTimer = vgui.Create( "DHudCountdown" );
			RespawnTimer:SizeToContents()
			RespawnTimer:SetValueFunction( function() return LocalPlayer():GetNWFloat( "RespawnTime", 0 ) end )
			RespawnTimer:SetLabel( "SPAWN IN" )
		GAMEMODE:AddHUDItem( RespawnTimer, 8 )
		return

	end
	
	if ( InRound ) then
	--[[
		local RoundTimer = vgui.Create( "DHudCountdown" );
			RoundTimer:SizeToContents()
			RoundTimer:SetValueFunction( function() 
											if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then return GetGlobalFloat( "RoundStartTime", 0 )  end 
											return GetGlobalFloat( "RoundEndTime" ) end )
			RoundTimer:SetLabel( "TIME" )
		GAMEMODE:AddHUDItem( RoundTimer, 8 )
		return
	--]]
	end
	--[[
	if ( Team != TEAM_SPECTATOR && !Alive ) then
	
		local RespawnText = vgui.Create( "DHudElement" );
			RespawnText:SizeToContents()
			RespawnText:SetText( "Press Fire to Spawn" )
		GAMEMODE:AddHUDItem( RespawnText, 8 )
		
	end
--]]
end


function GM:UpdateHUD_Alive( InRound )

	/* GAMEMODE:PaintAmmo()
	GAMEMODE:PaintHealth() */

	if ( GAMEMODE.RoundBased || GAMEMODE.TeamBased ) then
	
		local Bar = vgui.Create( "DHudBar" )
		GAMEMODE:AddHUDItem( Bar, 2 )

		if ( GAMEMODE.TeamBased ) then
		
			local TeamIndicator = vgui.Create( "DHudUpdater" );
				TeamIndicator:SizeToContents()
				TeamIndicator:SetValueFunction( function() 
													return team.GetName( LocalPlayer():Team() )
												end )
				TeamIndicator:SetColorFunction( function() 
													return team.GetColor( LocalPlayer():Team() )
												end )
				TeamIndicator:SetFont( "HudSelectionText" )
			Bar:AddItem( TeamIndicator )
			
		end
		
		if ( GAMEMODE.RoundBased ) then 
		
			local RoundNumber = vgui.Create( "DHudUpdater" );
				RoundNumber:SizeToContents()
				RoundNumber:SetValueFunction( function() return GetGlobalInt( "RoundNumber", 0 ) end )
				RoundNumber:SetLabel( "ROUND" )
			Bar:AddItem( RoundNumber )
			
			local RoundTimer = vgui.Create( "DHudCountdown" );
				RoundTimer:SizeToContents()
				RoundTimer:SetValueFunction( function() 
												if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then return GetGlobalFloat( "RoundStartTime", 0 )  end 
												return GetGlobalFloat( "RoundEndTime" ) end )
				RoundTimer:SetLabel( "TIME" )
			Bar:AddItem( RoundTimer )

		end
		
	end

end

function GM:PaintAmmo()

	local Bar = vgui.Create( "DHudBar" )
		GAMEMODE:AddHUDItem( Bar, 3 )

	local AmmoIndicator = vgui.Create( "DHudUpdater" )
		AmmoIndicator:SizeToContents()
		AmmoIndicator:SetValueFunction( function()
											if IsValid( LocalPlayer():GetActiveWeapon() ) then
												return LocalPlayer():GetActiveWeapon():Clip1() or 0
											end
											return 0
										end )
		AmmoIndicator:SetLabel( "AMMO" )
		AmmoIndicator:SetFont( "FHUDElement" )
		
	Bar:AddItem( AmmoIndicator )

end

function GM:PaintHealth()
	
	local Bar = vgui.Create( "DHudBar" )
		GAMEMODE:AddHUDItem( Bar, 1 )
		
	local HealthIndicator = vgui.Create( "DHudUpdater" )
		HealthIndicator:SizeToContents()
		HealthIndicator:SetValueFunction( function() return LocalPlayer():Health() end )
		HealthIndicator:SetColorFunction( function() 
											if LocalPlayer():Health() <= 25 then
												return Color( 255, 100 + math.sin( RealTime() * 3 ) * 100, 100 + math.sin( RealTime() * 3 ) * 100, 255 )	
											end
											return Color( 255, 255, 255, 255 )
										end )
		HealthIndicator:SetLabel( "HEALTH" )
		HealthIndicator:SetFont( "FHUDElement" )
		
	Bar:AddItem( HealthIndicator )

end

function GM:UpdateHUD_AddedTime( iTimeAdded )
	// to do or to override, your choice
end
usermessage.Hook( "RoundAddedTime", function( um ) if( GAMEMODE && um ) then GAMEMODE:UpdateHUD_AddedTime( um:ReadFloat() ) end end )



