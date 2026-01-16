if SERVER then 
    AddCSLuaFile()
    AddCSLuaFile( "includes/extensions/client/derma.lua" )

    return 
end

include( "includes/extensions/client/derma.lua" )


local CVAR_SKIN = CreateClientConVar( "derma_skin", "Default", true, nil, "Forces Derma to use specified skin" )

cvars.AddChangeCallback( CVAR_SKIN:GetName(), function( _, _, newValue )
    if derma.GetNamedSkin( newValue ) == nil then
        print( string.format( "No Derma skin named '%s'", newValue ) )
        return
    end

    derma.SetSkin( newValue )

    RunConsoleCommand( "spawnmenu_reload" )
end, "derma.SetSkin" )


local HOOK_NAME         = "ForceDermaSkin"
local HOOK_IDENTIFIER   = "DermaSkinSelector"

hook.Add( HOOK_NAME, HOOK_IDENTIFIER, function()
    return CVAR_SKIN:GetString()
end, PRE_HOOK_RETURN )

if PRE_HOOK_RETURN == nil then
    local patch = function()
        local hooks = hook.GetTable()[HOOK_NAME]
        if hooks == nil then return end

        for hookId, hookFunc in pairs( hooks ) do
            if hookId == HOOK_IDENTIFIER then continue end

            hook.Remove( HOOK_NAME, hookId )
        end
    end

    hook.Add( "Initialize", "DermaSkinSelector", patch )

    patch()
end


list.Set( "DesktopWindows", "DermaSkinSelector", {

    title       = "#widget.derma_skin_selector",
    icon        = "vgui/hsv",
    width       = 480,
    height      = 350,
    onewindow   = true,
    init        = function( widgetIcon, window )

        window:SetTitle( "#widget.derma_skin_selector.title" )
        window:Center()

        local scrollpanel = window:Add( "DScrollPanel" )
        scrollpanel:Dock( FILL )

        for skinName, skinData in pairs( derma.SkinList ) do
            -- container to automatically set skin on its children
            local container = scrollpanel:Add( "Panel" )
            container:Dock( TOP )
            container:DockMargin( 0, 0, 0, 4 )
            container:SetSkin( skinName )
            container:SetTall( 64 ) 
            do
                local button = container:Add( "DButton" )
                button:Dock( FILL )
                button:DockPadding( 4, 4, 4, 4 )
                button:SetText( "" )
                button.DoClick = function() 
                    CVAR_SKIN:SetString( skinName )
                end
                
                local container = button:Add( "Panel" )
                container:Dock( TOP )
                container:SetMouseInputEnabled( false )
                do
                    local name = container:Add( "DLabel" )
                    name:Dock( LEFT )
                    name:SetDark( true )
                    name:SetText( skinData.PrintName )
                    name.PerformLayout = function( s, w, h )
                        s:SetWide( s:GetParent():GetWide() / 3 )
                    end

                    local author = container:Add( "DLabel" )
                    author:Dock( LEFT )
                    author:SetDark( true )
                    author:SetText( string.format( language.GetPhrase( "derma_skin_selector.author" ), skinData.Author ) )
                    author:SizeToContents()  
                end

                local description = button:Add( "DLabel" )
                description:Dock( FILL )
                description:SetDark( true )
                description:SetContentAlignment( 7 )
                description:SetText( skinData.Description )
            end
        end

    end
} )