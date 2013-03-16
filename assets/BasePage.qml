import bb.cascades 1.0

Page {
    property alias contentContainer: contentContainer.controls
    property alias titleContainer: titleBar
    property alias rootContainer: topLevel.controls
    
    Container
    {
        layout: DockLayout {}
        id: topLevel
        
		background: Color.create("#1b4c76")
        
	    Container {
	        TitleContainer {
	        	id: titleBar
	        }
	        
	        horizontalAlignment: HorizontalAlignment.Fill
	        verticalAlignment: VerticalAlignment.Fill
	
	        Container // This container is replaced
	        {
	            layout: DockLayout {
	                
	            }
	            
	            id: contentContainer
	            objectName: "contentContainer"
	            
	            horizontalAlignment: HorizontalAlignment.Fill
	            verticalAlignment: VerticalAlignment.Fill
	
	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }
	
	            ImageView {
	                imageSource: "asset:///images/bottomDropShadow.png"
	                topMargin: 0
	                leftMargin: 0
	                rightMargin: 0
	                bottomMargin: 0
	
	                horizontalAlignment: HorizontalAlignment.Fill
	                verticalAlignment: VerticalAlignment.Top
	                
	                animations: [
	                    TranslateTransition {
	                        id: translate
	                        toY: 0
	                        fromY: -100
	                        duration: 1000
	                    }
	                ]
	                
			        onCreationCompleted:
			        {
			            if ( app.getValueFor("animations") == 1 ) {
			                translate.play()
			            }
			        }
	            }
	        }
	    }
    }
}