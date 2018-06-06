class X2Ability_ShieldAbilitySet extends X2Ability config(GameData_WeaponData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(ShieldBash());
	Templates.AddItem(ShieldAnimSet());
	
	return Templates;
}

static function X2AbilityTemplate ShieldBash()
{
	local X2AbilityTemplate                 Template;

	Template = class'X2Ability_RangerAbilitySet'.static.AddSwordSliceAbility('ShieldBash');

	//Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

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
    AnimSets.AddAnimSetWithPath("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield'");
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