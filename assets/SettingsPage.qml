import bb.cascades 1.0

BasePage {
    contentContainer: Container
    {
        leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
        
        SettingPair {
            title: qsTr("Animations")
        	toggle.checked: persist.getValueFor("animations") == 1
    
            toggle.onCheckedChanged: {
        		persist.saveValueFor("animations", checked ? 1 : 0)
        		
        		if (checked) {
        		    infoText.text = qsTr("Controls will be animated whenever they are loaded.")
        		} else {
        		    infoText.text = qsTr("Controls will be snapped into position without animations.")
        		}
            }
        }
        
        SettingPair {
            topMargin: 20
            title: qsTr("Landscape Lock")
        	toggle.checked: persist.getValueFor("landscape") == 1
    
            toggle.onCheckedChanged: {
        		persist.saveValueFor("landscape", checked ? 1 : 0)
        		
        		if (checked) {
        		    infoText.text = qsTr("The app will be locked to the landscape orientation.")
        		    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.DisplayLandscape
        		} else {
        		    infoText.text = qsTr("The app will not be locked to just the landscape orientation.")
        		    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All
        		}
            }
        }
        
        SettingPair {
            topMargin: 20
            title: qsTr("Stretch Video")
        	toggle.checked: persist.getValueFor("stretch") == 1
    
            toggle.onCheckedChanged: {
        		persist.saveValueFor("stretch", checked ? 1 : 0)
        		
        		if (checked) {
        		    infoText.text = qsTr("The video will be stretched to fill the entire screen.")
        		} else {
        		    infoText.text = qsTr("The video will not be stretched to fill the entire screen.")
        		}
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        Label {
            id: infoText
            multiline: true
            textStyle.fontSize: FontSize.XXSmall
            textStyle.textAlign: TextAlign.Center
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
}