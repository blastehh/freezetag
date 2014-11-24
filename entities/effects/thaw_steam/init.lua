
function EFFECT:Init( data )
	
	local pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( pos )
	for i = 1, 3 do
		local particle = emitter:Add( "particles/smokey", pos )
		particle:SetVelocity( VectorRand() * 10 + Vector(0,0,1) * math.random(5,20) )
		particle:SetDieTime( math.Rand(0.5,1.5) )
		particle:SetStartAlpha( 180 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.Rand(10,20) )
		particle:SetEndSize( math.Rand(25,70) )
		particle:SetRoll( math.Rand(-360,360) )
		particle:SetRollDelta( math.Rand(-0.1,0.1) )
		particle:SetColor( 255, 255, 255 )
		
		particle:SetGravity( Vector(0,0,30) )
		particle:SetCollide( false )
		particle:SetBounce( 0.25 ) 
	end
	
	emitter:Finish()
	
end

function EFFECT:Think( )

	return false
	
end


function EFFECT:Render()
	
end
