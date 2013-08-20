import bb.cascades 1.0

Page {
    property alias contentContainer: contentContainer.controls
    property alias titleContainer: titleBarControl
    property alias rootContainer: topLevel.controls
    
    Container
    {
        layout: DockLayout {}
        id: topLevel
        
		background: Color.create("#1b4c76")
        
	    Container {
			Container {
			    id: titleBarControl
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
			        
			        onCreationCompleted: {
                        translate.play();
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
                            ParallelAnimation {
                                id: fadeTranslate

                                FadeTransition {
                                    duration: 1000
                                    easingCurve: StockCurve.CubicIn
                                    fromOpacity: 0
                                    toOpacity: 1
                                }

                                TranslateTransition {
                                    toY: 0
                                    fromX: 200
                                    duration: 1000
                                }
                            }
                        ]

                        onCreationCompleted: {
                            fadeTranslate.play();
                        }
                    }
			    }
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
	                        id: shadowTranslate
	                        toY: 0
	                        fromY: -100
	                        duration: 1000
	                    }
	                ]
	                
			        onCreationCompleted: {
                        shadowTranslate.play();
			        }
	            }
	        }
	    }
    }
}