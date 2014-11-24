AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.HitDamage = 45
ENT.SplashDamage = 30

function ENT:Initialize()
 
	self.Entity:SetModel( Model( "models/props/cs_italy/orange.mdl" ) )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMaterial( "freezetag/ice" )
	local phys = self.Entity:GetPhysicsObject()
	self.Break = string.Explode(" ",table.Random( GAMEMODE.SnowballHit ) )[1]
	if IsValid( phys ) and IsValid( self.Entity ) then
		phys:Wake()
		--phys:EnableGravity(false)
		phys:SetVelocityInstantaneous( self.Entity:GetAngles():Forward():GetNormalized() * 2050 )
	end

	
	
end

function ENT:Think() 
	
end

function ENT:DieEffects()

	local ed = EffectData()
	ed:SetOrigin( self.Entity:GetPos() )
	util.Effect( "snowball_explode", ed, true, true )
	
	self.Entity:EmitSound( self.Break, 100, math.random(90,110) )
	self.Entity:Remove()
	
end

function ENT:PhysicsCollide( data, phys )

	if data.HitEntity:IsPlayer() then
		data.HitEntity:TakeDamage( self.HitDamage, self.Entity:GetOwner(), self.Entity )
	end
	
	for k,v in pairs( player.GetAll() ) do
		if v:GetPos():Distance( self.Entity:GetPos() ) < 100 and v != data.HitEntity then
			v:TakeDamage( self.SplashDamage, self.Entity:GetOwner(), self.Entity )
		elseif v:GetPos():Distance( self.Entity:GetPos() ) < 120 and v != data.HitEntity then
			v:TakeDamage( math.Round(self.SplashDamage * 0.3) , self.Entity:GetOwner(), self.Entity )
		end
	end
	
	self.Entity:DieEffects()
	
end


