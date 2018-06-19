class X2DownloadableContentInfo_WotCBallisticShields extends X2DownloadableContentInfo;

static event OnLoadedSavedGame()
{
	`Log("Starting OnLoadedSavedGame",, 'WotCBallisticShields');
	UpdateStorage();
}

// ******** HANDLE UPDATING STORAGE ************* //
static function UpdateStorage()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local array<X2ItemTemplate> ItemTemplates;
	local XComGameState_Item NewItemState;
	local int i;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Musashi: Updating HQ Storage to add CombatKnife");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	ItemTemplates.AddItem(ItemTemplateMgr.FindItemTemplate('BallisticShield_CV'));

	for (i = 0; i < ItemTemplates.Length; ++i)
	{
		if(ItemTemplates[i] != none)
		{
			if (!XComHQ.HasItem(ItemTemplates[i]))
			{
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " not found, adding to inventory",, 'WotCBallisticShields');
				NewItemState = ItemTemplates[i].CreateInstanceFromTemplate(NewGameState);
				NewGameState.AddStateObject(NewItemState);
				XComHQ.AddItemToHQInventory(NewItemState);
				History.AddGameStateToHistory(NewGameState);
			} else {
				`Log(ItemTemplates[i].GetItemFriendlyName() @ " found, skipping inventory add",, 'WotCBallisticShields');
				History.CleanupPendingGameState(NewGameState);
			}
		}
	}

	// Check Tier 2 & 3 for running campaigns that already bought the shields
	AddHigherTiers('BallisticShield_MG', 'MediumPlatedArmor', XComHQ, NewGameState);
	AddHigherTiers('BallisticShield_BM', 'MediumPoweredArmor', XComHQ, NewGameState);
	//schematics should be handled already, as the BuildItem UI draws from ItemTemplates, which are automatically loaded
}

static function AddHigherTiers(
	name Template,
	name CheckTemplate,
	XComGameState_HeadquartersXCom XComHQ,
	XComGameState NewGameState
	)
{
	local XComGameState_Item NewItemState;
	local XComGameStateHistory History;
	local X2ItemTemplate ItemTemplate, CheckItemTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;

	History = `XCOMHISTORY;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateMgr.FindItemTemplate(Template);
	CheckItemTemplate = ItemTemplateMgr.FindItemTemplate(CheckTemplate);
	if(ItemTemplate != none)
	{
		if (!XComHQ.HasItem(ItemTemplate) && 
			XComHQ.HasItem(CheckItemTemplate))
		{
			`Log(ItemTemplate.GetItemFriendlyName() @ " not found, adding to inventory",, 'WotCBallisticShields');
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(NewItemState);
			XComHQ.AddItemToHQInventory(NewItemState);
			History.AddGameStateToHistory(NewGameState);
		} else if(XComHQ.HasItem(ItemTemplate) && !XComHQ.HasItem(CheckItemTemplate)) {
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			XComHQ.RemoveItemFromInventory(NewGameState, NewItemState.GetReference(), 1);
			`Log(ItemTemplate.GetItemFriendlyName() @ " removed because coressponding tier not unlocked",, 'WotCBallisticShields');
		} else {
			`Log(ItemTemplate.GetItemFriendlyName() @ " found or not unlocked yet, skipping inventory add",, 'WotCBallisticShields');
			History.CleanupPendingGameState(NewGameState);
		}
	}
}

static function bool CanAddItemToInventory_CH(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
{
	local X2WeaponTemplate			WeaponTemplate;
	local bool						bEvaluate;
	local XComGameState_Item		PrimaryWeapon, SecondaryWeapon;
	//local XGParamTag				LocTag;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	PrimaryWeapon = UnitState.GetPrimaryWeapon();
	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	//LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	if (X2WeaponTemplate(SecondaryWeapon.GetMyTemplate()).WeaponCat == 'Shield' &&
		WeaponTemplate.InventorySlot == eInvSlot_PrimaryWeapon)
	{
		if (class'X2DataStructure_BallisticShields'.default.AllowedPrimaryWeaponCategoriesWithShield.Find(WeaponTemplate.WeaponCat) == INDEX_NONE)
		{
			bCanAddItem = 0;
			//LocTag.StrValue0 = WeaponTemplate.GetLocalizedCategory();
			DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
				`XEXPAND.ExpandString(
					class'XGLocalizedData_BallisticShields'.default.m_strCategoryRestricted
				)
			);
			bEvaluate = true;
		}
	}

	if (WeaponTemplate.InventorySlot == eInvSlot_SecondaryWeapon &&
		WeaponTemplate.WeaponCat == 'Shield')
	{
		if (class'X2DataStructure_BallisticShields'.default.AllowedPrimaryWeaponCategoriesWithShield.Find(X2WeaponTemplate(PrimaryWeapon.GetMyTemplate()).WeaponCat) == INDEX_NONE)
		{
			bCanAddItem = 0;
			//LocTag.StrValue0 = X2WeaponTemplate(PrimaryWeapon.GetMyTemplate()).GetLocalizedCategory();
			DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(
				`XEXPAND.ExpandString(
					class'XGLocalizedData_BallisticShields'.default.m_strCategoryRestricted
				)
			);
			bEvaluate = true;
		}
	}

	if (bEvaluate)
		`LOG(GetFuncName() @ WeaponTemplate.DataName @ DisabledReason @ bEvaluate,, 'WotCBallisticShields');

	if(CheckGameState == none)
		return !bEvaluate;

	return bEvaluate;
}


static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	local X2WeaponTemplate PrimaryWeaponTemplate, SecondaryWeaponTemplate;
	local string AnimSetToLoad;

	if (!UnitState.IsSoldier())
	{
		return;
	}

	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());
	SecondaryWeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	
	if (SecondaryWeaponTemplate.WeaponCat == 'shield')
	{
		switch (PrimaryWeaponTemplate.WeaponCat)
		{
			case 'rifle':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AssaultRifle'";
				break;
			case 'sidearm':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AutoPistol'";
				break;
			case 'pistol': case 'sawedoff':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Pistol'";
				break;
			case 'shotgun':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Shotgun'";
				break;
			case 'bullpup':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_SMG'";
				break;
			case 'sword':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Sword'";
				break;
		}

		if (AnimSetToLoad != "")
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype(AnimSetToLoad)));
		}

		CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Armory'")));
		CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield'")));
	}
}

static function AddAnimSet(XComUnitPawn Pawn, AnimSet AnimSetToAdd)
{
	if (Pawn.Mesh.AnimSets.Find(AnimSetToAdd) == INDEX_NONE)
	{
		Pawn.Mesh.AnimSets.AddItem(AnimSetToAdd);
		//`LOG(GetFuncName() @ "adding" @ AnimSetToAdd,, 'RPG');
	}
}