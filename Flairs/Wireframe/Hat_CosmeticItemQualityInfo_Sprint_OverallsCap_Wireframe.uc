class Hat_CosmeticItemQualityInfo_Sprint_OverallsCap_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_OverallsCap'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = false
	MeshOverride = SkeletalMesh'RideableGastrodon_Package.models.Overalls_Cap_Wireframe'
	PhysicsAssetOverride = PhysicsAsset'RideableGastrodon_Package.Physics.Overalls_Cap_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGastrodon_Package.Icons.Overalls_Cap_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_On
	HideFrontHair = CIQ_Off
	CosmeticItemName = "OverallsCapName"
	Description(0) = "OverallsCapDesc0"
	HatSectionGroup = "SprintHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGastrodon_WS'
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}