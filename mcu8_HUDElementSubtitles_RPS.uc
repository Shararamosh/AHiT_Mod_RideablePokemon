class mcu8_HUDElementSubtitles_RPS extends Hat_HUDElement;

struct KeywordReplacement
{
	var string Keyword;
	var string ReplSectionName;
	var string ReplKeyName;
	var string ReplPackageName;
	var string ReplLocalizedText;
};

var private transient string SectionName, KeyName, PackageName, LocalizedText;
var private transient Array<KeywordReplacement> KeywordReplacements;
var private transient float FadeIn, FadeOut;
var private transient bool IsClosing, KeywordsReplaced;
var private transient Color SubtitleColor;

event OnLanguageChange()
{
	UpdateLocalization();
}

simulated function UpdateLocalization()
{
	if (SectionName != "" && KeyName != "" && PackageName != "")
		LocalizedText = Localize(SectionName, KeyName, PackageName);
}

function bool OnPreCloseHUD(HUD H)
{
	IsClosing = true;
	return true;
}

function OnOpenHUD(HUD H, optional String command)
{
	local Array<string> SplitText;
	SubtitleColor = default.SubtitleColor;
	FadeIn = 0.0;
	FadeOut = 0.0;
	SectionName = "";
	KeyName = "";
	PackageName = "";
	LocalizedText = "";
	ParseStringIntoArray(command, SplitText, "|", false);
	if (SplitText.Length >= 4) //At least 4 sections. 3 of them - color.
	{
		SubtitleColor = MakeColor(Min(int(SplitText[0]), 255), Min(int(SplitText[1]), 255), Min(int(SplitText[2]), 255));
		if (SplitText.Length >= 6) //At least 6 sections. First 3 - color, next 3 - localization info.
		{
			SectionName = SplitText[3];
			KeyName = SplitText[4];
			PackageName = SplitText[5];
			UpdateLocalization();
		}
		else //4 or 5 sections - everything after 3rd section is part of localized text.
		{
			LocalizedText = SplitText[3];
			if (SplitText.Length == 5)
				LocalizedText $= "|"$SplitText[4];
		}
	}
	else if (SplitText.Length == 3) //Only 3 sections - localization info without color.
	{
		SectionName = SplitText[0];
		KeyName = SplitText[1];
		PackageName = SplitText[2];
		UpdateLocalization();
	}
	else //Less than 3 sections - whole command is a localized text.
		LocalizedText = command;
}

simulated function SetKeywordReplacements(Array<string> Keywords, Array<string> LocalizationPaths)
{
	local int i, n;
	local Array<string> SplitText;
	local KeywordReplacement ReplInfo;
	KeywordReplacements.Length = 0;
	n = Min(Keywords.Length, LocalizationPaths.Length);
	Keywords.Length = n;
	LocalizationPaths.Length = n;
	for (i = 0; i < n; i++)
	{
		if (Keywords[i] == "")
			continue;
		ReplInfo.Keyword = Keywords[i];
		ParseStringIntoArray(LocalizationPaths[i], SplitText, "|", false);
		if (SplitText.Length < 3)
		{
			ReplInfo.ReplSectionName = "";
			ReplInfo.ReplKeyName = "";
			ReplInfo.ReplPackageName = "";
			ReplInfo.ReplLocalizedText = LocalizationPaths[i];
		}
		else
		{
			ReplInfo.ReplSectionName = SplitText[0];
			ReplInfo.ReplKeyName = SplitText[1];
			ReplInfo.ReplPackageName = SplitText[2];
			ReplInfo.ReplLocalizedText = "";
		}
		KeywordReplacements.AddItem(ReplInfo);
	}
}

simulated function string ApplyKeywordReplacements()
{
	local int i;
	local string EditedText;
	if (LocalizedText == "")
		return "";
	EditedText = LocalizedText;
	for (i = 0; i < KeywordReplacements.Length; i++)
	{
		if (KeywordReplacements[i].Keyword == "")
			continue;
		if (KeywordReplacements[i].ReplLocalizedText != "")
			EditedText = Repl(EditedText, "["$KeywordReplacements[i].Keyword$"]", KeywordReplacements[i].ReplLocalizedText);
		else
			EditedText = Repl(EditedText, "["$KeywordReplacements[i].Keyword$"]", Localize(KeywordReplacements[i].ReplSectionName, KeywordReplacements[i].ReplKeyName, KeywordReplacements[i].ReplPackageName));
	}
	return EditedText;
}

function bool Tick(HUD H, float d)
{
	if (!Super.Tick(H, d))
		return false;	
	FadeIn = FMin(FadeIn+d/0.2, 1.0);
	if (IsClosing)
	{
		FadeOut = FMin(FadeOut+d/0.2, 1.0);
		if (FadeOut >= 1.0)
			CloseHUD(H, Class, true);
	}
	return true;
}

function bool Render(HUD H)
{
	local float alpha;
	local string ReplacedText;
    if (!Super.Render(H))
		return false;
	ReplacedText = ApplyKeywordReplacements();
	if (ReplacedText == "")
		return true;
	alpha = FadeIn*(1.0-FadeOut);
	H.Canvas.SetDrawColor(SubtitleColor.R, SubtitleColor.G, SubtitleColor.B, 255*alpha);
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(ReplacedText);
	DrawBorderedText(H.Canvas, ReplacedText, H.Canvas.ClipX*0.5, H.Canvas.ClipY*0.88, H.Canvas.ClipX*0.00035, true, TextAlign_Center);
    return true;
}

defaultproperties
{
	SubtitleColor = (R = 255, G = 255, B = 255)
}