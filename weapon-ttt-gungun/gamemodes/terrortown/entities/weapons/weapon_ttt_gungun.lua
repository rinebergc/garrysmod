AddCSLuaFile()

SWEP.HoldType = "rpg"

if CLIENT then
    SWEP.PrintName = "The Gun Gun"
    SWEP.Slot = 6

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54
    SWEP.DrawCrosshair = false

    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "A gun that shoots guns that shoot."
    };

    SWEP.Icon = "vgui/ttt/icon_rpg"
end

if SERVER then
    resource.AddFile("materials/VGUI/ttt/icon_rpg.vmt")
end

SWEP.Base = "weapon_tttbase"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.Delay = 0.125
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.ClipMax = 50

SWEP.AllowDrop = true
SWEP.AmmoEnt = "none"
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.IsSilent = false
SWEP.Kind = WEAPON_EQUIP1
SWEP.LimitedStock = true
SWEP.NoSights = true

function SWEP:PrimaryAttack()
    if (self:CanPrimaryAttack()) then
        self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        self:EmitSound( "weapons/ar2/ar2_altfire.wav" )
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        if SERVER then
            local gun = ents.Create("weapon_ttt_gungun_ent")
            local vec = Vector( 0, 0, 8 )
            local rand = math.random( 1, 21 )
            gun:SetModel( gun.GunModels[rand][1] )
            gun.GunSound = gun.GunModels[rand][2]
            gun.Damage = gun.GunModels[rand][3]
            if self.Owner:Crouching() then vec = Vector(0,0,4) end
            gun:SetPos( ( self.Owner:EyePos() - vec ) + ( self.Owner:GetForward() * 25 ) )
            gun:SetAngles( self.Owner:EyeAngles() )
            gun:Spawn()
            local gunphys = gun:GetPhysicsObject()
            gunphys:EnableGravity( false )
            gunphys:Wake()
            gunphys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * 1000 )
        end
        self:TakePrimaryAmmo(1)
    end
end