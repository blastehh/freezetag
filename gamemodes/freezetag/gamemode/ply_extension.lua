
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

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
	
	for k,v in pairs( player.GetAll() ) do
		curPly = v:SteamID()
		if v == self or v:IsFrozen() or (v:Team() != self:Team() ) then continue end
		if v:Alive() and v:GetPos():Distance( self:GetPos() ) <= 55 then
			if !self.BeingThawed then
				self.BeingThawed = true
				local ed = EffectData()
				ed:SetOrigin( self:GetPos() + Vector(0,0,30) )
				util.Effect( "thaw_steam", ed, true, true )
				timer.Create("thawparticledelay"..self:SteamID(),0.3,1, function() self.BeingThawed = false end)
				
			end
			self.LastThawTick = self.LastThawTick or {}
			self.LastThawTick[curPly] = self.LastThawTick[curPly] or 0
			if CurTime() - self.LastThawTick[curPly] > 1 then
				local amount = math.Clamp( math.ceil( 46 - team.NumPlayers(self:Team()) * 3.5 ), 15, 46 )
				self:SetHealth( math.Clamp( self:Health() + amount, 1, self:GetMaxHealth() ) )
				self.LastThawTick[curPly] = CurTime()

				if self:Health() >= self:GetMaxHealth() then
					v:AddFrags( 1 )
					self:Thaw(true)
					self:PlayerMsg("You were thawed by " .. v:Nick() .. "!")
				end
			end
			
		end
	end
end