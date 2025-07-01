AddCSLuaFile()

local cvar_automatic = CreateConVar("ttt_gungun_automatic", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local cvar_clip_max = CreateConVar("ttt_gungun_clipmax", "50", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local cvar_clip_size = CreateConVar("ttt_gungun_clipsize", "50", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local cvar_default_clip = CreateConVar("ttt_gungun_defaultclip", "50", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local cvar_delay = CreateConVar("ttt_gungun_delay", "0.125", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local cvar_limited_stock = CreateConVar("ttt_gungun_limitedstock", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)


if SERVER then
    resource.AddFile("materials/VGUI/ttt/icon_rpg.vmt")
end


if CLIENT then
    SWEP.PrintName = "The Gun Gun"
    SWEP.Slot = 6

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54
    SWEP.DrawCrosshair = false

    SWEP.Icon = "vgui/ttt/icon_rpg"
    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "A gun that shoots guns that shoot."
    }
end


SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "rpg"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary = {
    Ammo = "none",
    Automatic = cvar_automatic:GetBool(),
    ClipMax = cvar_clip_max:GetInt(),
    ClipSize = cvar_clip_size:GetInt(),
    DefaultClip = cvar_default_clip:GetInt(),
    Delay = cvar_delay:GetFloat()
}

SWEP.AllowDrop = true
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = cvar_limited_stock:GetBool()
SWEP.InLoadoutFor = nil

SWEP.AmmoEnt = "none"
SWEP.IsSilent = false
SWEP.Kind = WEAPON_EQUIP1
SWEP.NoSights = true


function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local owner = self.Owner
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound("weapons/ar2/ar2_altfire.wav")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

    function create_random_gun_entity(owner)
        local gun_entity = ents.Create("weapon_ttt_gungun_ent")
        if not gun_entity:IsValid() then return nil end
    
        local gun_data = gun_entity.GunModels[math.random(#gun_entity.GunModels)]
    
        gun_entity:SetModel(gun_data[1])
        gun_entity.GunSound = gun_data[2]
        gun_entity.Damage = gun_data[3]
        
        return gun_entity
    end

    if SERVER then
        local gun = create_random_gun_entity(owner)

        if gun then
            local offset_z = owner:Crouching() and 4 or 8
            gun:SetPos((owner:EyePos() - Vector(0, 0, offset_z)) + (owner:GetForward() * 25))
            gun:SetAngles(owner:EyeAngles())
            gun:Spawn()
            gun:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

            local phys = gun:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableGravity(false)
                phys:Wake()
                phys:ApplyForceCenter(owner:GetAimVector():GetNormalized() * 1000)
            end
        end
    end

    self:TakePrimaryAmmo(1)
end