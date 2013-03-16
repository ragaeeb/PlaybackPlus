import bb.cascades 1.0

Container {
    layout: DockLayout {}

    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Top
    
    ImageView {
        imageSource: "asset:///images/title_bg.amd"
        topMargin: 0
        leftMargin: 0
        rightMargin: 0
        bottomMargin: 0

        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
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

    Container
    {
        rightPadding: 20; bottomPadding: 50
        
	    horizontalAlignment: HorizontalAlignment.Right
	    verticalAlignment: VerticalAlignment.Center
        
		ImageView {
		    imageSource: "asset:///images/logo.png"
		    topMargin: 0
		    leftMargin: 0
		    rightMargin: 0
		    bottomMargin: 0
		
		    animations: [
		        FadeTransition {
		            id: fade
		            duration: 1000
		            easingCurve: StockCurve.CubicIn
		            fromOpacity: 0
		            toOpacity: 1
		        },
		
		        TranslateTransition {
		            id: translate2
		            toY: 0
		            fromX: 200
		            duration: 1000
		        }
		    ]
		    
		    onCreationCompleted:
		    {
		        if ( app.getValueFor("animations") == 1 )
		        {
		            fade.play()
		            translate2.play()
		        }
		    }
		}
    }
}