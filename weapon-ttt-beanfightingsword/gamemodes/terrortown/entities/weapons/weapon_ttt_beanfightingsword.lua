AddCSLuaFile()

SWEP.HoldType = "melee2"

if CLIENT then
   SWEP.PrintName = "Bean Fighting Sword"
   SWEP.Slot = 6

   SWEP.ViewModelFlip = false
   SWEP.ViewModelFOV = 54
   SWEP.DrawCrosshair = false

   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "It's a real katana... like from Bean Battles..."
   };

   SWEP.Icon = "vgui/ttt/icon_weapon_ttt_beanfightingsword"
end

if SERVER then
   resource.AddFile("materials/VGUI/ttt/icon_weapon_ttt_beanfightingsword.vmt")
end

SWEP.Base = "weapon_tttbase"

SWEP.UseHands = true
-- Use crowbar for testing
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
-- SWEP.ViewModel = "models/weapons/c_PLACEHOLDER.mdl"
-- SWEP.WorldModel = "models/weapons/w_PLACEHOLDER.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = true -- Silent, but deadly. Like a true Shino-bean.
SWEP.NoSights = true
SWEP.DeploySpeed = 2 -- Deploy faster than standard weapons.

SWEP.Primary.Damage = 25 -- Primary Attack: Slash
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Damage = 100 -- Secondary Attack: Dash
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
   self:NetworkVar( "Float", 0, "ChargeStartTime" )
end

-- Primary attack from crowbar
function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not IsValid(self:GetOwner()) then return end

   if self:GetOwner().LagCompensation then -- for some reason not always true
      self:GetOwner():LagCompensation(true)
   end

   local spos = self:GetOwner():GetShootPos()
   local sdest = spos + (self:GetOwner():GetAimVector() * 70)

   local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
   local hitEnt = tr_main.Entity

   self:EmitSound("primary" .. math.random(1,2) .. ".wav", 100, 100)

   if IsValid(hitEnt) or tr_main.HitWorld then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetSurfaceProp(tr_main.SurfaceProps)
         edata:SetHitBox(tr_main.HitBox)
         edata:SetEntity(hitEnt)

         if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
            self:GetOwner():LagCompensation(false)
            self:GetOwner():FireBullets({Num=1, Src=spos, Dir=self:GetOwner():GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
         else
            util.Effect("Impact", edata)
         end
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end

   if SERVER then
      local tr_all = nil
      tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner()})
      
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

      if hitEnt and hitEnt:IsValid() then
         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self:GetOwner())
         dmg:SetInflictor(self.Weapon)
         dmg:SetDamageForce(self:GetOwner():GetAimVector() * 1500)
         dmg:SetDamagePosition(self:GetOwner():GetPos())
         dmg:SetDamageType(DMG_CLUB)

         hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
      end
   end

   if self:GetOwner().LagCompensation then
      self:GetOwner():LagCompensation(false)
   end
end

function SWEP:SecondaryAttack()
   if not IsFirstTimePredicted() then return end
   if not IsValid( self:GetOwner() ) then return end

   if self:GetChargeStartTime() == 0 then
      self:SetChargeStartTime( CurTime() )
      self:EmitSound("charging" .. math.random(1,2) .. ".wav", 100, 100, 0.8)
   end

   local charge_duration = 2 -- Create ConVar later

   if self:GetChargeStartTime() != 0 and self:GetChargeStartTime() + charge_duration > CurTime() then
      self:EmitSound( "secondary1.wav", 100, 100 )
   end

   self:SetChargeStartTime( 0 )
end

-- function SWEP:DashAttack()
--    self:EmitSound( "secondary1.wav", 100, 100 )

--    local ply = self:GetOwner()
--    ply:SetVelocity(ply:GetAimVector() * 1000)
-- 	timer.Simple( 1, function() t = true ply:SetVelocity(-0.8 * ply:GetVelocity())  end )

--    if ply:IsOnGround() then
--       self:PrimaryAttack()
--    end
-- end