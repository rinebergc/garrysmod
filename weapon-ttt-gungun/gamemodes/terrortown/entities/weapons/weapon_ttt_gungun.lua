local cvar_delay = CreateConVar("ttt_gungun_delay", "0.125", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_automatic = CreateConVar("ttt_gungun_automatic", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_clip_size = CreateConVar("ttt_gungun_clipsize", "50", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_clip_max = CreateConVar("ttt_gungun_clipmax", "50", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_default_clip = CreateConVar("ttt_gungun_defaultclip", "50", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_limited_stock = CreateConVar("ttt_gungun_limitedstock", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

if SERVER then
    AddCSLuaFile()
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

SWEP.Primary = {
    Delay = cvar_delay:GetFloat(),
    Automatic = cvar_automatic:GetBool(),
    Ammo = "none",
    ClipSize = cvar_clip_size:GetInt(),
    ClipMax = cvar_clip_max:GetInt(),
    DefaultClip = cvar_default_clip:GetInt()
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.AllowDrop = true
SWEP.AmmoEnt = "none"
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.IsSilent = false
SWEP.Kind = WEAPON_EQUIP1
SWEP.LimitedStock = cvar_limited_stock:GetBool()
SWEP.NoSights = true

function SWEP:CreateRandomGunEntity(owner)
    local gun_entity = ents.Create("weapon_ttt_gungun_ent")
    if not gun_entity:IsValid() then return nil end

    local gun_data = gun_entity.GunModels[math.random(#gun_entity.GunModels)]

    gun_entity:SetModel(gun_data[1])
    gun_entity.GunSound = gun_data[2]
    gun_entity.Damage = gun_data[3]
    
    return gun_entity
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local owner = self.Owner
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound("weapons/ar2/ar2_altfire.wav")
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

    if SERVER then
        local gun = self:CreateRandomGunEntity(owner)

        if gun then
            gun:SetPos((owner:EyePos() - Vector(0, 0, owner:Crouching() and 4 or 8)) + (owner:GetForward() * 25))
            gun:SetAngles(owner:EyeAngles())

            gun:Spawn()

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