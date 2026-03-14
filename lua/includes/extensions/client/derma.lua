local GetNamedSkin, RefreshSkins = derma.GetNamedSkin, derma.RefreshSkins

local function SetSkin( panel, name )
    local panels = panel:GetChildren()

    for i = 1, #panels do
        local panel = panels[i]

        panel:SetSkin( name )
    end
end


function derma.SetSkin( name )
    local skin = GetNamedSkin( name )
    if skin == nil then return end

    SetSkin( vgui.GetWorldPanel(), name )

    RefreshSkins()

    hook.Run( "DermaSkinChanged", name )
end