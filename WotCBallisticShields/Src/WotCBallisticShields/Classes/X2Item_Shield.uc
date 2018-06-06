class X2Item_Shield extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue ROCKETLAUNCHER_BASEDAMAGE;

var config int ROCKETLAUNCHER_ISOUNDRANGE;
var config int ROCKETLAUNCHER_IENVIRONMENTDAMAGE;
var config int ROCKETLAUNCHER_ISUPPLIES;
var config int ROCKETLAUNCHER_TRADINGPOSTVALUE;
var config int ROCKETLAUNCHER_IPOINTS;
var config int ROCKETLAUNCHER_ICLIPSIZE;
var config int ROCKETLAUNCHER_RANGE;
var config int ROCKETLAUNCHER_RADIUS;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(BallisticShield_CV());

	return Weapons;
}

static function X2WeaponTemplate BallisticShield_CV()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'BallisticShield_CV');
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shield';
	Template.strImage = "img:///WoTC_Shield_UI.Inv_Ballistic_Shield";
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";

	Template.BaseDamage = default.ROCKETLAUNCHER_BASEDAMAGE;
	Template.iSoundRange = default.ROCKETLAUNCHER_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.ROCKETLAUNCHER_IENVIRONMENTDAMAGE;
	Template.iClipSize = default.ROCKETLAUNCHER_ICLIPSIZE;
	Template.iRange = default.ROCKETLAUNCHER_RANGE;
	Template.iRadius = default.ROCKETLAUNCHER_RADIUS;
	
	Template.PointsToComplete = default.ROCKETLAUNCHER_IPOINTS;
	Template.TradingPostValue = default.ROCKETLAUNCHER_TRADINGPOSTVALUE;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_HeavyWeapon;
	Template.GameArchetype = "WoTC_Ballistic_Shield.Archetype.WP_Ballistic_Shield";
	Template.ArmorTechCatForAltArchetype = 'powered';
	Template.bMergeAmmo = true;
	Template.DamageTypeTemplateName = 'Melee';

	Template.Abilities.AddItem('ShieldAnimSet');
	Template.Abilities.AddItem('ShieldBash');

	Template.CanBeBuilt = false;
	Template.StartingItem = true;

	return Template;
}
