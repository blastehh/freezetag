
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5

end

if ( CLIENT ) then

	SWEP.ViewModelFOV		= 60
	
	SWEP.PrintName = "Icicle Revolver"
	SWEP.IconLetter = "."
	SWEP.Slot = 1
	SWEP.Slotpos = 0
	
	killicon.AddFont( "ft_icerevolver", "HL2MPTypeDeath", SWEP.IconLetter, Color( 110, 210, 245, 255 ) )

end

SWEP.Base				= "ft_base"

SWEP.HoldType			= "pistol"

SWEP.ViewModel = "models/weapons/v_357.mdl"  
SWEP.WorldModel	= "models/weapons/w_357.mdl"  

SWEP.Primary.Sound			= Sound( "Weapon_357.Single" )
SWEP.Primary.Reload         = nil
SWEP.Primary.Damage			= 30
SWEP.Primary.Recoil			= 9.5
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.90

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 24
SWEP.Primary.Automatic		= false

function SWEP:Reload()
	if self.Weapon:Clip1() >= self.Primary.ClipSize then return end
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
	
end

function SWEP:CanPrimaryAttack()

	if self.Weapon:Clip1() <= 0 then

		self.Weapon:DefaultReload( ACT_VM_RELOAD )
		return false
		
	end
	
	return true
	
end