
local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

local function ParseAspectRatio(AspectRatio)
    if type(AspectRatio) == "string" then
        local Width, Height = AspectRatio:match("^%s*(%d+)%s*:%s*(%d+)%s*$")

        Width = tonumber(Width)
        Height = tonumber(Height)

        if Width and Height and Width > 0 and Height > 0 then
            return Width / Height
        end
    elseif type(AspectRatio) == "number" and AspectRatio > 0 then
        return AspectRatio
    end

    return 16 / 9
end

function Element:New(Config)
    local ImageModule = {
        __type = "Image",
        Image = Config.Image or "",
        AspectRatio = Config.AspectRatio or "16:9",
        Radius = Config.Radius or Config.Window.ElementConfig.UICorner,
    }

    local MainImage = Creator.Image(
        ImageModule.Image,
        ImageModule.Image,
        ImageModule.Radius,
        Config.Window.Folder,
        "Image",
        false
    )

    if not MainImage then
        warn("[WindUI] Failed to create image")
        return ImageModule.__type, ImageModule
    end

    MainImage.Parent = Config.Parent
    MainImage.Size = UDim2.new(1, 0, 0, 100)
    MainImage.BackgroundTransparency = 1

    local AspectConstraint = MainImage:FindFirstChildOfClass("UIAspectRatioConstraint")

    if not AspectConstraint then
        AspectConstraint = New("UIAspectRatioConstraint", {
            Parent = MainImage,
        })
    end

    AspectConstraint.AspectRatio = ParseAspectRatio(ImageModule.AspectRatio)
    AspectConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
    AspectConstraint.DominantAxis = Enum.DominantAxis.Width

    function ImageModule:SetImage(Image)
        self.Image = Image

        if MainImage:IsA("ImageLabel") or MainImage:IsA("ImageButton") then
            MainImage.Image = Image
        else
            local ImageObject = MainImage:FindFirstChildWhichIsA("ImageLabel", true)

            if ImageObject then
                ImageObject.Image = Image
            end
        end
    end

    function ImageModule:SetAspectRatio(AspectRatio)
        self.AspectRatio = AspectRatio
        AspectConstraint.AspectRatio = ParseAspectRatio(AspectRatio)
    end

    function ImageModule:SetRadius(Radius)
        self.Radius = Radius

        local Corner = MainImage:FindFirstChildOfClass("UICorner")

        if Corner then
            Corner.CornerRadius = UDim.new(0, Radius)
        end
    end

    function ImageModule:SetVisible(Visible)
        MainImage.Visible = Visible
    end

    function ImageModule:Destroy()
        MainImage:Destroy()
    end

    ImageModule.Main = MainImage

    return ImageModule.__type, ImageModule
end

return Element
