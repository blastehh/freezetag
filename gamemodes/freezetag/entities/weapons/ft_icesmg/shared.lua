
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5

end

if ( CLIENT ) then

	SWEP.ViewModelFOV		= 60
	
	SWEP.PrintName = "Icicle SMG"
	SWEP.IconLetter = "/"
	SWEP.Slot = 2
	SWEP.Slotpos = 1
	
	killicon.AddFont( "ft_icesmg", "HL2MPTypeDeath", SWEP.IconLetter, Color( 110, 210, 245, 255 ) )

end

SWEP.Base				= "ft_base"

SWEP.HoldType			= "smg"
	
SWEP.ViewModel	= "models/weapons/v_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.Primary.Sound			= Sound("Weapon_SMG1.Single")
SWEP.Primary.Reload         = Sound("weapons/smg1/smg1_reload.wav")
SWEP.Primary.Damage			= 8
SWEP.Primary.Recoil			= 2.0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.035
SWEP.Primary.Delay			= 0.075
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.ClipSize		= 40
SWEP.Primary.DefaultClip	= 99999
print("PrimaryDefaultClip SMG: ".. SWEP.Primary.DefaultClip)
SWEP.Primary.Automatic		= true