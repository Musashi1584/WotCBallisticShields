class X2Ability_ShieldAbilitySet extends X2Ability config(Shields);

var config int SHIELD_WALL_DODGE;
var config int SHIELD_WALL_DEFENSE;
var config bool SHIELD_WALL_FREE_ACTION;

var config int SHIELD_POINTS_CV;
var config int SHIELD_POINTS_MG;
var config int SHIELD_POINTS_BM;

var config int SHIELD_MOBILITY_PENALTY;
var config int SHIELD_AIM_PENALTY;

static function array<X2DataTemplate> CreateTemplates()
{
local array<X2DataTemplate> Templates;
	
Templates.AddItem(ShieldWall());
Templates.AddItem(BallisticShield('BallisticShield_CV', default.SHIELD_POINTS_CV));
Templates.AddItem(BallisticShield('BallisticShield_MG', default.SHIELD_POINTS_MG));
Templates.AddItem(BallisticShield('BallisticShield_BM', default.SHIELD_POINTS_BM));
Templates.AddItem(ShieldBash());
Templates.AddItem(ShieldAnimSet());
	
return Templates;
}

static function X2AbilityTemplate ShieldWall()
{
	local X2AbilityTemplate Template;
	local X2Effect_ShieldWall CoverEffect;

	Template = class'X2Ability_DefaultAbilitySet'.static.AddHunkerDownAbility('ShieldWall');

	if (default.SHIELD_WALL_FREE_ACTION)
	{
		Template.AbilityCosts.Length = 0;
		Template.AbilityCosts.AddItem(default.FreeActionCost);
	}

	X2Condition_UnitProperty(Template.AbilityShooterConditions[0]).ExcludeNoCover = false;

	X2Effect_PersistentStatChange(Template.AbilityTargetEffects[0]).m_aStatChanges[0].StatAmount = default.SHIELD_WALL_DODGE;
	X2Effect_PersistentStatChange(Template.AbilityTargetEffects[0]).m_aStatChanges[1].StatAmount = default.SHIELD_WALL_DEFENSE;

	CoverEffect = new class'X2Effect_ShieldWall';
	CoverEffect.EffectName = 'ShieldWall';
	CoverEffect.bRemoveWhenMoved = false;
	CoverEffect.bRemoveOnOtherActivation = false;
	CoverEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	CoverEffect.CoverType = CoverForce_High;
	CoverEffect.DuplicateResponse = eDupe_Allow;
	Template.AddTargetEffect(CoverEffect);

	Template.OverrideAbilities.AddItem('HunkerDown');

	return Template;
}

static function X2AbilityTemplate BallisticShield(name TemplateName, int ShieldHPAmount)
{
	local X2AbilityTemplate Template;
	local X2Effect_EnergyShield ShieldedEffect;
	local X2Effect_GenerateCover CoverEffect;
	local X2Effect_PersistentStatChange PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(1, true, false, true, eGameRule_TacticalGameStart);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, ShieldHPAmount);
	Template.AddTargetEffect(ShieldedEffect);

	CoverEffect = new class'X2Effect_GenerateCover';
	CoverEffect.EffectName = 'BallisticShield';
	CoverEffect.bRemoveWhenMoved = false;
	CoverEffect.bRemoveOnOtherActivation = false;
	CoverEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	CoverEffect.CoverType = CoverForce_Low;
	CoverEffect.DuplicateResponse = eDupe_Allow;
	Template.AddTargetEffect(CoverEffect);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.SHIELD_MOBILITY_PENALTY);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Offense, default.SHIELD_AIM_PENALTY);
	Template.AddTargetEffect(PersistentStatChangeEffect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.SHIELD_MOBILITY_PENALTY);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ShieldBash()
{
	local X2AbilityTemplate                 Template;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('ShieldBash');

	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true, , false));
	//Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	Template.CustomFireAnim = 'FF_MeleeShieldBash';
	Template.CustomFireKillAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingFireAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingFireKillAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingTurnLeftFireAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingTurnLeftFireKillAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingTurnRightFireAnim = 'FF_MeleeShieldBash';
	Template.CustomMovingTurnRightFireKillAnim = 'FF_MeleeShieldBash';

	return Template;
}

static function X2AbilityTemplate ShieldAnimSet()
{
    local X2AbilityTemplate                 Template;
    local X2Effect_AdditionalAnimSets        AnimSets;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'ShieldAnimSet');

    Template.AbilitySourceName = 'eAbilitySource_Item';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = false;
    
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
    AnimSets = new class'X2Effect_AdditionalAnimSets';
    AnimSets.EffectName = 'ShieldAnimSet';
    //AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield'");
	AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Grenade'");
	AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Medkit'");
    AnimSets.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
    AnimSets.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(AnimSets);
    
    Template.bSkipFireAction = true;
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}