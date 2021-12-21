var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [
            ],
            "config": {
                "/": {
                    "ItemGeometries-1024x768": "",
                    "ItemGeometries-1673x884": "",
                    "ItemGeometries-1677x888": "",
                    "ItemGeometries-1714x884": "",
                    "ItemGeometries-1718x888": "",
                    "ItemGeometries-1920x1080": "",
                    "ItemGeometriesHorizontal": "",
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "com.github.zren.inactiveblur"
                },
                "/ConfigDialog": {
                    "DialogHeight": "558",
                    "DialogWidth": "720"
                },
                "/Configuration": {
                    "PreloadWeight": "0"
                },
                "/General": {
                    "ToolBoxButtonState": "topcenter",
                    "ToolBoxButtonX": "557",
                    "ToolBoxButtonY": "26",
                    "iconSize": "4",
                    "sortMode": "-1"
                },
                "/Wallpaper/com.github.zren.inactiveblur/General": {
                    "FillMode": "2",
                    "Image": "file:///usr/share/wallpapers/Arch/Arch.jpeg",
                    "SlidePaths": "/usr/share/wallpapers"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "file:///usr/share/wallpapers/Arch/Arch.jpeg",
                    "SlidePaths": "/usr/share/wallpapers"
                }
            },
            "wallpaperPlugin": "com.github.zren.inactiveblur"
        }
    ],
    "panels": [
    ],
    "serializationFormatVersion": "1"
}
;


plasma.loadSerializedLayout(layout);
