class Hat_CosmeticItemQualityInfo_Sprint_SummerHat_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_SummerHat'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = false
	MeshOverride = SkeletalMesh'RideableGarchomp_Package.models.Summer_Hat_Wireframe'
	PhysicsAssetOverride = PhysicsAsset'RideableGarchomp_Package.Physics.Summer_Hat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGarchomp_Package.Icons.SummerHat_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SummerHatName"
	Description(0) = "SummerHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGarchomp_M'
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}