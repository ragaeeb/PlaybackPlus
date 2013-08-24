import bb.cascades 1.0
import bb.device 1.0

QtObject
{
    property DisplayInfo displayInfo: DisplayInfo {}
    property Container surface
    property OrientationHandler orientationHandler: OrientationHandler {
	    onOrientationChanged: {
            handleVideoDimensionsChanged(player.videoDimensions);
	    }
    }
    
    function handleVideoDimensionsChanged(videoDimensions)
    {
        if ( persist.getValueFor("stretch") == 0 )
        {
            surface.horizontalAlignment = HorizontalAlignment.Center
            surface.verticalAlignment = VerticalAlignment.Center
            
            if (orientationHandler.orientation == UIOrientation.Landscape) {
                if (videoDimensions.width > videoDimensions.height) { // src is landscape and device is portrait
                    surface.preferredWidth = displayInfo.pixelSize.height
                    surface.preferredHeight = (displayInfo.pixelSize.height/videoDimensions.width)*videoDimensions.height
                } else { // device is landscape and src is portrait
                    surface.preferredHeight = displayInfo.pixelSize.width
                    surface.preferredWidth = (displayInfo.pixelSize.width/videoDimensions.height)*videoDimensions.width
                }
            } else {
                if (videoDimensions.width > videoDimensions.height) { // device is portrait and src is landscape
                    surface.preferredWidth = displayInfo.pixelSize.width
                    surface.preferredHeight = (displayInfo.pixelSize.width/videoDimensions.width)*videoDimensions.height
                } else { // device is portrait, src is portrait
                    surface.preferredHeight = displayInfo.pixelSize.height
                    surface.preferredWidth = (displayInfo.pixelSize.height/videoDimensions.height)*videoDimensions.width
                }
            }
        } else {
            surface.resetPreferredSize()
            surface.horizontalAlignment = HorizontalAlignment.Fill
            surface.verticalAlignment = VerticalAlignment.Fill
        }
    }
    
    onCreationCompleted: {
        player.videoDimensionsChanged.connect(handleVideoDimensionsChanged);
    }
}