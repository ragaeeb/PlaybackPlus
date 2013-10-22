import bb.cascades 1.0

Dialog
{
    id: dialog    
    
    property alias actionButton: actionButton // we expose this so users of this control can register for events
    property string dialogTitle: "Sample Title"
    property string actionLabel: "Action"
    property string dismissLabel: qsTr("Cancel")
    property bool rightButtonEnabled: true
    
    Container
    {
        layout: StackLayout {}
        
        Container
        {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.0
            }	        
            
            layout: DockLayout {}
            
            Container {
                id: backgroundContainer
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.Black
                opacity: 0.5
            }
            
            Container
            {	            	        
                topPadding: 116 // the top edge of the dialog should be attached to the bottom of the top banner
                leftPadding: 20
                rightPadding: 20
                
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
                
                Container
                {			        
                    Container
                    {
                        layout: DockLayout {}
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        ImageView
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill                    
                            
                            imageSource: "asset:///images/Dialogs/dialog_header_bg.png"
                        }
                        
                        Container {
                            leftPadding: 30
                            rightPadding: 30
                            
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Center
                            
                            Label {
                                objectName: "dialogTitle"
                                textStyle.color: Color.White
                                textStyle.base: SystemDefaults.TextStyles.PrimaryText
                                text: dialogTitle
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Center
                                content.flags: TextContentFlag.Emoticons
                                multiline: false
                            }
                        }
                    } // end title bar
                    
                    ScrollView {
                        scrollViewProperties {
                            scrollMode: ScrollMode.Vertical
                            overScrollEffectMode: OverScrollEffectMode.None
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        Container {
                            layout: DockLayout {
                            }
                            
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            ImageView {
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                imageSource: "asset:///images/Dialogs/dialog_body.png"
                            }
                            
                            TextArea {
                                backgroundVisible: false
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                preferredHeight: 400
                            }
                        } // end block bg container
                    }
                    
                    Container // cancel delete buttons
                    {
                        layout: DockLayout {}
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        ImageView
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            imageSource: "asset:///images/Dialogs/dialog_button_bg.png"	                
                        }
                        
                        Container
                        {	            	
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            bottomPadding: 30
                            
                            Container
                            {	            	
                                layout: DockLayout {}
                                
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                
                                leftPadding: 10
                                
                                DialogButton
                                {
                                    id: cancelButton				                
                                    imageButtonInstance.objectName: "cancelButton"
                                    
                                    dialogButtonLabel: dismissLabel + Retranslate.onLanguageChanged
                                    
                                    horizontalAlignment: HorizontalAlignment.Center
                                    verticalAlignment: VerticalAlignment.Center
                                    
                                    imageButtonInstance.onClicked: {
                                        dialog.close()
                                    }
                                }						            
                            }
                            
                            Container
                            {	            	
                                layout: DockLayout {}
                                
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }                            		            		
                                
                                rightPadding: 10
                                
                                DialogButton
                                {
                                    id: actionButton				                
                                    imageButtonInstance.objectName: "actionButton"
                                    imageButtonInstance.enabled: rightButtonEnabled
                                    
                                    dialogButtonLabel: actionLabel
                                    horizontalAlignment: HorizontalAlignment.Center
                                    verticalAlignment: VerticalAlignment.Center			                    
                                }						            
                            }		
                        }
                    }
                }		        
            } // Main top to bottom container
        }
    }
}
