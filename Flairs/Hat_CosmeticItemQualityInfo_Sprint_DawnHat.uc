class Hat_CosmeticItemQualityInfo_Sprint_DawnHat extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Legendary'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableGiratina_Package.models.Dawn_Hat'
	PhysicsAssetOverride = PhysicsAsset'RideableGiratina_Package.Physics.Dawn_Hat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGiratina_Package.Icons.Dawn_Hat_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "DawnHatName"
	Description(0) = "DawnHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGiratina'
}