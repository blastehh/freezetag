
local meta = FindMetaTable( "Player" )
if (!meta) then return end
local baseThawAmount = 46
local subtractPerPly = 3.5

function meta:Thaw( playsounds )

	self:SetMaterial( "" )
	self:Freeze( false )
	self:SetColor( Color(255, 255, 255, 255 ))
	if not self:IsFrozen() then return end
	self:SetNWBool( "Frozen", false )
	
	if playsounds then
	
		local ed = EffectData()
		ed:SetOrigin( self:GetPos() )
		util.Effect( "ice_break", ed, true, true )
		self:EmitSound( table.Random( GAMEMODE.GlassBreak ), 100, math.random( 90, 110 ) )
		
	end
	
end

function meta:IceFreeze()

	--self:Freeze( true )

	self:SetMaterial( "freezetag/ice" )
	self:SetNWBool( "Frozen", true )
	
	self:EmitSound( table.Random( GAMEMODE.GlassHit ), 100, math.random(90,110) )
	
	--local col = team.GetColor( self:Team() )
	self:SetColor( Color(245, 245, 255 ), math.random(50,150) )
	
	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	util.Effect( "ice_poof", ed, true, true )
	
end

function meta:IsFrozen()
	return self:GetNWBool( "Frozen", false )
end

function meta:ThawCheck()
	local thawerCount = 0
	local thawerTable = {}
	
	for k,v in pairs( player.GetAll() ) do
		
		if v == self or v:IsFrozen() or (v:Team() != self:Team() ) then continue end
		if v:Alive() and v:GetPos():Distance( self:GetPos() ) <= 55 then
			thawerCount = thawerCount + 1
			thawerTable[#thawerTable+1] = v
			if !self.BeingThawed then
				self.BeingThawed = true
				local ed = EffectData()
				ed:SetOrigin( self:GetPos() + Vector(0,0,30) )
				util.Effect( "thaw_steam", ed, true, true )
				timer.Create("thawparticledelay"..self:SteamID(),0.3,1, function() self.BeingThawed = false end)
			end
			
		end
	end
	
	self.LastThawTick = self.LastThawTick or 0
	
	if (thawerCount > 0) and (CurTime() - self.LastThawTick > 1) then
		
		local thawMultiplier = (thawerCount / 2) + 0.5
		local thawAmount = (baseThawAmount - ( team.NumPlayers(self:Team()) * subtractPerPly )) * thawMultiplier
		local finalThawAmount = math.Clamp( math.ceil(thawAmount), 15, baseThawAmount)

		self:SetHealth( math.Clamp( self:Health() + finalThawAmount, 1, self:GetMaxHealth() ) )
		self.LastThawTick = CurTime()

		if self:Health() >= self:GetMaxHealth() then
			local names = ""
			local nameCount = 1
			for k,v in pairs(thawerTable) do
				if nameCount == 1 then
					names = v:Nick()
				elseif nameCount < #thawerTable then
					names = names .. ", ".. v:Nick()
				else
					names = names .. " and " .. v:Nick()
				end
				
				nameCount = nameCount + 1
				v:AddFrags( 1 )
			end
			net.Start( "PlayerKilledByPlayer" )
-		
-					net.WriteEntity( self )
-					net.WriteString( "thaw" )
-				--	net.WriteEntity( )
-		
-			net.Broadcast()
			self:Thaw(true)
			self:PlayerMsg("You were thawed by " .. names .. "!")
		end
	end
		
end
