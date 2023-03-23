class Hat_CosmeticItemQualityInfo_Sprint_Substitute_Wireframe extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	CosmeticItemWeApplyTo = class'Hat_CosmeticItemQualityInfo_Sprint_Substitute'
	ItemQuality = class'Hat_ItemQuality_Supporter'
	SupportsRoulette = false
	MeshOverride = SkeletalMesh'RideableSnorlax_Package.models.SubstituteHat_Wireframe'
	PhysicsAssetOverride = PhysicsAsset'RideableSnorlax_Package.Physics.SubstituteHat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableSnorlax_Package.Icons.SubstituteHatIcon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SubstituteName"
	Description(0) = "SubstituteDesc0"
	HatSectionGroup = "Hatless"
	StatusEffectOverride = class'Hat_StatusEffect_RideableSnorlax'
	SkinWeApplyTo = class'Hat_Collectible_Skin_Wireframe'
}